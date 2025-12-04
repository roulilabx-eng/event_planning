import 'package:flutter/material.dart';
import '../responsive_layout.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/slot_machine_widget.dart';
// 引入雪花特效
import '../widgets/snow_effect.dart';
// 引入身份選擇 Widget
import '../widgets/identity_selection_widget.dart';
// 引入 defaultEventTime，確保它可以被 CountdownWidget 成功調用
import '../widgets/countdown_widget.dart' show defaultEventTime;
import '../globals.dart' as globals;


// ====================================================================
// 🎁 活動資料與常數結構 (Event Data and Constants)
// 將所有文字內容和特定尺寸常數集中於此
// ====================================================================
class EventData {
  // --- Strings ---
  final String mainTitle = '🎁 聖誕 Ｘ 猜謎 Ｘ 交換禮物 🎁'; // 這裡不再是歡迎語，而是活動主標題

  final String infoTitle1 = '🎄 活動資訊 🎄';
  final String infoTheme = '主題｜再不猜謎就瘋狂：身體小小、頭腦一級棒';
  final String infoTime = '時間｜2025/12/24（三）19:00';
  final String infoLocation = '地點｜海底撈';

  final String infoTitle2 = '🔔 活動須知 🔔';
  final String infoDressCode = 'Dress Code｜聖誕風-紅綠穿搭 <-小黑人強力要求';
  final String infoGiftPrefix = '禮物主題｜';
  final String infoGiftClick = '請點擊';
  final String infoGiftAmount = '禮物金額｜300 up up';

  final String infoQA = '禮物猜謎｜請準備1個約5分鐘內可以完成的猜謎，必須有明確答案且控制在A4大小內';
  final String infoQA_detail = '(類型不限：謎語 / 腦筋急轉彎 / 密碼題 / 邏輯小問答 / 搞怪題)';

  final String infoTitle3 = '🎉 活動流程 🎉';
  final String processStep1 = '入場 & 報到（工作人員會收集個人的謎題)';
  final String processStep2 = '聖誕大餐';
  final String processStep3 = '交換禮物 & 遊戲環節';


  // --- Sizing and Spacing Constants ---
  final double mobileTitleSpacing = 16.0;
  final double desktopTitleSpacing = 32.0;
  final double mobileInfoSpacing = 12.0;
  final double desktopInfoSpacing = 24.0;

  const EventData();
}

// 實例化常數，方便全局存取
const eventData = EventData();


// ====================================================================
// 輔助 Widget: 活動資訊專用結構 (info_bg 邊框 + 白底遮罩)
// ====================================================================
class _InfoSectionContainer extends StatelessWidget {
  final Widget child;

  const _InfoSectionContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 1. 外部容器使用圖片作為背景 (模擬邊框效果)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // 🔴 實際專案中，這裡應該使用本地圖片
        image: const DecorationImage(
          image: AssetImage('assets/images/slot_machine_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(4), // 留出外部圖片邊框

      // 2. 內部內容容器 (偏白底遮罩)
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85), // 偏白底遮罩
          borderRadius: BorderRadius.circular(8),
        ),
        child: child, // 內容
      ),
    );
  }
}

// ====================================================================
// 主頁面 Widget (HomePage)
// ====================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 🔴 已驗證的使用者身份 (如果為 null，則身份未定)
  String? _authenticatedUser;

  @override
  void initState() {
    super.initState();
    // 🌟 在首頁啟動時預先載入禮物主題，後續開啟拉霸機可直接使用快取資料
    globals.loadGiftThemesIfNeeded();
    // 🔴 頁面渲染完成後，自動彈出身份選擇視窗
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authenticatedUser == null) {
        _showIdentitySelectionDialog(context);
      }
    });
  }

  // 🔴 處理身份驗證成功的回調
  void _handleUserVerified(String name) {
    setState(() {
      _authenticatedUser = name;
    });
    // 由於 IdentitySelectionWidget 是透過 showGeneralDialog 彈出，
    // 這裡需要 pop 掉該 Route (即 GeneralDialog)
    Navigator.of(context).pop();
  }

  // 🔴 彈出身份選擇視窗 (不再傳遞 participants)
  void _showIdentitySelectionDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // 🔴 必須通過驗證才能關閉 (但仍需 PopScope 禁用手勢)
      barrierLabel: 'IdentitySelection',
      barrierColor: Colors.black.withOpacity(0.9), // 深色遮罩，強調驗證優先級
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, a1, a2, child) {
        // 使用簡單的縮放過渡效果
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: a1,
            curve: Curves.easeOutBack,
          ),
          child: child,
        );
      },
      pageBuilder: (context, a1, a2) {
        // 🏆 修正：使用 PopScope 徹底禁用所有返回/關閉操作，包括手勢滑動 🏆
        return PopScope(
          canPop: false, // 禁用返回操作，從而禁用左右滑動關閉
          child: IdentitySelectionWidget(
            onVerified: _handleUserVerified,
          ),
        );
      },
    );
  }

  // 實作拉霸機視窗彈出與遮罩
  void _showSlotMachineDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 點擊視窗外可關閉
      barrierLabel: 'SlotMachine',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: a1,
            curve: Curves.easeOutBack,
          ),
          child: child,
        );
      },
      pageBuilder: (context, a1, a2) {
        return const Center(
          child: SlotMachineWidget(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Body 主體內容: Stack 堆疊背景、遮罩、雪花、內容 ---
      body: Stack(
        children: [
          // 1. 背景圖片 (最底層)
          Positioned.fill(
            child: Image.asset(
              'assets/images/christmas_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade900,
                  child: const Center(child: Text('圖片載入失敗', style: TextStyle(color: Colors.red))),
                );
              },
            ),
          ),

          // 2. 遮罩層 (位於背景之上)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // 3. 雪花效果 (位於遮罩之上，內容之下，確保雪花是亮色的)
          const Positioned.fill(child: SnowEffect()),

          // 4. RWD 主體內容 (最上層)
          ResponsiveLayout(
            mobile: _MobileBody(
              showSlotMachineDialog: _showSlotMachineDialog,
              authenticatedUser: _authenticatedUser,
            ),
            desktop: _DesktopBody(
              showSlotMachineDialog: _showSlotMachineDialog,
              authenticatedUser: _authenticatedUser,
            ),
          ),
        ],
      ),
    );
  }
}


// ====================================================================
// 📱 窄螢幕 (手機) 佈局內容 (_MobileBody)
// ====================================================================
class _MobileBody extends StatelessWidget {
  final Function(BuildContext) showSlotMachineDialog;
  final String? authenticatedUser;
  const _MobileBody({required this.showSlotMachineDialog, this.authenticatedUser});

  @override
  Widget build(BuildContext context) {
    // 核心修正：使用 SingleChildScrollView 包裹整個內容 Column
    return SingleChildScrollView(
      child: Column(
        // 🔴 修正溢位問題：確保 Column 僅佔用其內容所需的垂直空間
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ----------------------------------------------------
          // 1. 頭部區域：主題 Title -> 倒數計時元件 (已依照要求交換位置)
          // ----------------------------------------------------
          Padding(
            padding: EdgeInsets.only(
              // 縮減頂部填充，防止溢出
              top: MediaQuery.of(context).padding.top + 8.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // 區塊 1: 主題 Title (新位置)
                FittedBox(
                  fit: BoxFit.scaleDown, // 僅縮小
                  child: Text(
                    eventData.mainTitle, // 引用常數 (非歡迎語)
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1, // 確保單行
                  ),
                ),

                SizedBox(height: eventData.mobileTitleSpacing), // 引用常數 (標題與倒數計時器間距)

                // 區塊 2: 倒數計時元件 (新位置)
                Container(
                  alignment: Alignment.center,
                  child: CountdownWidget(targetDateTime: defaultEventTime),
                ),

                SizedBox(height: eventData.mobileTitleSpacing), // 引用常數 (倒數計時器與資訊區間距)
              ],
            ),
          ),

          // ----------------------------------------------------
          // 2. 資訊區域
          // ----------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _InfoSectionContainer(
                  child: _buildInfoContent(context, showSlotMachineDialog, isMobile: true),
                ),
                // 增加底部留白，讓滾動更順暢
                const SizedBox(height: 100.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ====================================================================
// 💻 寬螢幕 (桌面/平板) 佈局內容 (_DesktopBody)
// ====================================================================
class _DesktopBody extends StatelessWidget {
  final Function(BuildContext) showSlotMachineDialog;
  final String? authenticatedUser;
  const _DesktopBody({required this.showSlotMachineDialog, this.authenticatedUser});

  @override
  Widget build(BuildContext context) {
    return _DesktopMainLayout(
      showSlotMachineDialog: showSlotMachineDialog,
      authenticatedUser: authenticatedUser,
    );
  }
}


// ====================================================================
// 桌面主內容佈局 (_DesktopMainLayout) - 已修正為整個頁面可滾動
// ====================================================================
class _DesktopMainLayout extends StatelessWidget {
  final Function(BuildContext) showSlotMachineDialog;
  final String? authenticatedUser;
  const _DesktopMainLayout({required this.showSlotMachineDialog, this.authenticatedUser});

  static const double maxWidth = 1000.0;

  @override
  Widget build(BuildContext context) {
    // 核心修正：使用 SingleChildScrollView 包裹整個 Padding
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 32.0,
          left: 32.0,
          right: 32.0,
          // 修正：將底部邊距移到外層 Padding
          bottom: 32.0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [


                // ----------------------------------------------------
                // 1. 頭部區域：主題 Title -> 倒數計時元件 (已依照要求交換位置)
                // ----------------------------------------------------

                // 區塊 1: 主題 Title (新位置)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    eventData.mainTitle,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),

                SizedBox(height: eventData.desktopTitleSpacing), // 標題與倒數計時器間距

                // 區塊 2: 倒數計時元件 (新位置)
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CountdownWidget(targetDateTime: defaultEventTime),
                ),

                SizedBox(height: eventData.desktopTitleSpacing), // 倒數計時器與資訊區間距

                // ----------------------------------------------------
                // 2. 資訊區域
                // ----------------------------------------------------
                _InfoSectionContainer(
                  child: _buildInfoContent(context, showSlotMachineDialog, isMobile: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ====================================================================
// 共用區塊生成器：活動資訊內容 (Section Builders)
// ====================================================================

// 1. 活動資訊區塊
Widget _buildEventInfoSection(TextStyle titleStyle, TextStyle contentStyle, double sectionSpacing) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(eventData.infoTitle1, style: titleStyle),
      SizedBox(height: sectionSpacing / 2),
      Text(eventData.infoTheme, style: contentStyle),
      Text(eventData.infoTime, style: contentStyle),
      Text(eventData.infoLocation, style: contentStyle),
    ],
  );
}

// 2. 活動須知區塊 (包含點擊事件)
Widget _buildRequirementSection(BuildContext context, Function(BuildContext) showSlotMachineDialog, TextStyle titleStyle, TextStyle contentStyle, double sectionSpacing) {
  // 定義紅色字體的樣式，繼承自 contentStyle
  final TextStyle redContentStyle = contentStyle.copyWith(
    color: Colors.red.shade700,
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(eventData.infoTitle2, style: titleStyle),
      SizedBox(height: sectionSpacing / 2),

      Text(eventData.infoDressCode, style: contentStyle), // 顯示 Dress Code
      SizedBox(height: sectionSpacing / 4),

      // 禮物主題 (點擊事件，彈出拉霸機)
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 這裡的文字也要套用 contentStyle (粗體+加大)
          Text(eventData.infoGiftPrefix, style: contentStyle),
          InkWell(
            onTap: () => showSlotMachineDialog(context),
            child: Text(
              eventData.infoGiftClick,
              style: contentStyle.copyWith(
                color: Colors.blue.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: sectionSpacing / 4),

      Text(eventData.infoGiftAmount, style: contentStyle),
      SizedBox(height: sectionSpacing / 4),

      // QA 規則 - 第一行
      Text(eventData.infoQA, style: contentStyle),
      // QA 規則細節 - 顯示為紅色
      Text(eventData.infoQA_detail, style: redContentStyle),
    ],
  );
}

// 3. 活動流程區塊
Widget _buildProcessSection(TextStyle titleStyle, TextStyle contentStyle, double sectionSpacing) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(eventData.infoTitle3, style: titleStyle),
      SizedBox(height: sectionSpacing / 2),
      Text(eventData.processStep1, style: contentStyle),
      SizedBox(height: sectionSpacing / 2),
      Text(eventData.processStep2, style: contentStyle),
      SizedBox(height: sectionSpacing / 2),
      Text(eventData.processStep3, style: contentStyle),
    ],
  );
}

// ====================================================================
// 共用的活動資訊內容函式 (主要排版管理器)
// ====================================================================
Widget _buildInfoContent(BuildContext context, Function(BuildContext) showSlotMachineDialog, {required bool isMobile}) {
  const TextStyle titleStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple);

  // 樣式調整：內文文字設為粗體，並加大 1 點
  final TextStyle contentStyle = TextStyle(
    fontSize: isMobile ? 15 : 17, // 手機 14+1=15, 桌面 16+1=17
    color: Colors.black87,
    fontWeight: FontWeight.bold,
  );

  // 根據設備選擇間距常數
  final double sectionSpacing = isMobile ? eventData.mobileInfoSpacing : eventData.desktopInfoSpacing;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 🎄 活動資訊 🎄
      _buildEventInfoSection(titleStyle, contentStyle, sectionSpacing),

      SizedBox(height: sectionSpacing),

      // 🔔 活動須知 🔔
      _buildRequirementSection(context, showSlotMachineDialog, titleStyle, contentStyle, sectionSpacing),

      SizedBox(height: sectionSpacing),

      // 🎉 活動流程 🎉
      _buildProcessSection(titleStyle, contentStyle, sectionSpacing),
    ],
  );
}