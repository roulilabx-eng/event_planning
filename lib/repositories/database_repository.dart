
/*    const String supabaseUrl = 'https://ihpietkzzyueineodphr.supabase.co';
    const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlocGlldGt6enl1ZWluZW9kcGhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjUzMDQsImV4cCI6MjA3ODUwMTMwNH0.gWZvAl7cReHVYIlrqODjik1vBtX3wDbl5fkIz-DSR6U';
*/
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gift_theme_model.dart';
import '../models/participant_model.dart';


// ====================================================================
// 🌐 資料庫操作層 (DatabaseRepository) - 採用 Singleton 模式
// ====================================================================
class DatabaseRepository {

  // 假定這是 Supabase Client 的實例
  static late final SupabaseClient _supabase;

  // 靜態方法 1: 初始化 Supabase 連線 (供 lib/main.dart 呼叫)
  static Future<void> initializeSupabase() async {
    // ⚠️ 實際應用中，URL 和 Key 應從環境變數或安全配置中獲取
    // 這裡使用預留位置確保程式碼結構正確
    const String supabaseUrl = 'https://ihpietkzzyueineodphr.supabase.co';
    const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlocGlldGt6enl1ZWluZW9kcGhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjUzMDQsImV4cCI6MjA3ODUwMTMwNH0.gWZvAl7cReHVYIlrqODjik1vBtX3wDbl5fkIz-DSR6U';

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      _supabase = Supabase.instance.client;
      print('Supabase initialized successfully.');
    } catch (e) {
      print('Supabase initialization error: $e');
      // 實際應用中應有更完善的錯誤處理
    }
  }

  // 靜態方法 1: 初始化 Supabase 連線 (供 lib/main.dart 呼叫)

  // 🏆 靜態單例實例 🏆
  // static final DatabaseRepository _instance = DatabaseRepository._internal();
  // Factory 構造函數，確保始終返回相同的實例


  // factory DatabaseRepository() => _instance;

  // // 私有構造函數 (確保外部不能直接 new DatabaseRepository())
  // DatabaseRepository._internal();
  //
  // // 取得已初始化的 Supabase 客戶端
  // SupabaseClient get _client => Supabase.instance.client;

  // ----------------------------------------------------
  // 應用程式初始化
  // ----------------------------------------------------

  // /// 初始化 Supabase 連線。此方法應在應用程式啟動時呼叫一次。
  // static Future<void> initializeSupabase() async {
  //   // 🔴 警告：請將這些 PLACEHOLDER 值替換為您實際的 Supabase URL 和 Anon Key！
  //   // 這是連接到您後端服務的關鍵。
  //   const String supabaseUrl = 'https://ihpietkzzyueineodphr.supabase.co';
  //   const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlocGlldGt6enl1ZWluZW9kcGhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjUzMDQsImV4cCI6MjA3ODUwMTMwNH0.gWZvAl7cReHVYIlrqODjik1vBtX3wDbl5fkIz-DSR6U';
  //
  //   if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
  //     // 檢查是否仍在使用預留符號
  //     print('🔴 Supabase 初始化失敗：請在 DatabaseRepository 中填入實際的 URL 和 Key。');
  //     return;
  //   }
  //
  //   try {
  //     await Supabase.initialize(
  //       url: supabaseUrl,
  //       anonKey: supabaseAnonKey,
  //     );
  //     print('✅ Supabase 初始化成功！');
  //   } catch (e) {
  //     print('🚨 Supabase 初始化過程中發生錯誤: $e');
  //   }
  // }

  // ----------------------------------------------------
  // 禮物主題相關操作
  // ----------------------------------------------------

  /// 取得所有啟用的禮物主題列表
  /// 將 Supabase 返回的 JSON 資料轉換為 List<GiftTheme>
  // 靜態方法 2 (🔴 修正錯誤處): 獲取所有禮物主題
  // 供 SlotMachineWidget 內的 FutureBuilder 呼叫
  // lib/repositories/database_repository.dart (或 gift_theme_model.dart 中的 static 方法)

  static Future<List<GiftTheme>> getGiftThemes() async {
    try {
      // 1️⃣ 從 Supabase 取得 gift_themes 表格資料
      final response = await _supabase
          .from('gift_themes')
          .select('id, theme_name, code, is_active, created_at') // ✅ 必須包含 fromJson 所需欄位
          .eq('is_active', true) // 只取啟用的主題
          .limit(100)
          .order('theme_name', ascending: true);

      // 2️⃣ 確認回傳是 List
      if (response is List) {
        // 將 JSON 轉 GiftTheme，單筆解析失敗也不影響其他資料
        return response.map((map) {
          try {
            return GiftTheme.fromJson(map as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing GiftTheme: $e');
            return null; // 解析失敗回傳 null
          }
        }).whereType<GiftTheme>().toList(); // 過濾掉 null
      } else {
        throw Exception('Unexpected data format from Supabase: $response');
      }
    } on PostgrestException catch (e) {
      print('Postgrest Error fetching gift themes: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error fetching gift themes: $e');
      rethrow;
    }
  }


  /// 從 Supabase 取得 Participant 列表
  static Future<List<Participant>> getParticipants() async {
    try {
      // 查詢 participants 表格
      final response = await _supabase
          .from('participants')
          .select(
        'id, num, sort, full_name, verification_code, login_time, created_at, gift_assigned_theme',
      )
          .order('sort', ascending: true)
          .limit(100); // 可以依需求調整

      // 確認回傳格式
      if (response is List) {
        return response
            .map((map) => Participant.fromJson(map as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Unexpected data format from Supabase: $response');
      }
    } on PostgrestException catch (e) {
      print('Postgrest Error fetching participants: ${e.message}');
      rethrow; // 交給 FutureBuilder 或呼叫端處理錯誤
    } catch (e) {
      print('Error fetching participants: $e');
      rethrow;
    }
  }


  /// 更新 participant 的 gift_assigned_theme 欄位
  static Future<void> updateGiftAssignedTheme(int num, String themeCode) async {
    // TODO: 實作資料庫更新邏輯
    // 例如呼叫後端 API 或寫入本地資料
    print('更新 participant $num 的 gift_assigned_theme 為 $themeCode');
  }

// ----------------------------------------------------
// 參與者資訊相關操作 (待實作)
// ----------------------------------------------------
// Future<List<Participant>> getParticipants() async { ... }
// Future<bool> verifyParticipant(String name, String code) async { ... }
// Future<void> updateParticipantStatus(...) async { ... }
} // 這是 DatabaseRepository 類別的唯一結尾大括號。}