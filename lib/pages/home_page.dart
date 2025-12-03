import 'package:flutter/material.dart';
import '../widgets/snow_effect.dart';
import '../widgets/countdown_widget.dart';
import '../widgets/identity_selection_widget.dart';
import '../widgets/participant_settings_widget.dart';
import '../widgets/slot_machine_widget.dart'; // ⭐ 新版拉霸機

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool verified = false; // ⭐ 是否已完成身份選擇
  String? participantName; // ⭐ 目前登入者的名字

  // ⭐ 活動時間（倒數計時用）
  DateTime eventTime = DateTime(2025, 12, 24, 19, 0, 0);

  // ⭐ 參加者列表
  List<String> participants = [
    'Alice', 'Bob', 'Charlie', 'David',
    'Eve', 'Frank', 'Grace', 'Lab.X',
  ];

  // ⭐ 活動資訊框固定高度
  static const double activityInfoHeight = 480;

  // ⭐ 下方留白距離
  static const double bottomSpacing = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ================================================
          // 背景圖層
          // ================================================
          Positioned.fill(
            child: Image.asset(
              'assets/images/christmas_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // ================================================
          // 雪花特效覆蓋
          // ================================================
          const SnowEffect(),

          // ================================================
          // 倒數計時（固定在上方）
          // ================================================
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: CountdownWidget(
                targetDateTime: eventTime,
              ),
            ),
          ),

          // ================================================
          // Lab.X 專用：設定按鈕（右上角）
          // ================================================
          if (participantName?.toLowerCase() == 'lab.x')
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ParticipantSettingsWidget(
                      eventTime: eventTime,
                      participants: participants,
                      onSave: (newTime, newList) {
                        setState(() {
                          eventTime = newTime;
                          participants = newList;
                        });
                      },
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),

          // ================================================
          // 主內容（可滾動）
          // ================================================
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // --------------------------------------------
                  // 標題（🎁 聖誕 X 猜謎 X 交換禮物 🎁）
                  // --------------------------------------------
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: const [
                        Text('🎁', style: TextStyle(fontSize: 32)),
                        SizedBox(width: 10),
                        Text(
                          '聖誕 Ｘ 猜謎 Ｘ 交換禮物',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('🎁', style: TextStyle(fontSize: 32)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==========================================
                      // 左側：活動資訊框
                      // ==========================================
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.only(left: 60, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [

                              // -------------------------------------
                              // 活動資訊框（固定高度）
                              // -------------------------------------
                              Container(
                                height: activityInfoHeight,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      ' 🎄活動資訊 🎄',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    const Text('主題｜再不猜謎就瘋狂：身體小小、頭腦一級棒'),
                                    const Text('時間｜2025/12/24（三）19:00'),
                                    const Text('地點｜金色三麥'),

                                    const SizedBox(height: 20),

                                    const Text(
                                      ' 🔔 活動須知 🔔 ',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    const Text('禮物金額｜300 元以上（不含包裝）'),

                                    // ⭐ 點擊可開啟 SlotMachine 的入口
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (context) {
                                            return Dialog(
                                              insetPadding: const EdgeInsets.all(20),
                                              backgroundColor: Colors.transparent,
                                              child: Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: const SlotMachineWidget(), // ⭐ 拉霸機 Widget
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Row(
                                        children: const [
                                          Text(
                                            '禮物主題｜點擊右方聖誕樹',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.touch_app, size: 18, color: Colors.blue),
                                        ],
                                      ),
                                    ),

                                    const Text('Dress Code｜聖誕風（不限紅綠，可有小道具即可）'),
                                    const Text('必須：點擊右方聖誕樹'),

                                    const SizedBox(height: 20),

                                    const Text(
                                      ' 🎉 活動流程 🎉 ',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    const Text(
                                      '入場 & 報到（19:00–19:10）主辦人會收集每個人準備的謎題 & 禮物編號。',
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: bottomSpacing),
                            ],
                          ),
                        ),
                      ),

                      // ==========================================
                      // 右側：聖誕樹（可點擊彈出 SlotMachine）
                      // ==========================================
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return Dialog(
                                  insetPadding: const EdgeInsets.all(20),
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const SlotMachineWidget(), // ⭐ 新拉霸機
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            alignment: Alignment.topCenter,
                            margin: const EdgeInsets.only(right: 40, bottom: 50),
                            child: Image.asset(
                              'assets/images/tree.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),

          // ================================================
          // 覆蓋層：身份選擇（未驗證才會出現）
          // ================================================
          if (!verified)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: IdentitySelectionWidget(
                onVerified: _onVerified,
                participants: participants,
              ),
            ),
        ],
      ),
    );
  }

  // ⭐ 當身份完成選擇後觸發
  void _onVerified(String name) {
    setState(() {
      verified = true;
      participantName = name;
    });
  }
}
