import 'dart:math';
import 'package:flutter/material.dart';

class SnowEffect extends StatefulWidget {
  const SnowEffect({super.key});

  @override
  State<SnowEffect> createState() => _SnowEffectState();
}

class _SnowEffectState extends State<SnowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController controller; // 🔴 控制動畫
  final Random random = Random(); // 🔴 隨機數生成器
  late List<_Snowflake> snowflakes; // 🔴 雪花列表

  final int snowflakeCount = 20; // 🔴 雪花總數量
  final String snowImage = 'assets/images/snowflake.png'; // 🔴 雪花圖片路徑

  @override
  void initState() {
    super.initState();

    // 🔴 初始化雪花，每個雪花有隨機位置、大小、旋轉、縮放速度
    snowflakes = List.generate(snowflakeCount, (_) => _Snowflake(random));

    // 🔴 AnimationController 控制雪花動畫，duration 越長速度越慢
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60), // 🔴 整體動畫一圈 60 秒
    )..repeat(); // 🔴 無限循環
  }

  @override
  void dispose() {
    controller.dispose(); // 🔴 釋放動畫控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // 🔴 取得螢幕大小

    return AnimatedBuilder(
      animation: controller, // 🔴 根據動畫控制器重建畫面
      builder: (_, __) {
        return Stack(
          children: snowflakes.map((flake) {
            // 🔴 每次刷新時，雪花垂直向下移動
            flake.y += flake.speed;

            // 🔴 如果雪花超出畫面底部，重新回到畫面上方
            if (flake.y > screenSize.height) {
              flake.y = -flake.size; // 🔴 從頂部開始
              flake.x = random.nextDouble() * screenSize.width; // 🔴 隨機水平位置
              flake.rotation = random.nextDouble() * 2 * pi; // 🔴 隨機旋轉角度
            }

            final scale = flake.scale; // 🔴 取得雪花縮放比例

            return Positioned(
              left: flake.x, // 🔴 水平位置
              top: flake.y,   // 🔴 垂直位置
              child: Transform.rotate(
                angle: flake.rotation, // 🔴 旋轉雪花
                child: Transform.scale(
                  scale: scale, // 🔴 縮放雪花
                  child: Opacity(
                    opacity: 0.95, // 🔴 半透明，雪花不太刺眼
                    child: Image.asset(
                      snowImage,
                      width: flake.size,  // 🔴 雪花寬度
                      height: flake.size, // 🔴 雪花高度
                    ),
                  ),
                ),
              ),
            );
          }).toList(), // 🔴 將每個雪花 Widget 放進 Stack
        );
      },
    );
  }
}

// 🔴 雪花類別，保存每個雪花的狀態
class _Snowflake {
  double x;        // 🔴 雪花水平位置
  double y;        // 🔴 雪花垂直位置
  double size;     // 🔴 雪花大小
  double speed;    // 🔴 垂直飄落速度
  double rotation; // 🔴 雪花旋轉角度
  double scale;    // 🔴 雪花縮放比例

  _Snowflake(Random random)
      : x = random.nextDouble() * 400,        // 🔴 初始水平位置
        y = random.nextDouble() * 800,        // 🔴 初始垂直位置
        size = 10 + random.nextDouble() * 20, // 🔴 最大尺寸 10~25
        speed = 0.05 + random.nextDouble() * 0.2, // 🔴 降落速度 0.05~0.15
        rotation = random.nextDouble() * 2 * pi,  // 🔴 初始旋轉角度
        scale = 0.5 + random.nextDouble() * 0.2; // 🔴 雪花縮放 0.5~0.7
}
