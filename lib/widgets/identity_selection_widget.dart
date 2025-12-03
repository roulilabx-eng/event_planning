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
        // 🔴 根據使用者要求：暫時註解掉彈出通行碼 Dialog 的功能，只保留顯示畫面。
        // _showCodeDialog(context, name);
        debugPrint('Avatar tapped: $name (Functionality is currently disabled.)');
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
/*
  void _showCodeDialog(BuildContext context, String name) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // 🔴 不可隨意關閉
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            '輸入通行碼確認 $name',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '通行碼',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            // 🔴 新增取消/重選按鈕，回到身份選擇
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 🔴 關閉 Dialog 回到身份選擇
              },
              child: const Text('取消/重選', style: TextStyle(color: Colors.grey)),
            ),
            // 🔴 確認按鈕
            TextButton(
              onPressed: () {
                // 🔴 假設通行碼統一為 "1234"
                if (codeController.text == '1234') {
                  // 必須先關閉身份選擇 Dialog (IdentitySelectionWidget 外層的)
                  Navigator.of(context).pop();

                  onVerified(name); // 🔴 通過驗證並回傳名稱
                } else {
                  // 這裡暫時使用 SnackBar，假設外層有 Scaffold
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('通行碼錯誤', textAlign: TextAlign.center),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('確認', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            ),
          ],
        );
      },
    );
  }
  */
}