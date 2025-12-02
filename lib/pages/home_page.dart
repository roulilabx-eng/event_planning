import 'package:flutter/material.dart';
import '../widgets/snow_effect.dart';
import '../widgets/christmas_card.dart';
import 'countdown_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SnowEffect(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  '🎄 聖誕交換禮物派對 🎁',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '一起加入這個有趣的小小互動網站吧！',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 40),

                // 活動資訊
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📌 活動資訊',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('主題：猜謎 × 翻牌 × 聖誕樂趣'),
                      Text('時間：2024/12/24 19:00'),
                      Text('地點：聖誕小屋'),
                      Text('禮物金額：300 ~ 500'),
                      Text('Dress Code：紅 / 綠 / 手繪風')
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 聖誕卡片互動
                const ChristmasCard(),

                const SizedBox(height: 40),

                // 倒數計時按鈕
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CountdownPage()),
                    );
                  },
                  child: const Text('🎅 聖誕倒數'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
