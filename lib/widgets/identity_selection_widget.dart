import 'package:flutter/material.dart';
import 'dart:math';

// ====================================================================
// 🔴 IdentitySelectionWidget (身份選擇器)
// 負責在頁面加載時彈出，要求使用者從列表中選擇身份並輸入通行碼。
// ====================================================================

// 🔴 頂層尺寸常數已移除，改為在 build 函式中動態計算。

class IdentitySelectionWidget extends StatelessWidget {

  // 🔴 內部定義的參加者名單 (靜態常數)
  // 此列表即為動態數據源，增減人員只需修改此處。

  static const List<String> defaultParticipants = [
    '小黑人', '小明', '小華', '阿土伯', 'Tina', 'David', 'Chris', 'Eva', 'Frank'];// 增加幾個人確保 GridView 測試

  final Function(String) onVerified; // 🔴 回傳選擇成功的使用者

  const IdentitySelectionWidget({
    super.key,
    required this.onVerified,
  });

  // 輔助函式：建立單個頭像 (使用動態半徑)
  Widget _buildAvatar(BuildContext context, String name, String avatarPath, double radius) {
    return GestureDetector(
      onTap: () {
        // 🔴 根據使用者要求：重新開啟彈出通行碼 Dialog 的功能。
        _showCodeDialog(context, name);
        // debugPrint('Avatar tapped: $name (Functionality is currently disabled.)');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: radius, // 🔴 使用動態半徑
            backgroundColor: Colors.grey.shade300,
            // 🔴 依據使用者要求：不顯示圖片 (backgroundImage 設為 null) 且不顯示文字佔位 (child 設為 null)，僅保留圓形框 (backgroundColor)。
            backgroundImage: null,
            child: null,
          ),
          // 🔴 根據要求，已移除下方的 SizedBox(height: 4) 和 Text(name)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // 1. 🔴 根據螢幕寬度動態調整 Dialog 寬度 (RWD 核心)。
    // 如果螢幕寬度小於 600（手機），寬度佔 85%；否則佔 2/3 (66%)。
    final double dialogWidth = screenWidth < 600.0
        ? screenWidth * 0.85
        : screenWidth * 0.66;

    // 最大高度：裝置高度的 2/3 (保持不變，用於限制視窗不過大)
    final double maxDialogHeight = screenHeight * 0.66;

    // 2. 🔴 優化自適應尺寸計算 (RWD 比例優化)

    // 🔴 統一外邊界 (Outer Padding)：設為 Dialog 寬度的 4%，最小 16.0
    const double minOuterPaddingValue = 16.0;
    final double baseOuterPadding = dialogWidth * 0.04;
    final double dynamicOuterPadding = max(baseOuterPadding, minOuterPaddingValue);

    // 🔴 Grid 內間距 (Grid Spacing)：設為 Dialog 寬度的 2.5%，最小 10.0 (比外邊界略小)
    const double minGridSpacingValue = 10.0;
    final double baseGridSpacing = dialogWidth * 0.025;
    final double dynamicSpacing = max(baseGridSpacing, minGridSpacingValue);

    // 內容可用寬度 = 總寬度 - 左右邊界 padding * 2
    final double contentWidth = dialogWidth - (dynamicOuterPadding * 2);

    // 項目寬度 (AvatarSize) = (內容可用寬度 - 2 * Grid 間距) / 3
    final double dynamicAvatarSize = (contentWidth - 2 * dynamicSpacing) / 3;
    final double dynamicAvatarRadius = dynamicAvatarSize / 2;

    // 3. 計算 GridView 所需的**實際**高度 (確保自適應高度)
    final int numParticipants = defaultParticipants.length;
    final int numRows = (numParticipants / 3).ceil();

    // 🔴 項目高度：設為等於頭像直徑以維持 1:1 比例
    final double dynamicItemHeight = dynamicAvatarSize;

    // GridView 總高度 = 總行數 * 項目高度 + (行數-1) * 主軸間距 + 1.0 緩衝
    final double gridHeight = numRows * dynamicItemHeight + max(0, numRows - 1) * dynamicSpacing + 1.0;

    // 4. 主要佈局
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight, // 🔴 限制整個視窗最大高度
        ),
        child: Container(
          width: dialogWidth, // 🔴 採用計算後寬度
          // 🔴 間距：這是視窗的白色邊界區域 (Padding)
          padding: EdgeInsets.all(dynamicOuterPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          // 🔴 SingleChildScrollView 實現內容超高時自動滾動
          child: SingleChildScrollView(
            // 🔴 新增 Container 並給予紅底色，標示出「內容區域」（在 padding 內側）
            child: Container(
              color: Colors.red.withOpacity(0.1), // 🔴 內容區域的紅色背景
              // 🔴 Column 使用 mainAxisSize.min 實現「自動計算內容高度」
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // 🔴 固定的單行文字標題
                  Text(
                    '請選擇您的身份',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: dialogWidth * 0.06, // 字體大小隨視窗寬度自適應
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  // 🔴 標題與 Grid 之間的間距 (使用外邊距的一半，保持比例)
                  SizedBox(height: dynamicOuterPadding * 0.5),

                  // 🔴 人像列表 GridView (確保 3 個為一排)
                  SizedBox(
                    height: gridHeight, // 🔴 設定動態計算的高度
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // 避免雙重滾動
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 每排 3 個
                        crossAxisSpacing: dynamicSpacing, // 🔴 使用優化後的動態間距
                        mainAxisSpacing: dynamicSpacing, // 🔴 使用優化後的動態間距
                        childAspectRatio: 1.0, // 確保 1:1 比例
                      ),
                      itemCount: numParticipants,
                      itemBuilder: (context, index) {
                        final name = defaultParticipants[index];
                        final avatarPath = 'assets/images/${name.toLowerCase().replaceAll(' ', '')}.png';

                        return _buildAvatar(context, name, avatarPath, dynamicAvatarRadius);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔴 通行碼輸入 Dialog
  void _showCodeDialog(BuildContext context, String name) {
    final TextEditingController codeController = TextEditingController();

    // 內部處理提交邏輯，以便在 ElevatedButton 和 onSubmitted 中複用
    void handleSubmission(BuildContext dialogContext, String passcode) {
      // 🔴 假設通行碼統一為 "1234"
      if (passcode == '1234') {
        // 必須先關閉 Dialog
        Navigator.of(dialogContext).pop();
        onVerified(name); // 🔴 通過驗證並回傳名稱
      } else {
        // 顯示錯誤訊息 (使用外部 context 才能找到 Scaffold)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('通行碼錯誤', textAlign: TextAlign.center),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    // 🔴 Slot Machine 主題常數
    const Color _slotMachineColor = Color(0xFF5D4037); // 深棕色，模擬遊戲機底色
    const Color _titleTextColor = Colors.yellowAccent; // 亮黃色，模擬遊戲機文字
    const double _outerPadding = 16.0; // 深色背景內的邊距
    const double _contentMargin = 20.0; // 白底框內部的 Padding
    const double _cornerRadius = 12.0; // 圓角半徑

    // 🔴 使用 Dialog 來自訂內容
    showDialog(
      context: context,
      barrierDismissible: false, // 🔴 不可隨意關閉
      builder: (BuildContext dialogContext) {
        return Dialog(
          // 外部 Dialog 設為透明，讓 Stack 內的 Container 決定形狀和顏色
          backgroundColor: Colors.transparent,
          // shape 設為圓角矩形，與內容容器保持一致
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cornerRadius)),
          child: Stack(
            // 允許 X 鈕超出邊界
            clipBehavior: Clip.none,
            children: [
              // 1. 🔴 背景層：模擬 slot_machine_bg (深色主題)
              Container(
                decoration: BoxDecoration(
                  color: _slotMachineColor, // 模擬 slot_machine_bg 的深色底色
                  borderRadius: BorderRadius.circular(_cornerRadius),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5)),
                  ],
                  // 🔴 實際專案中，slot_machine_bg 應在此處使用：
                  // image: const DecorationImage(
                  //   image: AssetImage('assets/slot_machine_bg.png'),
                  //   fit: BoxFit.cover,
                  // ),
                ),
                // 內邊距，為內容區域留空間
                padding: const EdgeInsets.all(_outerPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🔴 頂部標題：位於深色背景上
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: Text(
                        '請輸入通行碼',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: _titleTextColor, // 使用亮色文字
                        ),
                      ),
                    ),

                    // 2. 🔴 內容層：白底框
                    Container(
                      // 內部的 padding 調整間距
                      padding: EdgeInsets.all(_contentMargin),
                      decoration: BoxDecoration(
                        color: Colors.white, // 白底
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 3. TextField + Confirm Button (並排)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: codeController,
                                  keyboardType: TextInputType.number,
                                  // ❌ 移除 obscureText: true, 屬性，實現輸入內容不隱碼
                                  // obscureText: true,
                                  // 🔴 禁用複製貼上功能 (保留此功能)
                                  toolbarOptions: const ToolbarOptions(
                                    copy: false,
                                    cut: false,
                                    paste: false,
                                    selectAll: false,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '請輸入', // 提示
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                                  ),
                                  onSubmitted: (value) => handleSubmission(dialogContext, value),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 🔴 確認按鈕 (放在輸入框右側)
                              SizedBox(
                                height: 56, // 匹配 TextField 高度
                                child: ElevatedButton(
                                  onPressed: () => handleSubmission(dialogContext, codeController.text),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _slotMachineColor, // 按鈕顏色與背景主題色同步
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: const Text('確認', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. 🔴 X Icon (Close button - 位於右上角，在 Dialog 之外)
              Positioned(
                // 使用負邊距讓 X 鈕脫離主體邊框，浮在右上角
                top: -12,
                right: -12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    tooltip: '取消/重選',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}