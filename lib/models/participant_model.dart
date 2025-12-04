// lib/models/participant_model.dart

class Participant {
  final int id;
  final int num;
  final int sort; // 排序
  final String fullName; // 參與者全名 (full_name)
  final String verificationCode; // 通行碼 (verification_code)
  final DateTime? loginTime; // 報到時間 (login_time)
  final DateTime createdAt; // 創建時間 (created_at)
  final String? giftAssignedTheme; // 分配到的禮物主題名稱 (gift_assigned_theme)

  // ----------------------------------------
  // 1. 靜態私有共享實例
  // ----------------------------------------
  static Participant? _sharedInstance;

  // ----------------------------------------
  // 2. 公開的命名構造函數 (Instance Constructor)
  // ----------------------------------------
  Participant.instance({
    required this.id,
    required this.num,
    required this.sort,
    required this.fullName,
    required this.verificationCode,
    this.loginTime,
    required this.createdAt,
    this.giftAssignedTheme,
  });

  // ----------------------------------------
  // 3. 靜態共享實例 (Singleton Getter)
  // ----------------------------------------
  static Participant get shared {
    if (_sharedInstance == null) {
      _sharedInstance = Participant.instance(
        id: 0,
        num: 0,
        sort: 0,
        fullName: 'Shared/Default Participant',
        verificationCode: 'N/A',
        loginTime: null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        giftAssignedTheme: null,
      );
    }
    return _sharedInstance!;
  }

  // ----------------------------------------
  // 4. 外部可創建錯誤或預設實例
  // ----------------------------------------
  factory Participant.errorInstance({
    required int id,
    required int num,
    required int sort,
    required String fullName,
    required String verificationCode,
    DateTime? loginTime,
    required DateTime createdAt,
    String? giftAssignedTheme,
  }) {
    return Participant.instance(
      id: id,
      num: num,
      sort: sort,
      fullName: fullName,
      verificationCode: verificationCode,
      loginTime: loginTime,
      createdAt: createdAt,
      giftAssignedTheme: giftAssignedTheme,
    );
  }

  // ----------------------------------------
  // 5. 從 JSON 轉換 (安全解析)
  // ----------------------------------------
  factory Participant.fromJson(Map<String, dynamic> json) {
    try {
      return Participant.instance(
        id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
        num: json['num'] is int ? json['num'] : int.tryParse('${json['num']}') ?? 0,
        sort: json['sort'] is int ? json['sort'] : int.tryParse('${json['sort']}') ?? 0,
        fullName: json['full_name']?.toString() ?? '',
        verificationCode: json['verification_code']?.toString() ?? '',
        loginTime: _parseDateTimeSafe(json['login_time']),
        createdAt: _parseDateTimeSafe(json['created_at']) ?? DateTime.now(),
        giftAssignedTheme: json['gift_assigned_theme']?.toString(),
      );
    } catch (e) {
      // 解析失敗時返回 shared instance
      print('Error parsing Participant: $e');
      return Participant.shared;
    }
  }

  // ----------------------------------------
  // 6. 轉換為 JSON
  // ----------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'num': num,
      'sort': sort,
      'full_name': fullName,
      'verification_code': verificationCode,
      'login_time': loginTime?.toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'gift_assigned_theme': giftAssignedTheme,
    };
  }

  // ----------------------------------------
  // 7. 安全解析 DateTime
  // ----------------------------------------
  static DateTime? _parseDateTimeSafe(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
