import 'package:flutter/material.dart';
import 'dart:math';
import '../globals.dart' as globals;
// 🎯 引入正確的 Participant 模型
import '../models/participant_model.dart';
// 🎯 新增: 引入 GiftTheme 模型，以便處理全域列表
import '../models/gift_theme_model.dart';

// ====================================================================
// 🎁 抽籤視窗主體 (已轉換為 StatefulWidget)
// ====================================================================
class LuckyDrawWidget extends StatefulWidget {
  const LuckyDrawWidget({super.key});

  @override
  State<LuckyDrawWidget> createState() => _LuckyDrawWidgetState();
}

class _LuckyDrawWidgetState extends State<LuckyDrawWidget> {
  // 🎯 抽獎項目列表 (使用全域啟用的主題名稱)
  List<String> _items = [];

  // 狀態變數
  bool _isDrawing = false;
  String _currentResult = '按下 START 抽取主題'; // 初始顯示文字

  @override
  void initState() {
    super.initState();

    // 🎯 核心變更: 從全域列表載入並過濾主題
    // 篩選出 is_active 為 true 的主題，並轉換為主題名稱 (name) 列表
    _items = globals.globalGiftThemes
        .where((theme) => theme.isActive)
        .map((theme) => theme.name)
        .toList();

    // 根據主題列表是否為空來設定初始顯示文字
    if (_items.isEmpty) {
      if (globals.globalGiftThemesLoaded) {
        _currentResult = '❌ 找不到任何已啟用的主題';
      } else {
        _currentResult = '⚠️ 主題資料尚未載入';
      }
    } else {
      // 初始顯示第一個項目
      _currentResult = _items[0];
    }
  }

  // ----------------------------------------------------
  // 核心邏輯: 開始抽獎 (已加入資料儲存邏輯)
  // ----------------------------------------------------
  void _startDraw() async {
    // 檢查是否有可用主題或是否正在抽獎
    if (_isDrawing || _items.isEmpty) return;

    setState(() {
      _isDrawing = true;
    });

    // 1. 預先決定最終結果
    final random = Random();
    final resultIndex = random.nextInt(_items.length);
    final String finalResult = _items[resultIndex]; // 主題名稱 (Name)

    // 2. 規劃滾動步驟和變速邏輯 (略)
    const int totalSpins = 60;
    const int fastDelay = 50;

    for (int i = 0; i < totalSpins; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: fastDelay));

      // 3. 滾動邏輯
      setState(() {
        if (i < totalSpins - 1) {
          _currentResult = _items[(i + 1) % _items.length];
        } else {
          _currentResult = finalResult;
        }
      });
    }

    // 4. 完成動畫與 UI 更新
    if (!mounted) return;
    setState(() {
      _isDrawing = false;
      _currentResult = finalResult; // 確保最後狀態是最終結果
    });

    // 🎯 核心變更: 加入資料庫儲存邏輯
    final int? userNum = globals.currentUserNum;
    if (userNum == null) {
      _showResultDialog(context, '錯誤', '找不到登入者資訊，無法儲存結果。');
      return;
    }

    // 1. 查找對應的 GiftTheme 物件以取得 code
    final List<GiftTheme> matchedThemes = globals.globalGiftThemes
        .where((theme) => theme.name == finalResult)
        .toList();

    final String themeCode = matchedThemes.isNotEmpty ? matchedThemes.first.code : '';

    if (themeCode.isEmpty) {
      _showResultDialog(context, '錯誤', '找不到對應的主題代碼，無法儲存結果。');
      return;
    }

    // 4. 呼叫全域更新函數
    try {
      // 假設 updateParticipantAssignedTheme 返回 Future<bool>
      final success = await globals.updateParticipantAssignedTheme(userNum, themeCode);

      if (success != null) {
        // 成功後顯示結果
        _showResultDialog(context, '🎉 你的專屬主題 🎉', '$finalResult');
      } else {
        // 更新失敗 (可能因為資料庫操作失敗或主題已被分配過)
        _showResultDialog(context, '失敗', '請重新再試一次。');
      }
    } catch (e) {
      // 資料庫操作異常
      _showResultDialog(context, '資料庫錯誤', '儲存結果時發生異常: $e');
    }
  }

  // ----------------------------------------------------
  // 模組 1: 視窗頭部 (標題) - 置中顯示
  // ----------------------------------------------------
  Widget _buildTitle() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Text(
          '🎰 幸運主題 🎰', // 標題文字
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
  // 模組 4: 顯示結果彈窗 (通用彈窗)
  // ----------------------------------------------------
  void _showResultDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.red.shade700, width: 4),
          ),
          title: Center(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          content: Text(
            content,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.red.shade900),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 4,
              ),
              child: const Text('我知道了', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // 🎯 檢查禮物分配狀態並顯示彈窗 (已新增主題名稱轉換邏輯)
  // ----------------------------------------------------
  void _checkGiftStatus(BuildContext context) async {
    String content = '目前沒有任何紀錄';
    String title = '🎉 你的專屬主題 🎉';

    // 1. 取得目前登入者的 numId
    final int? userNum = globals.currentUserNum;

    if (userNum != null) {
      // 2. 透過 num 取得參與者資料
      try {
        final Participant? participant = await globals.getParticipantByNum(userNum);

        // 3. 取得分配到的主題代碼
        final String? themeCode = participant?.giftAssignedTheme;

        if (themeCode != null && themeCode.isNotEmpty) {
          title = '🎉 你的專屬主題 🎉';

          // 🎯 核心邏輯: 查找全域主題列表，將代碼轉換為名稱
          // 假設 GiftTheme 類別有 'code' (用於比對) 和 'name' (用於顯示) 屬性
          final List<GiftTheme> matchedThemes = globals.globalGiftThemes
              .where((theme) => theme.code == themeCode)
              .toList();

          if (matchedThemes.isNotEmpty) {
            // 找到了，顯示主題名稱
            content = matchedThemes.first.name;
          } else {
            // 找不到對應的主題資料，顯示代碼並提示
            content = '主題代碼：$themeCode (未在全域列表中找到對應名稱)';
          }

        }
      } catch (e) {
        // 處理資料庫或其他錯誤
        content = '查詢資料時發生錯誤';
        // 實際應用中應記錄錯誤：print('Error fetching gift status: $e');
      }
    }

    // 4. 顯示彈窗
    _showResultDialog(context, title, content);
  }


  // ----------------------------------------------------
  // 模組 3: 底部動作區 (START 按鈕 + 結果按鈕)
  // ----------------------------------------------------
  Widget _buildAction(BuildContext context) {
    // START Button
    final startButton = ElevatedButton(
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
        _isDrawing ? '.ing...' : 'ＳＴＡＲＴ',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );

    // Result Button (新增)
    final resultButton = Container(
      margin: const EdgeInsets.only(left: 15.0), // 留出與 START 按鈕的間距
      child: ElevatedButton(
        // 抽獎中時禁用按鈕
        // 🎯 修改: 點擊時呼叫 _checkGiftStatus
        onPressed: _isDrawing ? null : () => _checkGiftStatus(context),
        style: ElevatedButton.styleFrom(
          // 🎯 圓形設定
          shape: const CircleBorder(
            side: BorderSide(color: Colors.red, width: 3.0), // 紅色框線
          ),
          padding: const EdgeInsets.all(15),
          backgroundColor: Colors.yellow.shade200, // 黃色底色
          elevation: 6,
          shadowColor: Colors.black54,
          foregroundColor: Colors.black, // 確保文字/圖標顏色可見
        ),
        child: const Text(
          '🎁',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );

    // 使用 Row 讓兩個按鈕並排，並使用 MainAxisSize.min 確保 Row 寬度只包含按鈕，這樣 Center 才能正確置中按鈕組
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        startButton,
        resultButton,
      ],
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

                    // 🎯 2. 拉霸機 UI 模組
                    _buildSlotMachine(),

                    // 3. 動作按鈕區塊 (居中顯示)
                    Center(child: _buildAction(context)), // 傳入 context 以便顯示彈窗
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