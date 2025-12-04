import 'package:flutter/material.dart';
import 'dart:math';

import '../models/gift_theme_model.dart';
import '../repositories/database_repository.dart';

class SlotMachineWidget extends StatefulWidget {
  const SlotMachineWidget({super.key});

  @override
  State<SlotMachineWidget> createState() => _SlotMachineWidgetState();
}

class _SlotMachineWidgetState extends State<SlotMachineWidget> {
  late final Future<List<GiftTheme>> _themesFuture;

  List<GiftTheme> _themes = [];
  bool _isSpinning = false;
  late int _currentSlotIndex;

  final Random _random = Random();
  late ScrollController _scrollController;
  double _itemHeight = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // ----------------------------------------------------------
    // 只在 initState 呼叫一次資料
    // ----------------------------------------------------------
    _themesFuture = DatabaseRepository.getGiftThemes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // Slot Machine 轉動動畫
  // ----------------------------------------------------------------
  void _spin() async {
    if (_isSpinning || _themes.isEmpty || _itemHeight == 0) return;

    setState(() => _isSpinning = true);

    const spinDurationSeconds = 3.5;
    const fullReels = 50;

    final int themeCount = _themes.length;
    final int finalResult = _random.nextInt(themeCount);

    final double startOffset = _scrollController.offset;
    final double cycleHeight = _itemHeight * themeCount;
    final double offsetInCurrentCycle = startOffset % cycleHeight;

    double distance = cycleHeight * fullReels;
    distance += (_itemHeight * finalResult) - offsetInCurrentCycle;

    if (distance < 0) distance += cycleHeight;

    try {
      await _scrollController.animateTo(
        startOffset + distance,
        duration: Duration(milliseconds: (spinDurationSeconds * 1000).toInt()),
        curve: Curves.easeOutQuart,
      );
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _isSpinning = false;
      _currentSlotIndex = finalResult;
    });
  }

  // ----------------------------------------------------------------
  // 單一 Slot 顯示元件
  // ----------------------------------------------------------------
  Widget _buildSingleReelDisplay(int index, double reelSize) {
    final themeCount = _themes.length;
    if (themeCount == 0) return const SizedBox.shrink();

    final double itemHeight = reelSize * 0.4;

    if (_itemHeight == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _itemHeight = itemHeight;
            _scrollController.jumpTo(_itemHeight * index * 1000);
          });
        }
      });
    }

    Widget _buildItem(BuildContext context, int i) {
      final theme = _themes[i % themeCount];
      final themeName = theme.name;

      return Container(
        height: itemHeight,
        color: Colors.white,
        alignment: const Alignment(0, -0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FittedBox(
          child: Text(
            themeName,
            style: TextStyle(
              fontSize: reelSize * 0.1,
              fontWeight: FontWeight.w900,
              color: Colors.red.shade900,
            ),
          ),
        ),
      );
    }

    return Container(
      width: reelSize,
      height: itemHeight,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.yellow.shade700, width: 6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ListView.builder(
          controller: _scrollController,
          itemExtent: itemHeight,
          physics: _isSpinning
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          itemCount: 999999999,
          itemBuilder: _buildItem,
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // UI 主體
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = min(screenWidth * 0.9, 450.0);
    final double reelSize = maxWidth - 48;

    // 🔴 FutureBuilder 核心區塊：根據 _themesFuture 的狀態來繪製 UI
    return FutureBuilder<List<GiftTheme>>(
      future: _themesFuture,
      builder: (context, snapshot) {
        Widget content;
        String title = '禮物主題拉霸機';

        if (snapshot.connectionState != ConnectionState.done) {
          content = const Column(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text('載入主題中...', style: TextStyle(color: Colors.white)),
            ],
          );
        } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          title = '載入失敗';
          content = Column(
            children: [
              Text(
                '無法連線或資料為空。',
                style: TextStyle(color: Colors.yellow.shade300),
              ),
              const SizedBox(height: 20),
              _buildSingleReelDisplay(0, reelSize),
            ],
          );
        } else {
          _themes = snapshot.data!;
          if (_currentSlotIndex == null) _currentSlotIndex = 0;

          content = Column(
            children: [
              _buildSingleReelDisplay(_currentSlotIndex, reelSize),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isSpinning ? null : _spin,
                icon: _isSpinning
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : const Icon(Icons.casino_outlined),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  foregroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                label: Text(
                  _isSpinning ? '轉動中...' : '開始抽籤！',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.yellow.shade400, width: 8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 36),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      content,
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          )
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.red.shade900),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
