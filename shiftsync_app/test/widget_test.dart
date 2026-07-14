import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftsync_app/main.dart';

void main() {
  testWidgets('ShiftSync onboarding, login flow, interactive calendar, and EGP ledger work seamlessly', (WidgetTester tester) async {
    // Build our app starting from WelcomeScreen
    await tester.pumpWidget(
      const ProviderScope(
        child: ShiftSyncApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify WelcomeScreen
    expect(find.text('شِفْت سينك • ShiftSync'), findsOneWidget);
    expect(find.text('تسجيل الدخول للمناوبات'), findsOneWidget);

    // Tap to enter LoginScreen
    await tester.tap(find.text('تسجيل الدخول للمناوبات'));
    await tester.pumpAndSettle();

    // Verify LoginScreen
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('مرحباً بك مجدداً 👋'), findsOneWidget);
    expect(find.textContaining('دخول تجريبي سريع'), findsOneWidget);

    // Tap Quick Demo Login button to reach MainNavigationScaffold
    await tester.tap(find.textContaining('دخول تجريبي سريع'));
    await tester.pumpAndSettle();

    // Verify MainNavigationScaffold items (Header, Calendar, Egyptian Pound Ledger, Bottom Nav)
    expect(find.textContaining('نظام شِفْت سينك'), findsOneWidget);
    expect(find.textContaining('كمال سرور'), findsOneWidget);
    expect(find.text('تقويم الورديات (تصفح شهر بشهر)'), findsOneWidget);
    expect(find.text('عليا فلوس (I OWE)'), findsOneWidget);
    expect(find.text('ليا فلوس (OWED TO ME)'), findsOneWidget);
    expect(find.text('٤٠٠ ج.م'), findsOneWidget);
    expect(find.text('٨٠٠ ج.م'), findsOneWidget);

    // Verify Bottom Nav items
    expect(find.text('الجدول والورديات'), findsOneWidget);
    expect(find.text('سوق التبادلات'), findsOneWidget);
  });
}
