import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'pages/home_page.dart';

/// ============================================================
/// ⭐ AppLayout
/// 全域 RWD + contentWidth 控制中心
/// 所有頁面 / 元件都能取用此資料 → 完整取代單頁 RWD
/// ============================================================
class AppLayout extends InheritedWidget {
  final double screenWidth;
  final double screenHeight;

  /// 🔥 全域 Layout Builder 控制的縮放比例（讓 UI 不跑版）
  final double scale;

  /// 🔥 全域內容最大寬度（行動裝置 / iPad / Web 各自不同）
  final double contentWidth;

  const AppLayout({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.scale,
    required this.contentWidth,
    required super.child,
  });

  static AppLayout of(BuildContext context) {
    final AppLayout? result =
    context.dependOnInheritedWidgetOfExactType<AppLayout>();
    assert(result != null, 'AppLayout not found in widget tree!');
    return result!;
  }

  @override
  bool updateShouldNotify(AppLayout oldWidget) => false;
}

/// ============================================================
/// ⭐ 主 App
/// ============================================================
class ChristmasApp extends StatefulWidget {
  const ChristmasApp({super.key});

  @override
  State<ChristmasApp> createState() => _ChristmasAppState();
}

class _ChristmasAppState extends State<ChristmasApp> {
  late AudioPlayer _player;
  final Random _random = Random();

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
  }

  /// 🔴 隨機播放背景音樂
  Future<void> _playRandomMusic() async {
    try {
      while (true) {
        final index = _random.nextInt(_audioAssets.length);
        await _player.setAsset(_audioAssets[index]);
        await _player.play();

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
    _player.dispose();
    super.dispose();
  }

  /// ============================================================
  /// ⭐ 這裡完全處理 RWD（全 app 通用）
  /// ============================================================
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // ------------------------------------------------------------
        // 🔥 RWD scale：解決所有跑版問題的核心
        //    - 基準以 iPhone 13 / 14 = 430px 為主
        // ------------------------------------------------------------
        final scale = (screenWidth / 430).clamp(0.75, 1.3);

        // ------------------------------------------------------------
        // 🔥 contentWidth：所有內容區域最大寬度
        //
        // Web  → 固定 480
        // iPad → 螢幕 60%（最多 560）
        // 手機 → 螢幕 90%
        // ------------------------------------------------------------
        double contentWidth;
        if (screenWidth >= 900) {
          contentWidth = 480; // Web
        } else if (screenWidth >= 600) {
          contentWidth = (screenWidth * 0.6).clamp(0, 560); // iPad
        } else {
          contentWidth = screenWidth * 0.9; // Mobile
        }

        return AppLayout(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          scale: scale,
          contentWidth: contentWidth,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: scale, // 🔥 全域字體等比例縮放
            ),

            /// ============================================================
            /// ⭐ Transform.scale → 全 App 等比例縮放（最關鍵）
            /// ============================================================
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,

              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: '🎄 Christmas Interactive Web',
                theme: ThemeData(
                  fontFamily: 'Arial',
                  colorScheme:
                  ColorScheme.fromSeed(seedColor: Colors.red),
                  useMaterial3: true,
                ),

                home: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SizedBox.expand(
                    child: Stack(
                      children: [
                        /// 🔴 app 全域背景
                        Image.asset(
                          'assets/images/christmas_bg.jpg',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),

                        /// 🔴 主頁面（已自動 RWD，不用調任何 UI）
                        const HomePage(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
