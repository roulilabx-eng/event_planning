import 'package:flutter/material.dart';
import 'dart:math';
// 引入獨立出來的 GiftTheme 模型 🏆
import '../models/gift_theme_model.dart';
// 引入資料庫 Repository
import '../repositories/database_repository.dart';

// ====================================================================
// 🏆 使用資料庫的拉霸機元件 (SlotMachineWidget)
// ====================================================================
class SlotMachineWidget extends StatefulWidget {
  const SlotMachineWidget({super.key});

  @override
  State<SlotMachineWidget> createState() => _SlotMachineWidgetState();
}

class _SlotMachineWidgetState extends State<SlotMachineWidget> {
  // 紀錄資料載入狀態
  late Future<List<GiftTheme>> _themesFuture;
  List<GiftTheme> _themes = [];

  // 拉霸機狀態
  bool _isSpinning = false;
  // 🏆 最終結果的主題索引 🏆
  late int _currentSlotIndex;
  final Random _random = Random();

  // 新增：滾輪控制器 (用於連續滾動動畫)
  late ScrollController _scrollController;
  // 新增：滾輪單一項目高度 (用於精確計算滾動距離)
  double _itemHeight = 0;

  // 使用無參數的 Singleton 模式
  final DatabaseRepository _dbRepo = DatabaseRepository();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // 初始化時開始從資料庫載入主題
    _themesFuture = _dbRepo.getGiftThemes().then((themes) {
      if (themes.isNotEmpty) {
        _themes = themes;
        // 初始狀態：顯示第一個主題
        _currentSlotIndex = 0;
      } else {
        // 如果沒有從 Supabase 取得主題，設定一個預設的錯誤主題
        _themes = [GiftTheme(id: 'err', name: '🚨 載入失敗', emoji: '❌')];
        _currentSlotIndex = 0;
      }

      // 🏆 在主題載入後，如果 _itemHeight 已計算，則設置初始滾動位置 🏆
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _itemHeight > 0) {
          // 初始位置設置在一個較大的偏移量，讓列表看起來是無限的
          _scrollController.jumpTo(_itemHeight * _currentSlotIndex * 1000);
        }
      });
      return _themes;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 模擬拉霸機轉動
  void _spin() async {
    final themeCount = _themes.length;
    // Guard：避免重複轉動、主題列表為空或高度未初始化
    if (_isSpinning || themeCount == 0 || _itemHeight == 0) return;

    setState(() {
      _isSpinning = true;
    });

    const double spinDurationSeconds = 3.5; // 總轉動時間
    const int fullReelsToScroll = 50; // 確保至少滾過 50 個完整的主題循環 (模擬無限)

    // 1. 決定最終結果
    final int finalResult = _random.nextInt(themeCount);

    // 2. 計算目標滾動距離
    final double startOffset = _scrollController.offset;
    final double cycleHeight = _itemHeight * themeCount;
    final double offsetInCurrentCycle = startOffset % cycleHeight;

    // 計算從當前循環位置到目標結果（finalResult）的距離
    // distanceToTarget = 確保滾動的最小距離 + 滾動到最終結果的精確距離
    double distanceToTarget = cycleHeight * fullReelsToScroll;
    distanceToTarget += (_itemHeight * finalResult) - offsetInCurrentCycle;

    // 確保距離是正數
    if (distanceToTarget < 0) {
      distanceToTarget += cycleHeight;
    }

    // 3. 執行動畫
    try {
      await _scrollController.animateTo(
        startOffset + distanceToTarget,
        duration: Duration(milliseconds: (spinDurationSeconds * 1000).toInt()),
        curve: Curves.easeOutQuart, // 使用強烈的減速曲線，模擬拉霸機停止的效果
      );
    } catch (e) {
      // 處理可能因 Widget dispose 導致的錯誤
      debugPrint('Spin animation interrupted: $e');
    }

    // 4. 更新最終狀態
    if (!mounted) return;
    setState(() {
      _isSpinning = false;
      _currentSlotIndex = finalResult;
    });
  }

  // 🏆 新增：單一轉盤的顯示元件 🏆
  Widget _buildSingleReelDisplay(int currentIndex, double reelSize) {
    final int themeCount = _themes.length;
    if (themeCount == 0) return const SizedBox.shrink();

    // 1. 設定單一項目高度 (確保與外部容器高度匹配)
    final double itemHeight = reelSize * 0.4;

    // 傳遞 itemHeight 給 State 變數，用於 _spin() 計算
    if (_itemHeight == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _itemHeight = itemHeight;
            // 首次設定初始滾動位置
            _scrollController.jumpTo(_itemHeight * currentIndex * 1000);
          });
        }
      });
    }

    // 輔助函式: 建立單一滾輪項目
    Widget _buildReelItem(BuildContext context, int index) {
      // 確保索引在主題數量內循環
      final int themeIndex = index % themeCount;
      final String themeName = '${_themes[themeIndex].emoji} ${_themes[themeIndex].name}';

      // 🏆 單一項目視覺塊 🏆
      return Container(
        height: itemHeight,
        color: Colors.white, // 卡片的白色背景
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: const Alignment(0, -0.05), // 微調，讓文字在視覺上稍微置中偏上，解決偏下問題
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            themeName,
            style: TextStyle(
              fontSize: reelSize * 0.1,
              fontWeight: FontWeight.w900,
              color: Colors.red.shade900,
              shadows: const [
                Shadow(color: Colors.yellow, blurRadius: 3)
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 2. 外層容器 - 作為卡片的視覺邊框 (紅色/金色)
    return Container(
      width: reelSize,
      height: itemHeight, // 較寬的矩形
      padding: const EdgeInsets.all(4),

      decoration: BoxDecoration(
        color: Colors.red.shade800, // 深紅色背景
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.yellow.shade700, width: 6), // 邊框加粗
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),

      // 3. 內層滾動區
      child: ClipRRect( // 裁剪，確保滾動動畫不會超出圓角
        borderRadius: BorderRadius.circular(10),
        child: ListView.builder(
          controller: _scrollController,
          // 轉動時禁用手動滾動，停止時允許
          physics: _isSpinning
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemExtent: itemHeight, // 設置項目高度
          // 模擬無限滾動，設置一個非常大的 ItemCount
          itemCount: 999999999,
          reverse: false, // 正常滾動方向（向下滾動）
          itemBuilder: _buildReelItem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🏆 響應式佈局計算：單一轉盤的最大寬度 🏆
    // 外部容器的最大寬度
    final double maxContainerWidth = min(screenWidth * 0.9, 450.0);
    // 容器內部有 24px padding，所以實際可用的顯示區域寬度
    final double reelDisplaySize = maxContainerWidth - 24 * 2;


    // 🏆 使用 FutureBuilder 處理主題載入狀態 🏆
    return FutureBuilder<List<GiftTheme>>(
      future: _themesFuture,
      builder: (context, snapshot) {
        Widget content;
        String titleText = '禮物主題拉霸機';

        // 1. 載入中狀態
        if (snapshot.connectionState != ConnectionState.done) {
          content = const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text('載入禮物主題中...', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          );


          // 2. 載入錯誤或無資料狀態
        } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          titleText = '🚨 載入錯誤 🚨';
          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('無法連線到資料庫或主題列表為空，請檢查網路及 Supabase 配置。', style: TextStyle(color: Colors.yellow.shade300, fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              // 提供一個假的主題列表，以便測試
              _buildSingleReelDisplay(0, reelDisplaySize),
            ],
          );
          // 在錯誤狀態下，禁用按鈕
          _isSpinning = true;

          // 3. 載入成功狀態
        } else {
          // 渲染主內容
          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🏆 拉霸機單一顯示框 🏆
              _buildSingleReelDisplay(_currentSlotIndex, reelDisplaySize),
              const SizedBox(height: 30),

              // 按鈕
              ElevatedButton.icon(
                // 檢查是否在轉動中 (_isSpinning)
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
                    : const Icon(Icons.casino_outlined, size: 24),
                label: Text(
                  _isSpinning ? '轉動中...' : '開始抽籤!',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                  foregroundColor: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          );
          // 在成功載入後，確保按鈕可點擊
          if (mounted && _isSpinning && snapshot.connectionState == ConnectionState.done) {
            _isSpinning = false;
          }
        }

        // 統一的外層佈局
        return Center(
          child: Material(
            type: MaterialType.transparency, // 允許背景透明
            child: Container(
              // 使用計算出的最大寬度，確保響應式
              width: maxContainerWidth,
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
              // ----------------------------------------------------
              // 🏆 使用 Stack 堆疊內容和關閉按鈕 🏆
              // ----------------------------------------------------
              child: Stack(
                // 🎯 修正：設置 Stack 對齊為 topCenter，確保內容居中對齊
                alignment: Alignment.topCenter,
                children: [
                  // 1. 主要內容 Column (將標題向左推以騰出按鈕空間)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 標題 (將標題推離右側)
                      Padding(
                        padding: const EdgeInsets.only(right: 36.0), // 留出空間給按鈕
                        child: Text(
                          titleText,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 內容 (FutureBuilder 渲染的結果)
                      content,
                    ],
                  ),

                  // 2. 關閉按鈕 (Positioned) - 實現半浮效果 (已調整為完美圓形)
                  Positioned(
                    top: 0, // 向上移動，讓它浮出邊框
                    right: 0, // 向右移動
                    child: Container(
                      width: 48.0, // 確保固定寬度，使其成為完美圓形
                      height: 48.0, // 確保固定高度，使其成為完美圓形
                      // 圓形背景和陰影，使其看起來是「半浮」的
                      decoration: BoxDecoration(
                        // 調整為乾淨的白色背景，模擬身分驗證介面的清脆按鈕
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        // 調整圖標顏色為與主題相配的深紅色
                        icon: Icon(Icons.close, color: Colors.red.shade900, size: 28),
                        onPressed: () {
                          // 使用這個 Widget 的 context 退出當前的導航路由（關閉模態視窗/對話框）
                          Navigator.of(context).pop();
                        },
                        tooltip: '關閉提醒視窗',
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