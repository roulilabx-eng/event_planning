library globals;

import '../repositories/database_repository.dart';
import '../models/participant_model.dart';
import 'globals.dart' as globals;

int? currentUserNum; // 紀錄目前登入者 numId

/// 使用 num 取得 Participant
Future<Participant?> getParticipantByNum(int num) async {
  try {
    final participants = await DatabaseRepository.getParticipants();
    for (var p in participants) {
      if (p.num == num) return p;
    }
    return null; // 找不到時回傳 null
  } catch (_) {
    return null;
  }
}


/// 🔹 全域函式：更新 participant 的 gift_assigned_theme，並取得更新後的值
Future<String?> updateParticipantAssignedTheme(int userNum, String themeCode) async {
  try {
    // 1️⃣ 更新資料庫
    await DatabaseRepository.updateGiftAssignedTheme(userNum, themeCode);

    // 2️⃣ 稍微延遲，確保資料庫或 Supabase 完成更新
    await Future.delayed(const Duration(milliseconds: 200));

    // 3️⃣ 取得更新後 participant
    final updatedUser = await globals.getParticipantByNum(userNum);

    // 4️⃣ debug：確認更新結果
    print('After update, participant giftAssignedTheme = ${updatedUser?.giftAssignedTheme}');

    // 5️⃣ 回傳最新 giftAssignedTheme
    return updatedUser?.giftAssignedTheme;
  } catch (e, st) {
    print('Error updating participant assigned theme: $e\n$st');
    return null;
  }
}
