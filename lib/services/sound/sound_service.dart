// lib/services/sound/sound_service.dart
// 声音播放服务（木块落地音 + 庙宇环境音）
// 注：当前没有音频资源，调用是 no-op，等接入资源后直接生效

import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _blockPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  Future<void> playBlockLand() async {
    // TODO: 接入 assets/audio/block_land.mp3 后解开注释
    // await _blockPlayer.play(AssetSource('audio/block_land.mp3'));
  }

  Future<void> startAmbient() async {
    // TODO: 接入 assets/audio/ambient_temple.mp3 后解开注释
    // await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    // await _ambientPlayer.play(AssetSource('audio/ambient_temple.mp3'), volume: 0.4);
  }

  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
  }

  Future<void> dispose() async {
    await _blockPlayer.dispose();
    await _ambientPlayer.dispose();
  }
}
