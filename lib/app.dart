import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // 🔴 播放音樂套件
import 'dart:math';
import 'pages/home_page.dart';

class ChristmasApp extends StatefulWidget {
  const ChristmasApp({super.key});

  @override
  State<ChristmasApp> createState() => _ChristmasAppState();
}

class _ChristmasAppState extends State<ChristmasApp> {
  late AudioPlayer _player; // 🔴 音樂播放器
  final Random _random = Random();

  // 🔴 本地五首音樂清單
  final List<String> _audioAssets = [
    'assets/audio/jingle_bells.mp3',
    'assets/audio/silent_night.mp3',
    'assets/audio/deck_the_halls.mp3',
    'assets/audio/we_wish_you.mp3',
    'assets/audio/frosty_the_snowman.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer(); // 🔴 初始化播放器
    // _playRandomMusic(); // 🔴 啟動自動隨機背景音樂
  }

  /// 🔴 隨機播放五首本地音樂並無限循環
  Future<void> _playRandomMusic() async {
    try {
      while (true) { // 🔴 無限循環
        // 🔴 隨機選一首音樂
        final randomIndex = _random.nextInt(_audioAssets.length);
        final selectedMusic = _audioAssets[randomIndex];

        // 🔴 設定播放資源
        await _player.setAsset(selectedMusic);

        // 🔴 播放音樂
        await _player.play();

        // 🔴 等待播放完成，再自動播放下一首
        await _player.playerStateStream
            .firstWhere((state) => state.processingState == ProcessingState.completed);
      }
    } catch (e) {
      debugPrint('播放音樂失敗: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose(); // 🔴 釋放播放器資源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '🎄 Christmas Interactive Web',
      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(), // 🔴 首頁
    );
  }
}
