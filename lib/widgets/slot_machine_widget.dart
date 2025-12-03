import 'dart:math';
import 'package:flutter/material.dart';

class SlotMachineWidget extends StatefulWidget {
  const SlotMachineWidget({super.key});

  @override
  State<SlotMachineWidget> createState() => _SlotMachineWidgetState();
}

class _SlotMachineWidgetState extends State<SlotMachineWidget>
    with TickerProviderStateMixin {
  final List<String> _words = [
    '聖誕結', '迷路', '裁人', '東南西北',
    '禮物', '雪球', '聖誕樹', '禮盒',
    '燈飾', '交換', '聖誕夜', '快樂'
  ];

  List<String> _finalWords = List.generate(4, (_) => '');

  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final Random _random = Random();
  bool _spinning = false;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      4,
          (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000 + i * 300),
      ),
    );

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    ))
        .toList();

    _finalWords = List.generate(
      4,
          (_) => _words[_random.nextInt(_words.length)].padRight(4, ' '),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _spin() async {
    if (_spinning) return;

    _spinning = true;

    _finalWords = List.generate(
      4,
          (_) => _words[_random.nextInt(_words.length)].padRight(4, ' '),
    );

    for (int i = 0; i < 4; i++) {
      _controllers[i].reset();
      _controllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    await Future.wait(_controllers.map((c) => c.forward()).toList());

    _spinning = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 外層 padding
          const double containerPadding = 20;
          const double slotSpacing = 20;

          final double availableWidth =
              constraints.maxWidth - containerPadding * 2;

          // 四格 + 三個間距
          final double slotWidth =
              (availableWidth - slotSpacing * 3) / 4;

          // 自動調整 slot 高度
          final double slotHeight = slotWidth * 1.4;

          return Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/slot_machine_bg.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(containerPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 四格 row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: slotWidth,
                      height: slotHeight,
                      margin: EdgeInsets.only(
                        right: index < 3 ? slotSpacing : 0,
                      ),
                      child: AnimatedBuilder(
                        animation: _animations[index],
                        builder: (context, child) {
                          double offset =
                              _animations[index].value * slotHeight * 5;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: -offset,
                                  left: 0,
                                  right: 0,
                                  child: Column(
                                    children: List.generate(10, (i) {
                                      String word =
                                      _words[_random.nextInt(_words.length)]
                                          .padRight(4, ' ');
                                      return SizedBox(
                                        height: slotHeight,
                                        child: Center(
                                          child: Text(
                                            word[index],
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                                // 最終停留文字
                                Center(
                                  child: Text(
                                    _finalWords[index][index],
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _spin,
                  child: const Text(
                    '🎰 Spin',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
