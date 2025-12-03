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
  final Random _random = Random(); // 🔴 用於隨機挑選音樂

  // 🔴 五首本地音樂清單
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
    // _playRandomMusic(); // 🔴 啟動隨機背景音樂（如需自動播放解開此行）
  }

  /// 🔴 隨機播放五首背景音樂 → 自動播完下一首 → 無限循環
  Future<void> _playRandomMusic() async {
    try {
      while (true) { // 🔴 無限播放
        final randomIndex = _random.nextInt(_audioAssets.length); // 🔴 隨機取一首
        final selectedMusic = _audioAssets[randomIndex];

        await _player.setAsset(selectedMusic); // 🔴 載入音檔
        await _player.play(); // 🔴 播放音樂

        // 🔴 等待播放完成，再自動播放下一首
        await _player.playerStateStream.firstWhere(
              (state) => state.processingState == ProcessingState.completed,
        );
      }
    } catch (e) {
      debugPrint('播放音樂失敗: $e'); // 🔴 錯誤處理
    }
  }

  @override
  void dispose() {
    _player.dispose(); // 🔴 關閉播放器釋放記憶體
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

      // 🔴🔴🔴 整個 App 的背景圖片
      home: Scaffold(
        backgroundColor: Colors.transparent, // 🔴 透明避免蓋掉背景
        body: SizedBox.expand( // 🔴 使用 SizedBox.expand 確保容器填滿整個畫面
          child: Stack(
            children: [
              // 🔴 背景圖片
              Image.asset(
                'assets/images/christmas_bg.jpg', // 🔴 背景圖片路徑
                fit: BoxFit.cover, // 🔴 填滿整個螢幕
                width: double.infinity,
                height: double.infinity,
              ),
              // 🔴 原本頁面
              const HomePage(),
            ],
          ),
        ),
      ),
      // 🔴🔴🔴 背景設定結束
    );
  }
}
