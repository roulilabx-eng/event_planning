import 'package:flutter/material.dart';
import 'dart:async';

class CountdownWidget extends StatefulWidget {
  final DateTime targetDateTime; // 🔴 目標倒數時間

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateRemaining());
  }

  @override
  void didUpdateWidget(covariant CountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔴 當 targetDateTime 變動時重新計算
    if (oldWidget.targetDateTime != widget.targetDateTime) {
      _calculateRemaining();
    }
  }

  void _calculateRemaining() {
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

  // 🔴 單個數字遮罩框，支援自動縮放
  Widget _buildNumberBox(String number, double numberSize) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: numberSize * 0.05),
      padding: EdgeInsets.all(numberSize * 0.15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        number,
        style: TextStyle(
          fontSize: numberSize,
          fontWeight: FontWeight.bold,
          color: Colors.yellow,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔴 RWD 設定：依螢幕寬度自動調整數字大小
    final screenWidth = MediaQuery.of(context).size.width;
    double numberSize = screenWidth < 400 ? 30 : 40; // 小螢幕自動縮小
    double spacing = numberSize * 0.2;

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    final textStyle = TextStyle(
      fontSize: numberSize * 0.5, // 🔴 文字縮小到數字的一半
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // 🔴 置中對齊
      crossAxisAlignment: CrossAxisAlignment.end, // 🔴 統一底部對齊
      children: [
        // 🔴 天數
        ...days.toString().split('').map((n) => _buildNumberBox(n, numberSize)),
        SizedBox(width: spacing),
        Text('day', style: textStyle),

        SizedBox(width: spacing),

        // 🔴 小時
        ...hours.toString().padLeft(2, '0').split('').map((n) => _buildNumberBox(n, numberSize)),
        SizedBox(width: spacing),
        Text('hr', style: textStyle),

        SizedBox(width: spacing),

        // 🔴 分鐘
        ...minutes.toString().padLeft(2, '0').split('').map((n) => _buildNumberBox(n, numberSize)),
        SizedBox(width: spacing),
        Text('min', style: textStyle),

        SizedBox(width: spacing),

        // 🔴 秒
        ...seconds.toString().padLeft(2, '0').split('').map((n) => _buildNumberBox(n, numberSize)),
        SizedBox(width: spacing),
        Text('sec', style: textStyle),
      ],
    );
  }
}

// 🔴 預設活動時間
final DateTime defaultEventTime = DateTime(2025, 12, 24, 19, 0, 0);
