// lib/database_repository.dart
/*


import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:developer'; // 用於日誌記錄

// ====================================================================
// 🔴 必填：Supabase 專案設定
// 請替換為您實際的專案 URL 和 Anon Key
// ====================================================================
const String _supabaseUrl = 'YOUR_SUPABASE_URL';
const String _supabaseAnonKey = 'YOUR_ANON_KEY';

// 靜態客戶端實例
SupabaseClient? _clientInstance;


/// -----------------------------------------------------------
/// 資料庫倉儲層 (DatabaseRepository)
/// 封裝所有 Supabase 相關的 CRUD 操作和錯誤處理。
/// -----------------------------------------------------------
class DatabaseRepository {

  // 私有建構子，防止外部直接實例化
  DatabaseRepository._();

  // 單例實例
  static final DatabaseRepository _instance = DatabaseRepository._();

  // 獲取實例的靜態方法
  static DatabaseRepository get instance => _instance;

  /// ------------------------------------
  /// I. 初始化與客戶端獲取
  /// ------------------------------------

  /// 應用程式啟動時呼叫，用於初始化 Supabase 客戶端。
  ///
  /// 注意：在 runApp() 之前必須確保呼叫此函式。
  static Future<void> initialize() async {
    if (_clientInstance == null) {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
      _clientInstance = Supabase.instance.client;
      log('Supabase 客戶端初始化完成。');
    }
  }

  /// 獲取 Supabase 客戶端，如果未初始化會拋出錯誤。
  SupabaseClient get _supabaseClient {
    if (_clientInstance == null) {
      throw Exception("DatabaseRepository 尚未初始化，請先呼叫 initialize()。");
    }
    return _clientInstance!;
  }

  // ------------------------------------
  // II. 讀取 (Read) 相關功能
  // ------------------------------------

  /// 連結資料庫資料表並讀取所有資料
  ///
  /// [tableName] 資料表名稱 (例如: 'gifts', 'users')
  /// [columns] 指定要讀取的欄位，預設為所有欄位 '*'
  /// [filter] 選用，用於設定過濾條件 (例如: {'user_id': 1})
  ///
  /// 返回: List<Map<String, dynamic>> 格式的資料清單，如果失敗則返回 null
  Future<List<Map<String, dynamic>>?> readAll(
      String tableName, {
        String columns = '*',
        Map<String, dynamic>? filter,
      }) async {
    try {
      var query = _supabaseClient.from(tableName).select(columns);

      // 應用過濾條件
      if (filter != null) {
        filter.forEach((key, value) {
          query = query.eq(key, value); // 簡單的等於條件 (可以擴展支持 gt, lt 等)
        });
      }

      final data = await query;
      log('成功讀取 $tableName 資料表中的 ${data.length} 筆資料');
      return data;
    } on PostgrestException catch (e) {
      log('Postgres 讀取 $tableName 錯誤: ${e.message}', error: e);
      return null;
    } catch (e) {
      log('讀取 $tableName 發生未知錯誤: $e', error: e);
      return null;
    }
  }

  // ------------------------------------
  // III. 寫入/更新 (Create, Update, Delete) 相關功能
  // ------------------------------------

  /// 新增資料到指定的資料表
  ///
  /// [tableName] 資料表名稱
  /// [data] 要新增的資料 (Map<String, dynamic>)
  ///
  /// 返回: 新增成功的資料，如果失敗則返回 null
  Future<Map<String, dynamic>?> create(
      String tableName,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _supabaseClient
          .from(tableName)
          .insert(data)
          .select() // 獲取新增後的完整資料
          .single();

      log('成功新增資料到 $tableName: $response');
      return response;
    } on PostgrestException catch (e) {
      log('Postgres 新增 $tableName 錯誤: ${e.message}', error: e);
      return null;
    } catch (e) {
      log('新增 $tableName 發生未知錯誤: $e', error: e);
      return null;
    }
  }

  /// 根據條件更新資料表中的資料
  ///
  /// [tableName] 資料表名稱
  /// [updates] 要更新的欄位及其新值 (Map<String, dynamic>)
  /// [filterColumn] 用於尋找目標資料列的欄位 (例如: 'id')
  /// [filterValue] 目標欄位的值 (例如: 1)
  ///
  /// 返回: 更新成功的資料，如果失敗則返回 null
  Future<Map<String, dynamic>?> update(
      String tableName,
      Map<String, dynamic> updates,
      String filterColumn,
      dynamic filterValue,
      ) async {
    try {
      final response = await _supabaseClient
          .from(tableName)
          .update(updates)
          .eq(filterColumn, filterValue) // 根據條件更新
          .select()
          .single();

      log('成功更新 $tableName 資料， $filterColumn: $filterValue');
      return response;
    } on PostgrestException catch (e) {
      log('Postgres 更新 $tableName 錯誤: ${e.message}', error: e);
      return null;
    } catch (e) {
      log('更新 $tableName 發生未知錯誤: $e', error: e);
      return null;
    }
  }

  /// 根據條件刪除資料表中的資料
  ///
  /// [tableName] 資料表名稱
  /// [filterColumn] 用於尋找目標資料列的欄位
  /// [filterValue] 目標欄位的值
  Future<bool> delete(
      String tableName,
      String filterColumn,
      dynamic filterValue,
      ) async {
    try {
      await _supabaseClient
          .from(tableName)
          .delete()
          .eq(filterColumn, filterValue);

      log('成功刪除 $tableName 資料， $filterColumn: $filterValue');
      return true;
    } on PostgrestException catch (e) {
      log('Postgres 刪除 $tableName 錯誤: ${e.message}', error: e);
      return false;
    } catch (e) {
      log('刪除 $tableName 發生未知錯誤: $e', error: e);
      return false;
    }
  }

  // ------------------------------------
  // IV. 實時訂閱功能 (Realtime Subscription)
  // ------------------------------------

  /// 訂閱資料表變動
  ///
  /// [tableName] 要訂閱的資料表
  /// [callback] 當資料表有變動時執行的回呼函式
  ///
  /// 返回: RealtimeChannel 實例，用於管理訂閱（例如取消訂閱：channel.unsubscribe()）
  RealtimeChannel subscribeToChanges(
      String tableName,
      Function(PostgresChange) callback,
      ) {
    final channel = _supabaseClient.channel('public_$tableName').onPostgresChanges(
      event: PostgresChangeEvent.all, // 訂閱所有變動 (INSERT, UPDATE, DELETE)
      schema: 'public',
      table: tableName,
      callback: callback,
    ).subscribe();

    log('已訂閱 $tableName 資料表變動');
    return channel;
  }
}

// 供其他頁面使用的單例實例
final databaseRepository = DatabaseRepository.instance;
*/

// --------------------------------------------------------------------
// ❗ 額外提示：在您的應用程式入口 (例如 main.dart 或 app.dart)
// 確保您在 runApp() 之前呼叫初始化函式：
// --------------------------------------------------------------------
/*
import 'package:flutter/material.dart';
import 'database_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 呼叫 DatabaseRepository 的靜態初始化方法
  await DatabaseRepository.initialize();

  runApp(const MyApp());
}
*/

