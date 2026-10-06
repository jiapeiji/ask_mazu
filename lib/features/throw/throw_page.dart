// lib/features/throw/throw_page.dart
// 投掷页(MP4 视频驱动,2026-09 重构)
// 之前用自定义 BlockPhysics 2D 物理 + 切图旋转,现在改用预渲染视频:
/*
视频时序(2.0s 总长):
  - 0.0 - 0.8s: 杯筊下落 + 第一次落地
  - 0.8 - 1.5s: 翻转 / 二次落地
  - 1.5 - 2.0s: 完全静止(结果展示 0.5s,用户看清)
  - 2.0s: 跳结果页

事件触发:
  - 0.8s 触发"叩"声(画面刚落地)
  - 1.9s(剩 0.1s)触发跳页(用户已看清结果 0.4s)

设计要点:
  - 视频本身带水墨山水底图,throw_page 不画自己的背景
  - 顶覆盖层(返回按钮)浮在视频上(无底部"叩·叩"提示)
  - "预生成 result" 的语义保留:用户点投掷→随机 result→视频从头播到底
*/
// BlockPhysics 整模块已废弃,保留物理文件不删(其他 reference 处理)

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/result_templates.dart';
import '../../data/models/fortune_sign.dart';
import '../../data/models/question_record.dart';
import '../../providers/providers.dart';
import '../result/result_page.dart';

/// 视频总时长 4.76s(原视频),1.2 倍速播放 → 实际 ~3.97s
/// 常量是 1.2 倍速后的实际时间(v.position / v.duration 反映倍速后的真实时间)
const Duration _kLandedSoundAt = Duration(milliseconds: 417);  // 落地音(原 167,2026-09 再晚 0.25s)
const Duration _kJumpPageThreshold = Duration(milliseconds: 100);  // 视频剩 0.1s 跳页
const double _kPlaybackSpeed = 1.2;  // 视频倍速(1.0=原速,1.2=快 20%)

class ThrowPage extends ConsumerStatefulWidget {
  final SignCategory category;
  final String question;
  final bool isCustom;
  const ThrowPage({
    super.key,
    required this.category,
    required this.question,
    this.isCustom = false,
  });

  @override
  ConsumerState<ThrowPage> createState() => _ThrowPageState();
}

class _ThrowPageState extends ConsumerState<ThrowPage> {
  VideoPlayerController? _videoController;
  ThrowResultType? _result;     // 预生成的 result(选视频 + 后续 match 用)
  bool _isDone = false;          // 防止跳页重复触发
  bool _landedSoundPlayed = false;  // 防止"叩"声重复触发
  bool _isDisposed = false;      // 防止用户返回后还跳结果页
  final _random = Random();

  @override
  void initState() {
    super.initState();
    // 等 first frame 渲染后再 init video(避免 initState 里 context 不可用)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startThrow();
    });
  }

  void _startThrow() {
    // 1. 预生成 result(圣/笑/阴 三选一)
    _result = ThrowResultType.values[_random.nextInt(ThrowResultType.values.length)];

    // 2. 选对应视频(视频本身已含水墨山水底图 + 杯筊落地全过程)
    final asset = switch (_result!) {
      ThrowResultType.saint => 'assets/videos/saint.mp4',
      ThrowResultType.laugh => 'assets/videos/laugh.mp4',
      ThrowResultType.yin => 'assets/videos/yin.mp4',
    };

    _videoController = VideoPlayerController.asset(asset)
      ..addListener(_onVideoTick)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        // 1.2 倍速播放(落地节奏紧凑,落地结果展示 ~2.6s)
        _videoController!.setPlaybackSpeed(_kPlaybackSpeed);
        _videoController!.play();
      }).catchError((e) {
        // 视频初始化失败(极少见:文件损坏/缺编解码器)
        // 兜底:直接跳结果页
        if (mounted && !_isDisposed) {
          _isDone = true;
          _handleResult();
        }
      });
  }

  void _onVideoTick() {
    if (_videoController == null) return;
    final v = _videoController!.value;
    if (!v.isInitialized) return;

    // 1. 0.8s 触发落地"叩"声(画面第一次落地时刻)
    //    SoundService 是占位 TODO,等音频文件就绪解开注释即生效
    if (!_landedSoundPlayed && v.position >= _kLandedSoundAt) {
      _landedSoundPlayed = true;
      ref.read(soundServiceProvider).playBlockLand();
    }

    // 2. 视频接近结束(剩 0.1s)时跳页
    //    此时落地结果已展示约 0.4s,用户已看清
    if (!_isDone && v.duration - v.position <= _kJumpPageThreshold) {
      _isDone = true;
      _handleResult();
    }
  }

  Future<void> _handleResult() async {
    if (_isDisposed) return;  // 用户已返回,不处理

    final result = _result!;
    final allSigns = await ref.read(signsProvider.future);
    if (_isDisposed) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    final userId = user?.name ?? 'guest';

    FortuneSign? matchedSign;
    if (result == ThrowResultType.saint) {
      matchedSign = ref.read(signRepositoryProvider).matchForSaint(
            category: widget.category,
            date: DateTime.now(),
            userId: userId,
            allSigns: allSigns,
            isCustom: widget.isCustom,
          );
    } else if (result == ThrowResultType.yin) {
      matchedSign = ref.read(signRepositoryProvider).matchForYin(
            category: widget.category,
            allSigns: allSigns,
            isCustom: widget.isCustom,
          );
    }
    // 笑杯无签

    // V1.2 (v5):记录写入移到 result_page,用户主动点「保存 · 写入日记」才落地
    // throw_page 只负责 match 出签 + 跳 result_page,不在这里 add QuestionRecord

    if (_isDisposed) return;
    if (!mounted) return;

    // 落地震动反馈(投掷完成,settings 开关控制)
    if (ref.read(settingsProvider).hapticEnabled) {
      await ref.read(hapticServiceProvider).light();
    }

    // 用 Navigator.push + 自定义 PageRouteBuilder,绕过 go_router 的 reverse animation bug
    try {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: Duration.zero,  // 瞬切,不闪
          pageBuilder: (context, animation, secondaryAnimation) => ResultPage(
            result: result,
            sign: matchedSign,
            question: widget.question,
            mood: Mood.confused,  // TODO:从 home_page 真实选择传过来(下轮接心情状态)
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // pop 时:直接显示(瞬切)
            if (animation.status == AnimationStatus.reverse) {
              return child;
            }
            // push 时:淡入
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      // 任何异常都吞掉,不影响其他
    }
  }

  @override
  void dispose() {
    _isDisposed = true;  // 先标记,拦住所有 await 后的逻辑
    _videoController?.removeListener(_onVideoTick);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoReady = _videoController != null && _videoController!.value.isInitialized;

    return Scaffold(
      // 透明背景:视频自带水墨山水底图,不能有自己的米白色盖住
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 视频全屏(按视频原比例 contain,确保水墨山水完整)
          if (videoReady)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),

          // 顶部返回(底部"叩·叩"提示已删,2026-09)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.inkBlack),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}
