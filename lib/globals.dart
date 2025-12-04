library globals;

import '../repositories/database_repository.dart';
import '../models/participant_model.dart';
import '../models/gift_theme_model.dart';
import 'globals.dart' as globals;

int? currentUserNum; // 紀錄目前登入者 numId

/// 全域快取：禮物主題列表，供首頁預先載入、其他頁面共用
List<GiftTheme> globalGiftThemes = [];
bool globalGiftThemesLoaded = false;

/// 在 App 生命週期中預先載入禮物主題（可在 HomePage.initState 呼叫）
Future<void> loadGiftThemesIfNeeded() async {
  if (globalGiftThemesLoaded) return;
  try {
    globalGiftThemes = await DatabaseRepository.getGiftThemes();
    globalGiftThemesLoaded = true;
    print('✅ Global gift themes loaded, count = ${globalGiftThemes.length}');
  } catch (e, st) {
    print('❌ Failed to load global gift themes: $e\n$st');
    // 保持為未載入狀態，下次有需要時可再嘗試
    globalGiftThemesLoaded = false;
  }
}

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


/// 🔹 全域函式：更新 participant 的 location，並取得更新後的值
Future<String?> updateParticipantLocation(int userNum, String location) async {

  // 1️⃣ 執行資料庫更新 (如果失敗，它會拋出錯誤)
  // 保持這個 await 是正確的，它會等待 Supabase/API 執行。
  await DatabaseRepository.updateParticipantLocation(userNum, location);

  // 2️⃣ 延遲（可選，通常不需要，但如果 Supabase 延遲，可以保留）
  await Future.delayed(const Duration(milliseconds: 200));

  // 3️⃣ 取得更新後 participant
  final updatedUser = await globals.getParticipantByNum(userNum);

  // 4️⃣ 核心驗證：確保更新真的發生了
  if (updatedUser == null) {
    // 找不到使用者，可能是 ID 錯誤或資料庫操作問題
    throw Exception("更新地點後找不到使用者 (ID: $userNum)！");
  }

  // ⚠️ 假設 updatedUser 有一個屬性叫做 'location' 或 'branch'
  // 請根據您的實際 participant 物件屬性進行調整
  final actualLocation = updatedUser.location; // <-- 請改成您實際的屬性名

  if (actualLocation == location) {
    // 5️⃣ 成功：返回地點名稱作為成功標誌
    return location;
  } else {
    // 6️⃣ 失敗：資料庫操作雖然沒有拋錯，但資料內容不正確
    throw Exception("資料庫寫入驗證失敗！預期地點: $location，實際地點: $actualLocation");
  }

  // ❌ 移除 try-catch，讓錯誤能拋出到呼叫端 (_submit)
  // 呼叫端 (_submit) 已經有 try-catch 處理，不應該在這裡吞掉錯誤
}