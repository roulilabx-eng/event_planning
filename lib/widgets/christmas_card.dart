import 'package:flutter/material.dart';

class ChristmasCard extends StatefulWidget {
  const ChristmasCard({super.key});

  @override
  State<ChristmasCard> createState() => _ChristmasCardState();
}

class _ChristmasCardState extends State<ChristmasCard> {
  final List<String> cards = ["Joy", "Snow", "Gift", "愛", "祝", "樂"];
  final Set<int> flipped = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🃏 翻開你的禮物提示',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final isFlipped = flipped.contains(index);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isFlipped) {
                    flipped.remove(index);
                  } else {
                    flipped.add(index);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isFlipped ? Colors.green : Colors.green.shade300,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: isFlipped
                    ? Text(cards[index],
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))
                    : const Text("?", style: TextStyle(color: Colors.white, fontSize: 28)),
              ),
            );
          },
        ),
      ],
    );
  }
}
