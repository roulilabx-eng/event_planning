import 'package:flutter/material.dart';

class LuckyDrawWidget extends StatelessWidget {
  const LuckyDrawWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 ConstrainedBox 限制對話框最大尺寸，確保 RWD 效果
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 600,
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade700, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 標題
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎁 禮物猜謎抽籤 🎁',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // 內容提示 (確認成功開啟)
                const Text(
                  '這是一個新的「你猜猜」抽籤/遊戲視窗！',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  '（未來將在這裡實作抽籤或遊戲互動邏輯）',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 模擬抽籤按鈕
                ElevatedButton(
                  onPressed: () {
                    // 這裡可以放抽籤邏輯
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('啟動猜謎流程...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('開始猜謎', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}