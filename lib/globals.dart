library globals;

import '../repositories/database_repository.dart';
import '../models/participant_model.dart';

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
