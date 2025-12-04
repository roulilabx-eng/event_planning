import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals.dart' as globals; // ⚠️ 請確保這個路徑正確且包含了 currentUserNum

// ============================================================
// 外部依賴定義
// ============================================================

/// 地點選擇結果
class LocationResult {
  final String branchName;
  const LocationResult(this.branchName);
}

// 實作外部連結開啟功能，使用 url_launcher
Future<void> _launchMap(String url) async {
  final Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint('無法開啟地圖連結：$url');
  }
}

// ============================================================
// 地點選擇 Dialog
// ============================================================

class LocationDialog extends StatefulWidget {
  const LocationDialog({super.key});

  @override
  State<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  // 0: 未選擇, 1: 慶城, 2: 大遠百
  int _selectedIndex = 0;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    // 1. 檢查地點選擇
    if (_selectedIndex == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('錯誤：請先選擇地點')),
        );
      }
      return;
    }

    // 2. ⚠️ 核心檢查：讀取全局變數
    if (globals.currentUserNum == null) {
      debugPrint('🚨 錯誤：globals.currentUserNum 為 null，中止提交。');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('錯誤：尚未登入或身份驗證，無法儲存地點！')),
        );
      }
      return;
    }

    final String branchName = _selectedIndex == 1 ? '慶城店' : '大遠百店';
    // 🎯 直接使用全局變數的值
    final int userNum = globals.currentUserNum!;

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    debugPrint('----------------------------------------------------');
    debugPrint('➡️ 嘗試提交：User ID $userNum，選擇地點：$branchName');
    // 這一行現在會正確印出 993109，如果您的全局變數有正確賦值的話
    debugPrint('----------------------------------------------------');

    try {
      // 3. 核心寫入操作 (使用您 globals.dart 中的函式)
      // 由於您在 Supabase 邏輯中可能沒有提供驗證函式，我們直接使用 updateParticipantLocation
      // 確保您的 updateParticipantLocation 內部**會拋出錯誤**如果寫入失敗。
      await globals.updateParticipantLocation(userNum, branchName);

      debugPrint('✅ 寫入資料表成功！');

      // 4. 成功處理
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('地點 "$branchName" 儲存成功！'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(LocationResult(branchName));

    } catch (e, stackTrace) {
      // 5. 失敗處理 (如果 updateParticipantLocation 內部有錯誤，會在這裡被捕獲)
      debugPrint('❌ 寫入資料表失敗！原始錯誤: $e');
      debugPrint('Stack Trace: $stackTrace');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('儲存地點失敗: ${e.toString().split(':')[0]}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      // 6. 退出提交狀態
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// 單一卡片：顯示一個地點選項 (佈局穩定版本)
  Widget _buildLocationCard({
    required int index,
    required String branchName,
    required String description,
    required String mapUrl,
    required String imagePath,
    required String time,
    required double cardWidth,
  }) {
    final bool isSelected = _selectedIndex == index;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.red.shade600 : Colors.grey.shade400,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '分店：$branchName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: () => _launchMap(mapUrl),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: Text(
                                '載入失敗: $imagePath',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                              ),
                            );
                          },
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                            ),
                          ),
                          child: const Text(
                            '點擊圖片開啟地圖',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '時間：$time',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '行程：$description',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.red.shade500 : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSelected ? '已選中' : '點擊選擇',
                    style: TextStyle(
                      color: isSelected ? Colors.red.shade500 : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.location_on, color: Colors.red.shade400, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 響應式佈局 (RWD) 邏輯
    final screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth < 600
        ? screenWidth * 0.9
        : screenWidth * 0.7;

    final double constrainedWidth = dialogWidth > 300
        ? (dialogWidth < 800 ? dialogWidth : 800)
        : 300;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          width: constrainedWidth,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade400, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 標題列 + 關閉按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '請選擇地點(慶城/大遠百)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // 兩個地點選擇卡片 (RWD 佈局)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double parentWidth = constraints.maxWidth;
                    final isNarrow = parentWidth < 600;

                    final double cardWidth = isNarrow
                        ? parentWidth
                        : (parentWidth - 12) / 2;

                    final locationCards = [
                      // 慶城店選項
                      _buildLocationCard(
                        index: 1,
                        branchName: '慶城店',
                        description: ' 吃飽飽  ⮕ 回家睡覺 ',
                        mapUrl: 'https://maps.app.goo.gl/NBrj9VHk6ff8n4bN7',
                        imagePath: 'assets/images/location_2.jpg',
                        time: '20 : 00',
                        cardWidth: cardWidth,
                      ),
                      SizedBox(width: isNarrow ? 0 : 12, height: isNarrow ? 12 : 0),

                      // 大遠百店選項
                      _buildLocationCard(
                        index: 2,
                        branchName: '大遠百店',
                        description: ' 吃飽飽  ⮕ 聖誕樹 ',
                        mapUrl: 'https://maps.app.goo.gl/yFSgcjjpFgveY4m8A',
                        imagePath: 'assets/images/location_1.jpg',
                        time: '19 : 30',
                        cardWidth: cardWidth,
                      ),
                    ];

                    return isNarrow
                        ? Column(children: locationCards)
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: locationCards,
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 送出按鈕
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      '送出',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}