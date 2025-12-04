// lib/models/gift_theme_model.dart

// ====================================================================
// 🎁 禮物主題模型 (GiftTheme Model) - 實作 Singleton 模式
//
// 使用方式:
// 1. 存取單例實例 (包含預設資料): GiftTheme.shared
// 2. 外部直接創建實例: GiftTheme.instance(...) <-- 已公開
// 3. 從 JSON 建立新實例: GiftTheme.fromJson(map)
// 4. 從外部創建特殊實例 (如錯誤): GiftTheme.errorInstance(...)
// ====================================================================
class GiftTheme {
  final int id;
  final String name; // 主題名稱 (name)
  final String code; // 禮物編號/主題代碼 (code)
  final bool isActive; // 是否啟用 (is_active)
  final DateTime createdAt; // 創建時間 (created_at)

  // 1. 靜態私有實例變數
  static GiftTheme? _sharedInstance;

  // 2. 公開的命名構造函數 (Instance Constructor)
  // 這是實際創建實例的唯一途徑，現在外部也可以直接使用。
  GiftTheme.instance({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    required this.createdAt,
  });

  // 3. 靜態共享實例 (Singleton Getter)
  // 外部通過 GiftTheme.shared 存取唯一的實例。
  static GiftTheme get shared {
    // 延遲初始化：如果實例不存在，則創建一個預設實例。
    if (_sharedInstance == null) {
      _sharedInstance = GiftTheme.instance( // <-- 使用公開構造函數
        id: 0,
        name: 'Shared/Default Theme',
        code: 'SHARED_DEF',
        isActive: false,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }
    return _sharedInstance!;
  }


  // ----------------------------------------------------
  // 新增工廠方法：用於外部創建特殊的錯誤或預設實例
  // ----------------------------------------------------
  factory GiftTheme.errorInstance({
    required int id,
    required String name,
    required String code,
    required bool isActive,
    required DateTime createdAt,
  }) {
    // 呼叫公開的 instance 構造函數來創建實例
    return GiftTheme.instance( // <-- 使用公開構造函數
      id: id,
      name: name,
      code: code,
      isActive: isActive,
      createdAt: createdAt,
    );
  }



  // ----------------------------------------------------
  // 從 JSON 轉換 (工廠方法，用於數據解析)
  // ----------------------------------------------------
  factory GiftTheme.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['theme_name'] == null || json['code'] == null) {
      // 如果數據不完整，可以返回 shared 實例或拋出錯誤
      throw const FormatException("GiftTheme data missing required fields (id, name, code, or created_at).");
    }

    // 透過公開的 instance 構造函數創建一個新的、帶有實際數據的實例
    return GiftTheme.instance( // <-- 使用公開構造函數
      // 確保 id 轉換為 int
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int),
      name: json['theme_name'] as String,
      // 主題代碼 code
      code: json['code'] as String,
      isActive: (json['is_active'] ?? false) as bool,
      // 解析 Supabase 傳來的 ISO 8601 時間字串
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }



  // ----------------------------------------------------
  // 轉換為 Map
  // ----------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theme_name': name, // 資料庫欄位名稱 theme_name
      'code': code,
      'is_active': isActive,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}