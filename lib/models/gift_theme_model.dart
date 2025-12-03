// lib/models/gift_theme_model.dart

// ====================================================================
// 1. 資料模型：禮物主題 (GiftTheme Model)
// 此模型用於儲存 Supabase 中 'gift_themes' 表格的資料結構。
// ====================================================================
class GiftTheme {
  final String id;
  final String name;
  final String emoji;

  GiftTheme({
    required this.id,
    required this.name,
    required this.emoji,
  });

  // Factory 函式：從 JSON/Map 建立 GiftTheme 物件
  factory GiftTheme.fromJson(Map<String, dynamic> json) {
    return GiftTheme(
      // 確保 id 欄位 (可能是 int8) 被安全地轉換為 String
      id: json['id']?.toString() ?? '',
      name: json['theme_name'] as String,
      // 處理 emoji 欄位可能為空的情況，預設為 '🎁'
      emoji: json['theme_emoji'] as String? ?? '🎁',
    );
  }
}