
/*    const String supabaseUrl = 'https://ihpietkzzyueineodphr.supabase.co';
    const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlocGlldGt6enl1ZWluZW9kcGhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjUzMDQsImV4cCI6MjA3ODUwMTMwNH0.gWZvAl7cReHVYIlrqODjik1vBtX3wDbl5fkIz-DSR6U';
*/
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// 🏆 引入獨立出來的 GiftTheme 模型 🏆
import '../models/gift_theme_model.dart';

// ====================================================================
// 2. 資料庫操作層 (DatabaseRepository) - 採用 Singleton 模式
// ====================================================================
class DatabaseRepository {
  // 🏆 靜態單例實例 🏆
  static final DatabaseRepository _instance = DatabaseRepository._internal();
  // Factory 構造函數，確保始終返回相同的實例
  factory DatabaseRepository() => _instance;

  // 私有構造函數 (確保外部不能直接 new DatabaseRepository())
  DatabaseRepository._internal();

  // 取得已初始化的 Supabase 客戶端
  SupabaseClient get _client => Supabase.instance.client;

  // ----------------------------------------------------
  // 應用程式初始化
  // ----------------------------------------------------

  /// 初始化 Supabase 連線。此方法應在應用程式啟動時呼叫一次。
  static Future<void> initializeSupabase() async {
    // 🔴 警告：請將這些 PLACEHOLDER 值替換為您實際的 Supabase URL 和 Anon Key！
    // 這是連接到您後端服務的關鍵。
    const String supabaseUrl = 'https://ihpietkzzyueineodphr.supabase.co';
    const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlocGlldGt6enl1ZWluZW9kcGhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjUzMDQsImV4cCI6MjA3ODUwMTMwNH0.gWZvAl7cReHVYIlrqODjik1vBtX3wDbl5fkIz-DSR6U';

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      // 檢查是否仍在使用預留符號
      print('🔴 Supabase 初始化失敗：請在 DatabaseRepository 中填入實際的 URL 和 Key。');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print('✅ Supabase 初始化成功！');
    } catch (e) {
      print('🚨 Supabase 初始化過程中發生錯誤: $e');
    }
  }

  // ----------------------------------------------------
  // 禮物主題相關操作
  // ----------------------------------------------------

  /// 獲取所有啟用的禮物主題列表
  Future<List<GiftTheme>> getGiftThemes() async {
    try {
      // 查詢 public.gift_themes 表格
      // 篩選條件：is_active 必須為 true
      // 排序：按 created_at 升序排列
      final response = await _client
          .from('gift_themes')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: true);

      // 將 List<Map> 轉換為 List<GiftTheme> 物件
      final List<GiftTheme> themes = (response as List)
          .map((json) => GiftTheme.fromJson(json as Map<String, dynamic>))
          .toList();

      print('✅ 成功獲取 ${themes.length} 個禮物主題。');
      return themes;
    } on PostgrestException catch (e) {
      print('🚨 獲取禮物主題時發生 Postgrest 錯誤 (可能是表名或欄位錯誤): ${e.message}');
      return [];
    } catch (e) {
      print('🚨 獲取禮物主題失敗: $e');
      return [];
    }
  }

// ----------------------------------------------------
// 參與者資訊相關操作 (待實作)
// ----------------------------------------------------
// Future<List<Participant>> getParticipants() async { ... }
// Future<bool> verifyParticipant(String name, String code) async { ... }
// Future<void> updateParticipantStatus(...) async { ... }
} // 這是 DatabaseRepository 類別的唯一結尾大括號。}