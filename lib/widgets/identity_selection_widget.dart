import 'package:flutter/material.dart';

// 🔴 IdentitySelectionWidget 支援動態參加者名單
class IdentitySelectionWidget extends StatelessWidget {
  final Function(String) onVerified; // 🔴 回傳選擇成功的使用者
  final List<String> participants; // 🔴 從 HomePage 傳入的參加者名單

  const IdentitySelectionWidget({
    super.key,
    required this.onVerified,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    // 🔴 畫面寬度的一半
    final double width = MediaQuery.of(context).size.width * 0.5;

    return Center(
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, // 🔴 白色背景
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '請選擇你的身份',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // 🔴 人像列表 GridView，最多一排三個
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: participants.map((name) {
                // 🔴 預設使用者頭像，如果有對應圖片可改
                final avatarPath = 'assets/images/${name.toLowerCase().replaceAll(' ', '')}.png';
                return GestureDetector(
                  onTap: () {
                    _showCodeDialog(context, name); // 🔴 點擊顯示通行碼 Dialog
                  },
                  child: CircleAvatar(
                    radius: 40, // 🔴 大小
                    backgroundImage: AssetImage(avatarPath),
                    child: Text(
                      name[0].toUpperCase(), // 🔴 若圖片不存在，顯示首字母
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // 🔴 通行碼輸入 Dialog（新增取消/重選功能）
  void _showCodeDialog(BuildContext context, String name) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // 🔴 不可隨意關閉
      builder: (context) {
        return AlertDialog(
          title: Text('輸入通行碼確認 $name'),
          content: TextField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: '通行碼',
            ),
          ),
          actions: [
            // 🔴 新增取消/重選按鈕，回到身份選擇
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 🔴 關閉 Dialog 回到身份選擇
              },
              child: const Text('取消/重選'),
            ),
            // 🔴 確認按鈕
            TextButton(
              onPressed: () {
                // 🔴 假設通行碼統一為 "1234"，Lab.X 可以在開發者設定改動
                if (codeController.text == '1234') {
                  onVerified(name); // 🔴 通過驗證
                  Navigator.of(context).pop(); // 🔴 關閉 Dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('通行碼錯誤')),
                  );
                }
              },
              child: const Text('確認'),
            ),
          ],
        );
      },
    );
  }
}
