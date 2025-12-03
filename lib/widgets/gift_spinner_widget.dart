import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GiftSpinnerWidget extends StatefulWidget {
  final List<String> gifts; // 禮物主題清單
  final int columns; // 欄位數，預設 3

  const GiftSpinnerWidget({
    super.key,
    required this.gifts,
    this.columns = 3,
  });

  @override
  State<GiftSpinnerWidget> createState() => _GiftSpinnerWidgetState();
}

class _GiftSpinnerWidgetState extends State<GiftSpinnerWidget> {
  final Random _random = Random();
  late List<String> _currentValues;
  late List<Timer> _timers;

  @override
  void initState() {
    super.initState();
    _currentValues = List.generate(widget.columns, (_) => '');
    _timers = [];
    _startSpin();
  }

  @override
  void dispose() {
    for (var t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _startSpin() {
    // 每個欄位獨立滾動
    for (int i = 0; i < widget.columns; i++) {
      int count = 0;
      Timer timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        setState(() {
          _currentValues[i] = widget.gifts[_random.nextInt(widget.gifts.length)];
        });
        count++;
        // 每個欄位停滯時間不同，模擬拉霸效果
        if (count > 20 + i * 10) t.cancel();
      });
      _timers.add(timer);
    }
  }

  void _reSpin() {
    for (var t in _timers) t.cancel();
    _timers.clear();
    _startSpin();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🎁 抽禮物拉霸機'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _currentValues.map((val) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black),
            ),
            child: Text(
              val,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('關閉'),
        ),
        ElevatedButton(
          onPressed: _reSpin,
          child: const Text('重新抽取'),
        ),
      ],
    );
  }
}
