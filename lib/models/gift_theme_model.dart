// lib/models/gift_theme_model.dart

// ====================================================================
// 🎁 禮物主題模型 (GiftTheme Model)
// 對應資料庫中的 public.gift_themes 資料表
// ====================================================================
class GiftTheme {
  final int id;
  final String name; // 主題名稱 (name)
  final bool isActive; // 是否啟用 (is_active)
  final DateTime createdAt; // 創建時間 (created_at)

  const GiftTheme({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  // ----------------------------------------------------
  // 從 JSON 轉換 (例如從 Supabase 取得的 Map 資料)
  // ----------------------------------------------------
  factory GiftTheme.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['name'] == null) {
      throw const FormatException("GiftTheme data missing required fields (id or name).");
    }

    return GiftTheme(
      id: (json['id'] as int),
      name: json['name'] as String,
      isActive: (json['is_active'] ?? false) as bool,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  // ----------------------------------------------------
  // 轉換為 Map (例如用於 Supabase 插入或更新)
  // ----------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}