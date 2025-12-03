// 匯入 Flutter 的核心 UI 套件（提供常見的 Widget，如 MaterialApp、Scaffold、TextField、Button 等）
  import 'package:flutter/material.dart';
// 匯入 Supabase Flutter SDK，用來與 Supabase 資料庫溝通
  import 'package:supabase_flutter/supabase_flutter.dart';

  import 'app.dart';

/// main() 為 Flutter 應用的進入點（所有應用從這裡開始執行）
  Future<void> main() async {
    // Flutter 的 Widgets 系統初始化（確保在 runApp 前能安全呼叫 plugin 或 async 初始化）
    WidgetsFlutterBinding.ensureInitialized();

    // const supabaseUrl = 'https://ihpietkzzyueineodphr.supabase.co';
    // const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlocGlldGt6enl1ZWluZW9kcGhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MjUzMDQsImV4cCI6MjA3ODUwMTMwNH0.gWZvAl7cReHVYIlrqODjik1vBtX3wDbl5fkIz-DSR6U';
    //
    //
    // // 初始化 Supabase，連接你的專案
    // // 🔹 請替換成你在 Supabase 專案中的 URL 與 anon key
    // await Supabase.initialize(
    //   url: supabaseUrl, // ← 請放入你的 Supabase URL
    //   anonKey: supabaseKey, // ← 請放入你的匿名 key
    // );
    //
    // // 🔍 測試查詢資料庫連線是否成功
    // final response = await Supabase.instance.client
    //     .from('members')
    //     .select('*')
    //     .limit(1);
    //
    // print('📡 Supabase 測試回傳: ${response}');



    // 啟動整個 Flutter App
    // runApp(const MyApp());
    runApp(const MyApp());
  }

  // /// 應用的根組件（StatelessWidget：不需要內部狀態）
  // class MyApp extends StatelessWidget {
  // const MyApp({super.key});
  //
  // @override
  // Widget build(BuildContext context) {
  // // MaterialApp：Flutter 提供的基礎 App 容器（包含路由、主題設定、首頁）
  // return MaterialApp(
  // title: '2025 年末聖誕交換禮物',
  // debugShowCheckedModeBanner: false, // 關閉右上角「DEBUG」標籤
  // theme: ThemeData(
  // primarySwatch: Colors.blue, // 主題色（藍色系）
  // useMaterial3: true, // 啟用 Material 3 規範樣式
  // ),
  // home: const RegistrationPage(), // 設定應用首頁為「RegistrationPage」
  // );
  // }
  // }
  //
  // /// 建立一個「有狀態」的頁面，用於報名表單
  // class RegistrationPage extends StatefulWidget {
  // const RegistrationPage({super.key});
  //
  // @override
  // State<RegistrationPage> createState() => _RegistrationPageState();
  // }
  //
  // /// 頁面對應的狀態類別（State），負責管理使用者輸入與互動
  // class _RegistrationPageState extends State<RegistrationPage> {
  // // 三個 TextEditingController：分別控制「姓名」、「Email」、「備註」欄位的輸入內容
  // final _nameController = TextEditingController();
  // final _messageController = TextEditingController();
  //
  // // 是否正在送出資料（用來顯示 loading 狀態）
  // bool _isSubmitting = false;
  //
  // /// 送出報名表單的主要方法
  // Future<void> _submitForm() async {
  // // 取得使用者輸入內容並去除前後空白
  // final name = _nameController.text.trim();
  // final message = _messageController.text.trim();
  //
  // // 簡單驗證：姓名與 Email 不可為空
  // if (name.isEmpty) {
  // // 用 SnackBar 顯示提示訊息
  // ScaffoldMessenger.of(context).showSnackBar(
  // const SnackBar(content: Text('請輸入姓名與 Email')),
  // );
  // return; // 中止送出
  // }
  //
  // // 開啟 loading 狀態
  // setState(() => _isSubmitting = true);
  //
  // try {
  // // 呼叫 Supabase API，將表單資料插入資料表
  // await Supabase.instance.client
  //     .from('members') // 指定要操作的資料表名稱
  //     .insert({
  // 'name': name, // 對應資料表中的 name 欄位
  // 'memo': message, // 對應資料表中的 message 欄位（可選）
  // });
  //
  // // 若成功，顯示成功提示
  // ScaffoldMessenger.of(context).showSnackBar(
  // const SnackBar(content: Text('報名成功！')),
  // );
  //
  // // 清空所有輸入欄位
  // _nameController.clear();
  // _messageController.clear();
  // } catch (error) {
  // // 若發生錯誤（例如權限不足、網路錯誤等）
  // ScaffoldMessenger.of(context).showSnackBar(
  // SnackBar(content: Text('發生錯誤：$error')),
  // );
  // } finally {
  // // 不論成功或失敗都結束 loading 狀態
  // setState(() => _isSubmitting = false);
  // }
  // }
  //
  // /// build() 為頁面 UI 的主要繪製方法
  // @override
  // Widget build(BuildContext context) {
  // return Scaffold(
  // // Scaffold 是 Material App 的基礎結構（包含 AppBar、Body 等）
  // appBar: AppBar(
  // title: const Text('活動報名表單'), // 頁面標題
  // centerTitle: true, // 標題文字置中
  // ),
  //
  // // body：主體內容
  // body: Center(
  // child: SingleChildScrollView(
  // // SingleChildScrollView 可讓表單內容在小螢幕可滾動，避免被鍵盤擋住
  // padding: const EdgeInsets.all(24), // 外邊距 24
  // child: Column(
  // mainAxisAlignment: MainAxisAlignment.center, // 垂直置中
  // children: [
  // // 頁面主標題文字
  // const Text(
  // '報名參加活動',
  // style: TextStyle(
  // fontSize: 28,
  // fontWeight: FontWeight.bold,
  // ),
  // ),
  //
  // const SizedBox(height: 24), // 標題與第一個輸入框的間距
  //
  // // 姓名輸入欄
  // TextField(
  // controller: _nameController, // 綁定 controller
  // decoration: const InputDecoration(
  // labelText: '姓名', // 輸入提示文字
  // border: OutlineInputBorder(), // 外框樣式
  // ),
  // ),
  //
  // const SizedBox(height: 16), // 欄位間距
  //
  // // 備註欄（可選）
  // TextField(
  // controller: _messageController,
  // decoration: const InputDecoration(
  // labelText: '備註（可選）',
  // border: OutlineInputBorder(),
  // ),
  // maxLines: 3, // 允許輸入多行文字
  // ),
  //
  // const SizedBox(height: 24), // 與按鈕間距
  //
  // // 根據狀態切換：若正在送出則顯示 loading，否則顯示按鈕
  // _isSubmitting
  // ? const CircularProgressIndicator() // 轉圈圈進度條
  //     : ElevatedButton.icon(
  // icon: const Icon(Icons.send), // 按鈕圖示
  // label: const Text('送出報名'), // 按鈕文字
  // onPressed:
  // _submitForm, // 按下按鈕後呼叫 _submitForm() 方法
  // style: ElevatedButton.styleFrom(
  // padding: const EdgeInsets.symmetric(
  // horizontal: 32,
  // vertical: 16,
  // ), // 自訂內距
  // ),
  // ),
  // ],
  // ),
  // ),
  // ),
  // );
  // }
  //
  // /// 釋放 TextEditingController 避免記憶體洩漏
  // @override
  // void dispose() {
  // _nameController.dispose();
  // _messageController.dispose();
  // super.dispose();
  // }
  // }
