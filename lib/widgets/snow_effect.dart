import 'dart:math';
import 'package:flutter/material.dart';

// ====================================================================
// ❄️ 雪花動畫效果 (SnowEffect)
// 負責在畫面上生成並移動雪花
// ====================================================================
class SnowEffect extends StatefulWidget {
  const SnowEffect({super.key});

  @override
  State<SnowEffect> createState() => _SnowEffectState();
}

class _SnowEffectState extends State<SnowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController controller; // 控制動畫的控制器
  final Random random = Random(); // 隨機數生成器
  late List<_Snowflake> snowflakes; // 雪花物件列表

  final int snowflakeCount = 30; // 增加雪花總數量
  final String snowImage = 'assets/images/snowflake.png'; // 雪花圖片路徑

  @override
  void initState() {
    super.initState();

    // 初始化雪花，每個雪花有隨機位置、大小、旋轉、縮放和速度
    snowflakes = List.generate(snowflakeCount, (_) => _Snowflake(random));

    // AnimationController 控制雪花動畫，讓其持續移動
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40), // 降低持續時間以增加更新頻率
    )..repeat(); // 無限循環
  }

  @override
  void dispose() {
    controller.dispose(); // 釋放動畫控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // 取得螢幕大小

    return AnimatedBuilder(
      animation: controller, // 根據動畫控制器重建畫面
      builder: (_, __) {
        return Stack(
          children: snowflakes.map((flake) {
            // 每次刷新時，雪花垂直向下移動
            flake.y += flake.speed;

            // 如果雪花超出畫面底部，重新回到畫面上方
            if (flake.y > screenSize.height) {
              flake.reset(random, screenSize.width, screenSize.height);
            }

            final scale = flake.scale; // 取得雪花縮放比例

            return Positioned(
              left: flake.x, // 水平位置
              top: flake.y,   // 垂直位置
              child: Transform.rotate(
                angle: flake.rotation, // 旋轉雪花
                child: Transform.scale(
                  scale: scale, // 縮放雪花
                  child: Opacity(
                    opacity: 0.95, // 半透明，雪花不太刺眼
                    // 由於我們不知道 snowflake.png 是否存在，這裡使用 Text 搭配 emoji 作為安全備用
                    // 如果確定圖片存在，可以使用 Image.asset
                    child: flake.imageAsset
                        ? Image.asset(
                      snowImage,
                      width: flake.size,
                      height: flake.size,
                      errorBuilder: (context, error, stackTrace) {
                        // 如果圖片載入失敗，使用 Text 替代
                        return Text(
                          '❅', // 使用雪花 emoji
                          style: TextStyle(
                              fontSize: flake.size,
                              color: Colors.white,
                              shadows: const [
                                Shadow(blurRadius: 2.0, color: Colors.black45)
                              ]
                          ),
                        );
                      },
                    )
                        : Text(
                      '❅', // 使用雪花 emoji
                      style: TextStyle(
                          fontSize: flake.size,
                          color: Colors.white,
                          shadows: const [
                            Shadow(blurRadius: 2.0, color: Colors.black45)
                          ]
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(), // 將每個雪花 Widget 放進 Stack
        );
      },
    );
  }
}

// 🔴 雪花類別，保存每個雪花的狀態
class _Snowflake {
  double x;        // 雪花水平位置
  double y;        // 雪花垂直位置
  double size;     // 雪花大小
  double speed;    // 垂直飄落速度
  double rotation; // 雪花旋轉角度
  double scale;    // 雪花縮放比例
  bool imageAsset = true; // 假設圖片存在，若不確定請設為 false 並使用 emoji

  _Snowflake(Random random)
  // 速度放緩：從 0.5~2.0 調整為 0.1~0.8
  // 尺寸加大：從 10~30 調整為 15~35
      : x = random.nextDouble() * 400,        // 初始水平位置
        y = random.nextDouble() * 800,        // 初始垂直位置
        size = 15 + random.nextDouble() * 20, // 最大尺寸 15~35
        speed = 0.1 + random.nextDouble() * 0.7, // 降落速度 0.1~0.8
        rotation = random.nextDouble() * 2 * pi,  // 初始旋轉角度
        scale = 0.5 + random.nextDouble() * 0.4; // 雪花縮放 0.5~0.9

  // 重置雪花位置
  void reset(Random random, double screenWidth, double screenHeight) {
    x = random.nextDouble() * screenWidth; // 隨機水平位置
    y = -size; // 從頂部開始
    rotation = random.nextDouble() * 2 * pi; // 隨機旋轉角度
  }
}