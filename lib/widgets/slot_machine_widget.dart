import 'package:flutter/material.dart';
import 'dart:math';

import '../models/gift_theme_model.dart';
import '../repositories/database_repository.dart';
import '../globals.dart' as globals;
import '../models/participant_model.dart';

// -----------------------------------------------------------------------------
// 🔹 SlotMachineController
// -----------------------------------------------------------------------------
class SlotMachineController {
  final Random _random = Random();
  List<GiftTheme> themes = [];
  String? lastAssignedThemeName;

  Future<void> initialize() async {
    try {
      // 優先使用首頁預先載入的全域快取，若尚未載入則在此補抓一次
      if (globals.globalGiftThemesLoaded && globals.globalGiftThemes.isNotEmpty) {
        themes = List<GiftTheme>.from(globals.globalGiftThemes);
      } else {
        themes = await DatabaseRepository.getGiftThemes();
        globals.globalGiftThemes = List<GiftTheme>.from(themes);
        globals.globalGiftThemesLoaded = true;
      }
    } catch (e, st) {
      print('Error loading gift themes: $e\n$st');
    }

    if (themes.isEmpty) return;

    if (globals.currentUserNum != null) {
      final Participant? userData =
      await globals.getParticipantByNum(globals.currentUserNum!);
      if (userData != null && userData.giftAssignedTheme != null) {
        final matchedThemes =
        themes.where((t) => t.code == userData.giftAssignedTheme).toList();
        if (matchedThemes.isNotEmpty) {
          lastAssignedThemeName = matchedThemes.first.name;
        }
      }
    }
  }

  int getRandomIndex() {
    if (themes.isEmpty) return 0;
    return _random.nextInt(themes.length);
  }

  Future<void> updateUserAssignedTheme(int index) async {
    if (globals.currentUserNum == null || themes.isEmpty) return;
    final theme = themes[index];
    await DatabaseRepository.updateGiftAssignedTheme(
        globals.currentUserNum!, theme.code);
    lastAssignedThemeName = theme.name;
  }

  Future<String> fetchLatestUserTheme() async {
    if (globals.currentUserNum == null) return "無抽籤資料";
    final Participant? userData =
    await globals.getParticipantByNum(globals.currentUserNum!);
    if (userData == null || userData.giftAssignedTheme == null) {
      return "無抽籤資料";
    }
    final matchedThemes =
    themes.where((t) => t.code == userData.giftAssignedTheme).toList();
    if (matchedThemes.isEmpty) return "無抽籤資料";
    return matchedThemes.first.name;
  }
}

// -----------------------------------------------------------------------------
// 🔹 SlotMachineDisplay
// -----------------------------------------------------------------------------
class SlotMachineDisplay extends StatelessWidget {
  final double reelSize;
  final double itemHeight;
  final ScrollController scrollController;
  final List<GiftTheme> themes;

  const SlotMachineDisplay({
    super.key,
    required this.reelSize,
    required this.itemHeight,
    required this.scrollController,
    required this.themes,
  });

  @override
  Widget build(BuildContext context) {
    // 若尚未有主題資料，顯示佔位提示，避免除以 0
    if (themes.isEmpty) {
      return Container(
        width: reelSize,
        height: itemHeight,
        decoration: BoxDecoration(
          color: Colors.red.shade800,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.yellow.shade700, width: 6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: FittedBox(
              child: Text(
                '尚無可抽主題',
                style: TextStyle(
                  fontSize: reelSize * 0.12,
                  fontWeight: FontWeight.w900,
                  color: Colors.red.shade900,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: reelSize,
      height: itemHeight,
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.yellow.shade700, width: 6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ListView.builder(
          controller: scrollController,
          itemExtent: itemHeight,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 999999999,
          itemBuilder: (_, index) {
            final theme = themes[index % themes.length];
            return Container(
              alignment: Alignment.center,
              height: itemHeight,
              color: Colors.white,
              child: FittedBox(
                child: Text(
                  theme.name,
                  style: TextStyle(
                    fontSize: reelSize * 0.12,
                    fontWeight: FontWeight.w900,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🔹 SlotMachineWidget
// -----------------------------------------------------------------------------
class SlotMachineWidget extends StatefulWidget {
  const SlotMachineWidget({super.key});

  @override
  State<SlotMachineWidget> createState() => _SlotMachineWidgetState();
}

class _SlotMachineWidgetState extends State<SlotMachineWidget> {
  final SlotMachineController _controller = SlotMachineController();
  final ScrollController _scrollController = ScrollController();

  bool _isSpinning = false;
  double _itemHeight = 0;
  int _currentSlotIndex = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();
    if (!mounted) return;

    if (_controller.themes.isNotEmpty) {
      // 根據使用者上次抽中的主題（若有），決定初始停留的 index
      int initialIndex = 0;
      if (_controller.lastAssignedThemeName != null) {
        final matchedIndex = _controller.themes.indexWhere(
          (t) => t.name == _controller.lastAssignedThemeName,
        );
        if (matchedIndex >= 0) {
          initialIndex = matchedIndex;
        }
      }

      _currentSlotIndex = initialIndex;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 等第一幀完成、_itemHeight 已計算好後，再捲動到對應位置
        final double targetOffset = initialIndex * _itemHeight;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(targetOffset);
        }
        setState(() {});
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _spin() async {
    if (_isSpinning || _controller.themes.isEmpty || _itemHeight == 0) return;

    setState(() => _isSpinning = true);

    final int themeCount = _controller.themes.length;
    final int finalResult = _controller.getRandomIndex();

    // 1️⃣ 先把目前 offset 正規化到一個循環內，避免數值越滾越大造成精度問題
    final double cycleHeight = themeCount * _itemHeight;
    double currentOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    if (cycleHeight > 0) {
      currentOffset = currentOffset % cycleHeight;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(currentOffset);
      }
    }

    // 當前對應的主題索引（就近取整）
    final int currentIndex =
        ((currentOffset / _itemHeight).round()) % themeCount;

    // 2️⃣ 設定要多轉幾圈，模擬一般拉霸機「先快後慢」長時間轉動的感覺
    const int minSpins = 3;
    const int maxSpins = 6;
    final int extraSpins =
        minSpins + Random().nextInt(maxSpins - minSpins + 1); // 3~6 圈

    // 確保目標 index 在目前 index 之後（往前轉），並加上額外圈數
    int diff = finalResult - currentIndex;
    if (diff <= 0) {
      diff += themeCount;
    }
    final int totalSteps = extraSpins * themeCount + diff;
    final double targetOffset = currentOffset + totalSteps * _itemHeight;

    // 依照轉動圈數調整動畫時間
    final double spinDurationSeconds = 1.5 + extraSpins * 0.4;

    try {
      await _scrollController.animateTo(
        targetOffset,
        duration: Duration(milliseconds: (spinDurationSeconds * 1000).toInt()),
        // 由快到慢的減速曲線，模擬一般拉霸機收尾感
        curve: Curves.decelerate,
      );
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _isSpinning = false;
      _currentSlotIndex = finalResult;
      _controller.lastAssignedThemeName = _controller.themes[finalResult].name;
    });

    await _controller.updateUserAssignedTheme(_currentSlotIndex);
  }

  void _showLatestThemeDialog() async {
    String latestTheme = await _controller.fetchLatestUserTheme();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.yellow.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.yellow.shade700, width: 3),
          ),
          content: Text(
            latestTheme,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade700,
                foregroundColor: Colors.grey.shade800,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "我知道了",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = min(screenWidth * 0.9, 450.0);
    final double reelSize = maxWidth - 48;
    // 使用整數像素高度，避免捲動停止時出現半格錯位
    _itemHeight = min(reelSize * 0.3, 80).floorToDouble().clamp(1.0, double.infinity);

    final double maxPopupHeight = MediaQuery.of(context).size.height * 0.6;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxPopupHeight),
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
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 36),
                    child: Text(
                      '抽取專屬禮物主題',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlotMachineDisplay(
                    reelSize: reelSize,
                    itemHeight: _itemHeight,
                    scrollController: _scrollController,
                    themes: _controller.themes,
                  ),
                  const SizedBox(height: 30),
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          label: Text(
                            _isSpinning ? '轉動中...' : '開始抽籤！',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _showLatestThemeDialog,
                          icon: const Icon(Icons.info_outline),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow.shade700,
                            foregroundColor: Colors.red.shade900,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                          ),
                          label: const Text(
                            "目前主題",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      ),
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
  }
}
