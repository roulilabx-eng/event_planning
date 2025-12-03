// lib/widgets/countdown_widget.dart

import 'package:flutter/material.dart';
import 'dart:async';

// 預設活動時間 (請根據實際需求修改)
final DateTime defaultEventTime = DateTime(2025, 12, 24, 19, 0, 0);

class CountdownWidget extends StatefulWidget {
  final DateTime targetDateTime; // 目標倒數時間

  const CountdownWidget({
    super.key,
    required this.targetDateTime,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Duration remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    // 每秒更新一次
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateRemaining());
  }

  @override
  void didUpdateWidget(covariant CountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetDateTime != widget.targetDateTime) {
      _calculateRemaining();
    }
  }

  void _calculateRemaining() {
    if (!mounted) return;

    setState(() {
      remaining = widget.targetDateTime.difference(DateTime.now());
      if (remaining.isNegative) remaining = Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ====================================================================
  // 輔助函式: 建立單個數字框
  // ====================================================================
  Widget _buildNumberBox(String number, double numberSize) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: numberSize * 0.05),
      padding: EdgeInsets.all(numberSize * 0.15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5), // 數字背景半透明遮罩
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2)
          )
        ],
      ),
      child: Text(
        number,
        style: TextStyle(
          fontSize: numberSize,
          fontWeight: FontWeight.bold,
          color: Colors.yellowAccent, // 數字顏色
        ),
      ),
    );
  }

  // ====================================================================
  // 輔助函式: 建立時間組 (數字 + 標籤)
  // ====================================================================
  Widget _buildTimeGroup(int value, String label, double numberSize, {bool isDays = false}) {
    // 處理天數：不需要補零。小時、分鐘、秒需要 padLeft(2, '0')
    String valueStr = isDays ? value.toString() : value.toString().padLeft(2, '0');

    final textStyle = TextStyle(
      fontSize: numberSize * 0.5,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Column(
      // mainAxisSize 設置為 min，確保 Column 只佔用內容所需的最小垂直空間
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 數字部分
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: valueStr.split('').map((n) => _buildNumberBox(n, numberSize)).toList(),
        ),

        SizedBox(height: numberSize * 0.1), // 數字與標籤間距

        // 標籤部分
        Text(label, style: textStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 固定尺寸邏輯：確保兩行佈局在大部分裝置上都能看
    double dayNumberSize;
    double hmsNumberSize;
    double spacing;

    if (screenWidth < 600) {
      // 行動裝置尺寸
      dayNumberSize = 40;
      hmsNumberSize = 30;
      spacing = 16.0;
    } else {
      // 桌面/平板尺寸
      dayNumberSize = 55;
      hmsNumberSize = 40;
      spacing = 24.0;
    }

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    // ============================================================
    // 固定兩行佈局
    // ============================================================
    return Column(
      // 設置為 center，讓倒數計時器在垂直方向上居中
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ------------------------------------
        // 第一行：天數 (Day)
        // ------------------------------------
        _buildTimeGroup(days, 'day', dayNumberSize, isDays: true),

        SizedBox(height: spacing * 1.5), // 兩行間距

        // ------------------------------------
        // 第二行：時/分/秒 (Hour/Minute/Second)
        // ------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeGroup(hours, 'hr', hmsNumberSize),
            SizedBox(width: spacing * 1.5), // 時分秒之間的間距
            _buildTimeGroup(minutes, 'min', hmsNumberSize),
            SizedBox(width: spacing * 1.5),
            _buildTimeGroup(seconds, 'sec', hmsNumberSize),
          ],
        ),
      ],
    );
  }
}