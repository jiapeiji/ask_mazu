// lib/services/sound/sound_service.dart
// 声音播放服务(木块落地音 / 结果揭晓 ding / 庙宇环境音)
// 2026-09 接入真实音频资源

import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _blockPlayer = AudioPlayer();
  final AudioPlayer _resultPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  /// 木块落地"叩"声(投掷完成后触发)
  Future<void> playBlockLand() async {
    await _blockPlayer.stop();
    await _blockPlayer.play(AssetSource('audio/block_land.mp3'));
  }

  /// 结果揭晓 ding(圣/笑/阴共用一个 ding 声)
  /// 音量 0.5(原 1.0 太大,2026-09 调)
  Future<void> playResult() async {
    await _resultPlayer.stop();
    await _resultPlayer.setVolume(0.5);
    await _resultPlayer.play(AssetSource('audio/result_ding.mp3'));
  }

  /// 庙宇环境音(订阅后,结果页背景循环)
  Future<void> startAmbient() async {
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    await _ambientPlayer.setVolume(0.4);
    await _ambientPlayer.play(AssetSource('audio/ambient_temple.mp3'));
  }

  /// 停止环境音(iOS 上单纯 stop() 偶发不彻底,需 release + seek 重置)
  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
    await _ambientPlayer.seek(Duration.zero);
    await _ambientPlayer.release();
  }

  /// 停止所有一次性音效(投掷 + 揭晓,用于账号删除等清理场景)
  Future<void> stopAllOneShot() async {
    await _blockPlayer.stop();
    await _blockPlayer.release();
    await _resultPlayer.stop();
    await _resultPlayer.release();
  }

  Future<void> dispose() async {
    await _blockPlayer.dispose();
    await _resultPlayer.dispose();
    await _ambientPlayer.dispose();
  }
}
