import 'package:flutter/material.dart';
import 'dart:math';

import '../models/gift_theme_model.dart';
import '../repositories/database_repository.dart';
import '../globals.dart' as globals;
import '../models/participant_model.dart';

// -----------------------------------------------------------------------------
// 🔹 SlotMachineController (模組化控制邏輯)
// -----------------------------------------------------------------------------
class SlotMachineController {
  final Random _random = Random();
  List<GiftTheme> themes = [];
  String? lastAssignedThemeName;

  /// 初始化：載入主題列表 + 上一次抽到的主題
  Future<void> initialize() async {

    print('我進來了');

    try {
      themes = await DatabaseRepository.getGiftThemes();
      print('Loaded gift themes: ${themes.length}');  // 🔴
    } catch (e, st) {
      print('Error loading gift themes: $e\n$st');  // 🔴
    }


    // 🔴 新增檢查是否有取得資料
    print('Loaded gift themes: ${themes.length}');
    for (var t in themes) {
      print('Theme: id=${t.id}, name=${t.name}, code=${t.code}');
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

  /// 隨機取得最終索引
  int getRandomIndex() {
    if (themes.isEmpty) return 0;
    return _random.nextInt(themes.length);
  }

  /// 更新使用者最後抽到的主題
  Future<void> updateUserAssignedTheme(int index) async {
    if (globals.currentUserNum == null || themes.isEmpty) return;
    final theme = themes[index];
    await DatabaseRepository.updateGiftAssignedTheme(
        globals.currentUserNum!, theme.code);
    lastAssignedThemeName = theme.name;
  }
}

// -----------------------------------------------------------------------------
// 🔹 SlotMachineDisplay (UI顯示元件)
// -----------------------------------------------------------------------------
class SlotMachineDisplay extends StatelessWidget {
  final double reelSize;
  final double itemHeight;
  final ScrollController scrollController;
  final List<GiftTheme> themes;
  final bool isSpinning;

  const SlotMachineDisplay({
    super.key,
    required this.reelSize,
    required this.itemHeight,
    required this.scrollController,
    required this.themes,
    required this.isSpinning,
  });

  @override
  Widget build(BuildContext context) {
    if (themes.isEmpty) return const SizedBox.shrink();

    Widget _buildItem(BuildContext context, int i) {
      final theme = themes[i % themes.length];
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
          controller: scrollController,
          itemExtent: itemHeight,
          physics: isSpinning
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          itemCount: 999999999,
          itemBuilder: _buildItem,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🔹 SlotMachineWidget (主 Widget)
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

    const spinDurationSeconds = 3.5;
    const fullReels = 50;

    final int themeCount = _controller.themes.length;
    final int finalResult = _controller.getRandomIndex();

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

    await _controller.updateUserAssignedTheme(_currentSlotIndex);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = min(screenWidth * 0.9, 450.0);
    final double reelSize = maxWidth - 48;
    final double itemHeight = reelSize * 0.4;

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
                      '禮物主題拉霸機',
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
                    itemHeight: itemHeight,
                    scrollController: _scrollController,
                    themes: _controller.themes,
                    isSpinning: _isSpinning,
                  ),
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
                  if (_controller.lastAssignedThemeName != null)
                    Text(
                      '上一次抽到的禮物主題：${_controller.lastAssignedThemeName}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
  }
}
