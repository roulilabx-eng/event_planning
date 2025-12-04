import 'package:flutter/material.dart';
import 'dart:math';

// ====================================================================
// 🎁 抽籤視窗主體 (已轉換為 StatefulWidget)
// ====================================================================
class LuckyDrawWidget extends StatefulWidget {
  const LuckyDrawWidget({super.key});

  @override
  State<LuckyDrawWidget> createState() => _LuckyDrawWidgetState();
}

class _LuckyDrawWidgetState extends State<LuckyDrawWidget> {
  // 🎯 抽獎項目列表 (假資料)
  final List<String> _items = [
    '🎬 電影主題',
    '🗺️ 旅遊景點',
    '🍲 特色美食',
    '📚 書籍名稱',
    '🕹️ 經典遊戲'
  ];

  // 狀態變數
  bool _isDrawing = false;
  String _currentResult = '按下 START 抽取主題'; // 初始顯示文字

  @override
  void initState() {
    super.initState();
    // 初始化時可以顯示第一個項目，讓 UI 看起來不空
    _currentResult = _items[0];
  }

  // ----------------------------------------------------
  // 核心邏輯: 開始抽獎
  // ----------------------------------------------------
  void _startDraw() async {
    if (_isDrawing) return;

    setState(() {
      _isDrawing = true;
    });

    // 1. 預先決定最終結果
    final random = Random();
    final resultIndex = random.nextInt(_items.length);
    final String finalResult = _items[resultIndex];

    // 2. 規劃滾動步驟和變速邏輯
    // 總時長約 3 秒 (60 步 * 50ms = 3000ms)
    const int totalSpins = 60;
    // 恆定快速延遲 (50ms)
    const int fastDelay = 50;

    for (int i = 0; i < totalSpins; i++) {
      if (!mounted) return;

      // 恆定延遲
      int delayMs = fastDelay;

      await Future.delayed(Duration(milliseconds: delayMs));

      // 3. 滾動邏輯
      setState(() {
        if (i < totalSpins - 1) {
          // 滾動中：顯示下一個項目
          // 使用 (i + 1) 確保每次都不同，並循環使用列表
          _currentResult = _items[(i + 1) % _items.length];
        } else {
          // 最後一步：顯示最終結果
          _currentResult = finalResult;
        }
      });
    }

    // 4. 完成
    if (!mounted) return;
    setState(() {
      _isDrawing = false;
      _currentResult = finalResult; // 確保最後狀態是最終結果
    });
  }

  // ----------------------------------------------------
  // 模組 1: 視窗頭部 (標題) - 置中顯示
  // ----------------------------------------------------
  Widget _buildTitle() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Text(
          '🎰 主題你來選 🎰', // 標題文字
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 🎯 模組 2: 拉霸機 UI (顯示抽獎結果/過程)
  // ----------------------------------------------------
  Widget _buildSlotMachine() {
    // 調整 1: 底色固定為白色
    final Color backgroundColor = Colors.white;
    // 調整 2: 框線固定為黃色
    final Color borderColor = Colors.yellow.shade700;

    return Container(
      height: 80,
      alignment: Alignment.center,
      // 🎯 調整間距: 縮小頂部間距 (從 20 縮到 10)
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor, // 應用白色底色
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 6), // 框線寬度為 6
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100), // 快速切換以模擬滾動
          transitionBuilder: (Widget child, Animation<double> animation) {
            // 使用 FadeTransition 保持平滑切換，避免文字縮放
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            _currentResult, // 顯示當前狀態或結果
            key: ValueKey<String>(_currentResult), // 使用 Key 讓 AnimatedSwitcher 知道內容發生變化
            style: TextStyle(
              fontSize: 30, // 放大字體
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900, // 文字顏色為紅色
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // 模組 3: 底部動作區 (START 按鈕)
  // ----------------------------------------------------
  Widget _buildAction() {
    return ElevatedButton(
      // 抽獎中時禁用按鈕
      onPressed: _isDrawing ? null : _startDraw,
      style: ElevatedButton.styleFrom(
        // 抽獎中時，顏色會變淡 (透過 onPressed: null 自動處理)
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
        shadowColor: Colors.black,
      ),
      child: Text(
        // 根據狀態顯示不同文字
        _isDrawing ? '拉霸中...' : 'ＳＴＡＲＴ',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ----------------------------------------------------
  // 主建構函式 (組合模組與 RWD 包裝)
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final Color crimsonRed = Colors.red.shade900;

    // 確保對話框居中
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600, // 最大寬度
          maxHeight: 600, // 最大高度
        ),
        child: Stack(
          children: [
            // 1. 主要內容卡片 (必須在最底層)
            Material(
              borderRadius: BorderRadius.circular(16),
              color: crimsonRed,
              child: Container(
                // 增加頂部 padding (40)，為右上角按鈕預留空間
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellow.shade700, width: 8),
                  borderRadius: BorderRadius.circular(16),
                  color: crimsonRed,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. 標頭區塊
                    _buildTitle(),

                    // 分隔線
                    const Divider(color: Colors.white, thickness: 1.5),
                    // 🎯 移除 SizedBox(height: 16)，將間距控制轉移到 _buildSlotMachine 的 margin

                    // 🎯 2. 拉霸機 UI 模組
                    _buildSlotMachine(),

                    // 3. 動作按鈕區塊 (居中顯示)
                    Center(child: _buildAction()),
                  ],
                ),
              ),
            ),

            // 4. 關閉按鈕 (置於右上方，RWD-safe 邊緣定位)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(1, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.red.shade800,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}