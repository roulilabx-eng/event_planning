import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

// ====================================================================
// 🔴 GlobalAudioService (全域單例音訊服務)
// - 管理 AudioPlayer 實例和音樂播放邏輯。
// - 專門負責解決 Web 瀏覽器自動播放限制。
// ====================================================================
class GlobalAudioService {
  // 單例實例
  static final GlobalAudioService _instance = GlobalAudioService._internal();
  factory GlobalAudioService() => _instance;
  GlobalAudioService._internal();

  // 播放器實例和狀態
  late final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();
  bool _isMusicStarted = false;

  // 背景音樂資源列表
  final List<String> _audioAssets = [
    'assets/audio/jingle_bells.mp3',
    'assets/audio/silent_night.mp3',
    'assets/audio/deck_the_halls.mp3',
    'assets/audio/we_wish_you.mp3',
    'assets/audio/frosty_the_snowman.mp3',
  ];

  /// 🔴 啟動隨機播放背景音樂 (循環播放)
  /// 此函數必須在用戶第一次與 App 互動時呼叫。
  void startMusic() {
    // 確保只啟動一次
    if (_isMusicStarted) {
      debugPrint("背景音樂已啟動，不重複播放。");
      return;
    }
    _isMusicStarted = true;
    _playRandomMusicLoop();
    debugPrint("背景音樂啟動成功。");
  }

  // 內部循環播放邏輯
  Future<void> _playRandomMusicLoop() async {
    try {
      while (_isMusicStarted) { // 使用狀態變數來控制循環
        final index = _random.nextInt(_audioAssets.length);
        final assetPath = _audioAssets[index];

        await _player.setAsset(assetPath);
        await _player.play();

        // 等待當前歌曲播放完成
        // 使用 Future.any 避免在 dispose 呼叫時 stuck 在 firstWhere
        await Future.any([
          _player.playerStateStream.firstWhere(
                (state) => state.processingState == ProcessingState.completed,
          ),
          Future.delayed(const Duration(hours: 1)) // 避免無限等待，但主要靠 _isMusicStarted
        ]);
      }
    } catch (e) {
      // 捕捉播放錯誤
      debugPrint("播放音樂失敗: $e");
    }
  }

  /// 🔴 停止和釋放資源
  void dispose() {
    _isMusicStarted = false; // 停止循環
    _player.stop(); // 停止播放
    _player.dispose(); // 釋放播放器
    debugPrint("AudioService 資源已釋放。");
  }
}