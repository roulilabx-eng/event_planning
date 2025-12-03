// lib/models/participant_model.dart

// ====================================================================
// 🎁 參與者模型 (Participant Model)
// 對應資料庫中的 public.participants 資料表
// ====================================================================
class Participant {
  final int id;
  final int num;
  final String fullName; // 參與者全名 (full_name)
  final String verificationCode; // 通行碼 (verification_code)
  final bool isPresent; // 是否已報到/在場 (is_present)
  final DateTime? loginTime; // 報到時間 (login_time)
  final DateTime createdAt; // 創建時間 (created_at)

  // 分配到的禮物主題名稱 (gift_assigned_theme) - 可能是 null (如果未中獎)
  final String? giftAssignedTheme;

  const Participant({
    required this.id,
    required this.num,
    required this.fullName,
    required this.verificationCode,
    required this.isPresent,
    required this.loginTime,
    required this.createdAt,
    this.giftAssignedTheme,
  });

  // ----------------------------------------------------
  // 從 Map 轉換 (例如從 Supabase 取得的 JSON 資料)
  // ----------------------------------------------------
  factory Participant.fromMap(Map<String, dynamic> json) {
    // 檢查必填欄位是否存在，如果缺失則拋出 FormatException，這比在初始化中嘗試使用 '?? throw' 更安全。
    if (json['id'] == null || json['full_name'] == null || json['verification_code'] == null) {
      // 在 Dart 的 fromMap/fromJson 中，如果資料缺失，拋出異常是標準做法。
      throw const FormatException("Participant data missing required fields (id, full_name, or verification_code).");
    }


    return Participant(
      id: (json['id'] as int),
      num: (json['num'] as int),
      fullName: json['fullName'] as String,
      verificationCode: json['verificationCode'] as String,
      isPresent: (json['isPresent'] ?? false) as bool,
      loginTime: DateTime.parse(json['loginTime'] as String).toLocal(),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      // 可選欄位：禮物主題
      giftAssignedTheme: json['gift_assigned_theme'] as String?,
    );
  }

  // ----------------------------------------------------
  // 轉換為 Map (例如用於 Supabase 插入或更新)
  // ----------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'num': num,
      'full_name': fullName,
      'verification_code': verificationCode,
      'is_present': isPresent,
      'login_time': loginTime?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'gift_assigned_theme': giftAssignedTheme,
    };
  }
}