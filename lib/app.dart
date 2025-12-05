import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // 保持這個引入，因為我們需要它的類型
import 'dart:math';
import 'repositories/database_repository.dart'; // 引入 Repository
import 'pages/home_page.dart';
import '../audio_service.dart'; // 🔴 引入全域音訊服務檔案

// ============================================================
// ⭐ 應用程式啟動與初始化
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🏆 初始化 Supabase 連線 🏆
  await DatabaseRepository.initializeSupabase();

  runApp(const MyApp());
}


// ============================================================
// ⭐ 主 App (整合全域音樂服務)
// - 移除音樂相關的狀態和方法，改用 GlobalAudioService。
// ============================================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 🔴 移除所有音樂相關的狀態變數

  @override
  void dispose() {
    // 🔴 釋放全域 AudioService 資源
    GlobalAudioService().dispose();
    super.dispose();
  }

  // 🔴 移除 _playRandomMusic 方法

  // 由於我們改用 ResponsiveLayout，AppLayout 和 Transform.scale 結構被移除
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '🎄聖誕 Ｘ 猜謎 Ｘ 交換禮物 🎄',
      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),

      // 🔴 直接使用 HomePage 作為應用程式的起始頁
      // 移除 GestureDetector，將音樂啟動的責任移交給 HomePage 內部元件。
      home: const HomePage(),
    );
  }
}