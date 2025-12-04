import 'package:flutter/material.dart';
import 'dart:math';
import '../repositories/database_repository.dart';
import '../models/participant_model.dart';
import '../globals.dart' as globals;
import '../audio_service.dart'; // 🔴 導入 GlobalAudioService

// ====================================================================
// 🔴 IdentitySelectionWidget (身份選擇器)
// - Avatar 顯示依照 participant.num 對應圖片名稱
// - 支援 png/jpg/jpeg fallback，不存在則顯示預設圖片
// - RWD + 可滾動 + 無雙黃線輸入框
// - 通行碼驗證對應 participant.verification_code
// - 通行碼 Dialog 可透過右上 X 關閉
// - UI 調整：黃色邊框紅底，X icon 圓形紅色帶陰影
// ====================================================================
class IdentitySelectionWidget extends StatefulWidget {
  final Function(String) onVerified;

  const IdentitySelectionWidget({super.key, required this.onVerified});

  @override
  State<IdentitySelectionWidget> createState() => _IdentitySelectionWidgetState();
}

class _IdentitySelectionWidgetState extends State<IdentitySelectionWidget> {
  List<Participant> participants = [];

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  // ===============================================================
  // 🔹 1️⃣ 從資料庫取得參加者
  // ===============================================================
  Future<void> _loadParticipants() async {
    try {
      final fetchedParticipants = await DatabaseRepository.getParticipants();
      if (!mounted) return;
      setState(() {
        participants = fetchedParticipants;
      });
      debugPrint('Fetched ${participants.length} participants.');
    } catch (e) {
      debugPrint('Error fetching participants: $e');
    }
  }

  // ===============================================================
  // 🔹 2️⃣ 取得 participant 對應的圖片路徑 (同步判斷，避免 web 上 bundle 載入問題)
  // ===============================================================
  String _getAvatarImagePath(int num) {
    // 這些 num 對應的 jpg 檔已在 pubspec.yaml 中註冊
    const availableNums = <int>{
      993106,
      993109,
      993120,
      993128,
      993135,
      999999,
      999998,
      999997,
      999996,
    };

    if (availableNums.contains(num)) {
      return 'assets/images/people/$num.jpg';
    }

    // 其他未對應到的 num 一律使用預設頭像
    return 'assets/images/people/default.jpg';
  }

  // ===============================================================
  // 🔹 3️⃣ 建立單個 Avatar
  // ===============================================================
  Widget _buildAvatar(Participant participant, double radius) {
    final imagePath = _getAvatarImagePath(participant.num);
    return GestureDetector(
      onTap: () => _showCodeDialog(context, participant),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: AssetImage(imagePath),
      ),
    );
  }

  // ===============================================================
  // 🔹 4️⃣ 建立 GridView
  // ===============================================================
  Widget _buildParticipantsGrid(double contentWidth, double spacing) {
    const crossAxisCount = 3;
    final avatarSize = (contentWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
    final avatarRadius = avatarSize / 2;

    return participants.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        return _buildAvatar(participants[index], avatarRadius);
      },
    );
  }

  // ===============================================================
  // 🔹 5️⃣ 顯示通行碼 Dialog (黃色框線紅底 + 圓形紅 X icon)
  // ===============================================================
  void _showCodeDialog(BuildContext context, Participant participant) {
    final codeController = TextEditingController();

    Future<void> handleSubmission(String passcode) async {
      if (passcode == participant.verificationCode) {

        // ✅ 登入成功，記錄 num
        globals.currentUserNum = participant.num;

        // 🔴 播放背景音樂 (解決 Web Autoplay 限制)
        GlobalAudioService().startMusic();

        // ✅ 寫入登入時間到資料表
        try {
          await DatabaseRepository.updateParticipantLoginTime(
            participant.num,
            DateTime.now(),
          );
        } catch (_) {
          // 若寫入失敗，不阻擋使用流程，只在 console 記錄
        }

        Navigator.of(context).pop();
        widget.onVerified(participant.fullName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('通行碼錯誤', textAlign: TextAlign.center),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth < 600 ? screenWidth * 0.85 : screenWidth * 0.5;

        return AlertDialog(
          backgroundColor: Colors.teal.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.yellow, width: 4),
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '請輸入通行碼',
                style: TextStyle(color: Colors.white),
              ),
              Material(
                elevation: 4,
                shape: const CircleBorder(),
                color: Colors.red.shade700,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              onSubmitted: (value) => handleSubmission(value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '請輸入',
                hintStyle: TextStyle(color: Colors.white70),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.yellow),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.yellow),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.red.shade900,
              ),
              onPressed: () => handleSubmission(codeController.text),
              child: const Text('確認'),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // 🔹 6️⃣ 主 build (RWD + 可滾動 + 文字自動縮放)
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final dialogWidth = screenWidth < 600 ? screenWidth * 0.85 : screenWidth * 0.66;
    final outerPadding = max(dialogWidth * 0.04, 16.0);
    final gridSpacing = max(dialogWidth * 0.025, 10.0);
    final contentWidth = dialogWidth - 2 * outerPadding;
    final maxDialogHeight = screenHeight * 0.8;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        child: Container(
          width: dialogWidth,
          padding: EdgeInsets.all(outerPadding),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.yellow, width: 4),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 文字自動縮放保持一行
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Who Who Who',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: outerPadding),
                _buildParticipantsGrid(contentWidth, gridSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}