// lib/features/throw/throw_page.dart
// 投掷页（核心物理动画）

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/result_templates.dart';
import '../../data/models/fortune_sign.dart';
import '../../data/models/question_record.dart';
import '../../providers/providers.dart';
import '../result/result_page.dart';
import '../../services/physics/block_physics.dart';

class ThrowPage extends ConsumerStatefulWidget {
  final SignCategory category;
  final String question;
  const ThrowPage({
    super.key,
    required this.category,
    required this.question,
  });

  @override
  ConsumerState<ThrowPage> createState() => _ThrowPageState();
}

class _ThrowPageState extends ConsumerState<ThrowPage>
    with SingleTickerProviderStateMixin {
  BlockPhysics? _physics;
  late AnimationController _controller;
  ThrowResultType? _result;
  FortuneSign? _matchedSign;
  bool _isDone = false;
  bool _isDisposed = false;  // 防止用户返回后还跳结果页
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),  // 60fps
    )..addListener(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startThrow();
    });
  }

  void _startThrow() {
    final size = MediaQuery.of(context).size;
    _physics = BlockPhysics();
    _physics!.init(size: size);
    _controller.repeat();
  }

  void _onTick() {
    if (_isDone) return;
    final dt = 0.016;
    final done = _physics!.update(dt);
    if (mounted) setState(() {});
    if (done && !_isDone) {
      _isDone = true;
      _controller.stop();
      _handleResult();
    }
  }

  Future<void> _handleResult() async {
    if (_isDisposed) return;  // 用户已返回，不处理

    final result = _physics!.getResult();
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
          );
    } else if (result == ThrowResultType.yin) {
      matchedSign = ref.read(signRepositoryProvider).matchForYin(
            category: widget.category,
            allSigns: allSigns,
          );
    }

    // 记录到历史
    if (user != null) {
      final record = QuestionRecord(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        question: widget.question,
        category: widget.category,
        result: result,
        signId: matchedSign?.id,
        nameAtTime: user.name,
      );
      await ref.read(recordsProvider.notifier).add(record);
    }

    if (_isDisposed) return;

    // 延迟 0.5s 后跳转
    await Future.delayed(const Duration(milliseconds: 500));
    if (_isDisposed || !mounted) return;

    // 用 Navigator.push + 自定义 PageRouteBuilder，绕过 go_router 的 reverse animation bug
    // 不再检查 go_router 路由（throw 不再走 go_router）
    try {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: Duration.zero,  // 瞬切，不闪
          pageBuilder: (context, animation, secondaryAnimation) => ResultPage(
            result: result,
            sign: matchedSign,
            category: widget.category,
            question: widget.question,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // pop 时：直接显示（瞬切）
            if (animation.status == AnimationStatus.reverse) {
              return child;
            }
            // push 时：淡入
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      // 任何异常都吞掉，不影响其他
    }
  }

  @override
  void dispose() {
    _isDisposed = true;  // 先标记，拦住所有 await 后的逻辑
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      body: Stack(
        children: [
          // 杯筊动画（_physics 在 postFrameCallback 异步初始化，第一帧可能为 null）
          if (!_isDone && _physics != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _BlockPainter(
                  blockA: _physics!.blockA,
                  blockB: _physics!.blockB,
                ),
              ),
            ),
          // 顶部返回
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.inkBlack),
              onPressed: () => context.pop(),
            ),
          ),
          // 底部提示
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _isDone ? '' : '叩 · 叩',
                style: const TextStyle(
                  fontSize: 24,
                  color: AppColors.gray,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockPainter extends CustomPainter {
  final Block blockA;
  final Block blockB;
  _BlockPainter({required this.blockA, required this.blockB});

  @override
  void paint(Canvas canvas, Size size) {
    _drawBlock(canvas, blockA);
    _drawBlock(canvas, blockB);
  }

  void _drawBlock(Canvas canvas, Block block) {
    final paint = Paint()
      ..color = block.face == BlockFace.flat
          ? const Color(0xFFB8895A)  // 浅木色
          : const Color(0xFF8B5A2B); // 深木色
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.save();
    canvas.translate(block.position.dx, block.position.dy);
    canvas.rotate(block.angle);

    // 阴影
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0, 4),
        width: 70,
        height: 16,
      ),
      shadowPaint,
    );

    // 主体（月牙形简化：椭圆）
    final rect = Rect.fromCenter(center: Offset.zero, width: 70, height: 70);
    canvas.drawOval(rect, paint);

    // 中心点
    final centerPaint = Paint()..color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(const Offset(0, 0), 4, centerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BlockPainter old) => true;
}
