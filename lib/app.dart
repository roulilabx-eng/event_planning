import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'database_repository.dart'; // 導入 Supabase 服務
import 'pages/home_page.dart';

// ============================================================
// ⭐ 應用程式啟動與初始化
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔴 1. 初始化 Supabase 客戶端 (使用 database_repository.dart 中的配置)
  // try {
  //   await DatabaseRepository.initialize();
  //   debugPrint('Supabase 初始化成功！');
  // } catch (e) {
  //   debugPrint('Supabase 初始化失敗: $e');
  //   // 可以在此處顯示一個錯誤頁面或日誌，但不阻擋應用啟動
  // }

  runApp(const MyApp());
}


// ============================================================
// ⭐ 主 App (整合音樂播放邏輯)
// ============================================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AudioPlayer _player;
  final Random _random = Random();

  // 🔴 背景音樂資源列表
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
    _player = AudioPlayer();
    // 啟動音樂播放
    // _playRandomMusic();
  }

  /// 🔴 隨機播放背景音樂 (循環播放)
  Future<void> _playRandomMusic() async {
    try {
      while (mounted) {
        final index = _random.nextInt(_audioAssets.length);

        // 設定播放資源
        await _player.setAsset(_audioAssets[index]);
        await _player.play();

        // 等待當前歌曲播放完成
        await _player.playerStateStream.firstWhere(
              (state) => state.processingState == ProcessingState.completed,
        );
      }
    } catch (e) {
      debugPrint("播放音樂失敗: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose(); // 釋放音樂播放器資源
    super.dispose();
  }

  // 由於我們改用 ResponsiveLayout，AppLayout 和 Transform.scale 結構被移除
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

      // 使用 HomePage 作為應用程式的起始頁
      home: const HomePage(),

      // 注意：AppLayout 和 Transform.scale 的全域縮放功能已在
      // responsive_layout.dart 和 home_page.dart 內部的 RWD 邏輯取代。
    );
  }
}