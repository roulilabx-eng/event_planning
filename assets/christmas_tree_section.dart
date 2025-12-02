// lib/widgets/christmas_tree_section.dart
import 'package:flutter/material.dart';


class ChristmasTreeSection extends StatelessWidget {
  const ChristmasTreeSection({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎄 點點聖誕樹',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text('點擊吊飾會出現不同的驚喜效果：照片、影片、動畫等。'),
        const SizedBox(height: 20),


        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildBall(context, '📸', '這裡會彈出照片示例！'),
            _buildBall(context, '🎬', '這裡會播放影片示例！'),
            _buildBall(context, '✨', '小動畫特效示例！'),
            _buildBall(context, '🎁', '更多自製互動可放這裡！'),
          ],
        )
      ],
    );
  }


  Widget _buildBall(BuildContext context, String emoji, String message) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(message),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }