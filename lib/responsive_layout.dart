// lib/responsive_layout.dart

import 'package:flutter/material.dart';

// ====================================================================
// 響應式斷點定義 (Screen Breakpoints)
// ====================================================================
class ScreenBreakpoints {
  // 手機 (Mobile) 斷點：小於這個寬度視為手機佈局
  static const double mobile = 600;

  // 平板/桌面 (Tablet/Desktop) 斷點：大於這個寬度可視為超寬桌面
  static const double tablet = 1200;

  /// 判斷當前螢幕寬度是否為手機尺寸 (< 600px)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// 判斷當前螢幕寬度是否為寬螢幕尺寸 (>= 600px)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobile;
  }
}


// ====================================================================
// 通用響應式佈局 Widget (ResponsiveLayout)
// ====================================================================
// 此 Widget 用於根據螢幕寬度，自動切換顯示 mobile 或 desktop 佈局。
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  /// 建構子要求必須提供 mobile 和 desktop 兩種視圖
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 LayoutBuilder 獲取父層 Widget 提供的可用空間限制
    return LayoutBuilder(
      builder: (context, constraints) {
        // 判斷可用寬度是否達到桌面斷點
        if (constraints.maxWidth >= ScreenBreakpoints.mobile) {
          // 寬度 >= 600px，顯示桌面版佈局
          return desktop;
        } else {
          // 寬度 < 600px，顯示手機版佈局
          return mobile;
        }
      },
    );
  }
}