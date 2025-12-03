import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// ====================================================================
// 🎁 Slot Machine Widget (拉霸機/老虎機元件)
// 用於隨機決定禮物主題的彈出式互動視窗
// ====================================================================
class SlotMachineWidget extends StatefulWidget {
  const SlotMachineWidget({super.key});

  @override
  State<SlotMachineWidget> createState() => _SlotMachineWidgetState();
}

class _SlotMachineWidgetState extends State<SlotMachineWidget> {
  // 禮物主題列表 (可以根據需要擴充)
  final List<String> _giftThemes = const [
    '❌ 黑暗料理包 🤢',
    '🎁 質感實用組 ✨',
    '📦 廢物利用品 🗑️',
    '💰 現金禮券組 🧧',
    '🔨 實用工具包 🔧',
    '🎨 藝術文創組 🖼️',
    '🧴 香氛保養品 🧖',
  ];

  // 拉霸機顯示的當前主題
  String _currentTheme = '點擊按鈕拉霸 🎰';
  // 是否正在轉動
  bool _isSpinning = false;
  // 最終結果
  String? _finalResult;

  // 模擬拉霸機轉動並選定結果
  void _spinTheWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _finalResult = null; // 重置結果
    });

    // 隨機選取一個結果
    final random = Random();
    final int resultIndex = random.nextInt(_giftThemes.length);
    final String resultTheme = _giftThemes[resultIndex];

    // 模擬轉動過程
    int spinDurationMs = 2000; // 總轉動時間 2 秒
    int intervalMs = 100; // 每次更新間隔 100 毫秒

    // 使用計數器模擬轉動視覺效果
    int iterations = spinDurationMs ~/ intervalMs;
    int currentIteration = 0;

    // 設置一個計時器來模擬視覺轉動
    Future<void> _animateSpin() async {
      await Future.delayed(Duration(milliseconds: intervalMs));
      if (currentIteration < iterations - 5) {
        // 在大部分時間內，快速切換主題 (視覺轉動)
        final int tempIndex = random.nextInt(_giftThemes.length);
        setState(() {
          _currentTheme = _giftThemes[tempIndex];
        });
        currentIteration++;
        await _animateSpin();
      } else {
        // 接近尾聲時，減速並鎖定最終結果
        // 這裡可以加入更精細的減速邏輯
        setState(() {
          _currentTheme = resultTheme;
          _isSpinning = false;
          _finalResult = resultTheme;
        });
        // 播放震動回饋 (僅適用於支援的設備)
        HapticFeedback.heavyImpact();
      }
    }

    _animateSpin();
  }

  // 創建拉霸顯示區域
  Widget _buildDisplayArea() {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade700, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _currentTheme,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _isSpinning ? Colors.orange.shade800 : Colors.green.shade800,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // 創建按鈕
  Widget _buildSpinButton() {
    return ElevatedButton.icon(
      onPressed: _isSpinning ? null : _spinTheWheel,
      icon: _isSpinning
          ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : const Icon(Icons.casino, size: 24),
      label: Text(_isSpinning ? '轉動中...' : '決定命運！SPIN', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.yellow, width: 2),
        ),
        elevation: 10,
      ),
    );
  }

  // 創建結果提示
  Widget _buildResultHint() {
    if (_finalResult == null) {
      return const SizedBox(height: 20);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        '✅ 最終結果：${_finalResult!} 🎉',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.yellowAccent, // 改為亮黃色，與主題匹配
          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔴 根據螢幕寬度動態調整彈出視窗寬度 (RWD)
    final double screenWidth = MediaQuery.of(context).size.width;
    // 寬度佔螢幕的 75%
    final double dialogWidth = screenWidth * 0.75;
    // 限制最大寬度為 500，確保桌面環境不會太大
    final double maxWidth = min(dialogWidth, 500.0);

    return Center(
      // 🔴 使用 Padding 替代 margin，提供外邊距 (安全區域)
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Stack(
            // 🔴 允許 X 關閉按鈕超出 Stack 邊界
            clipBehavior: Clip.none,
            children: [
              // 1. 核心內容容器 (綠色邊框)
              Container(
                // 寬度已由 ConstrainedBox 控制
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.green.shade800,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red, width: 6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 讓 Column 只佔用內容所需的空間
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 標題
                    Text(
                      '🎁 禮物主題決定機 🎁',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.yellow.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // 拉霸顯示區域
                    _buildDisplayArea(),
                    const SizedBox(height: 30),

                    // 按鈕
                    _buildSpinButton(),

                    // 結果提示
                    // _buildResultHint(),

                    // 🔴 移除原本底部的「確認結果並關閉」TextButton
                  ],
                ),
              ),

              // 2. 🔴 右上角 X 關閉按鈕
              Positioned(
                // 使用負邊距讓 X 鈕脫離主體邊框
                top: -15,
                right: -15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red), // 使用紅色 X 圖標
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '關閉拉霸機',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}