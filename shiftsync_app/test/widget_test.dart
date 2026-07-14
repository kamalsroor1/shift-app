import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftsync_app/core/navigation/main_navigation_scaffold.dart';
import 'package:shiftsync_app/core/storage/local_storage.dart';
import 'package:shiftsync_app/main.dart';
import 'package:dio/dio.dart';
import 'package:shiftsync_app/core/providers/core_providers.dart';

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('shiftsync_test');
    await HiveCacheService.init(testPath: tempDir.path);
  });

  testWidgets('Shiftak onboarding, login flow, interactive calendar, and EGP ledger work seamlessly with Riverpod', (WidgetTester tester) async {
    // Build our app starting from WelcomeScreen
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(
            Dio(
              BaseOptions(
                baseUrl: 'http://localhost:8000',
                connectTimeout: const Duration(milliseconds: 100),
                receiveTimeout: const Duration(milliseconds: 100),
              ),
            ),
          ),
        ],
        child: const ShiftakApp(),
      ),
    );
    await tester.pumpAndSettle();
    // Verify WelcomeScreen
    expect(find.text('شِفْتَك • Shiftak'), findsOneWidget);
    expect(find.text('تسجيل الدخول للمناوبات'), findsOneWidget);

    // Tap to enter LoginScreen
    await tester.tap(find.text('تسجيل الدخول للمناوبات'));
    await tester.pumpAndSettle();

    // Verify LoginScreen
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('مرحباً بك مجدداً 👋'), findsOneWidget);
    expect(find.textContaining('دخول تجريبي سريع'), findsOneWidget);

    // Tap Quick Demo Login button to reach MainNavigationScaffold
    await tester.ensureVisible(find.textContaining('دخول تجريبي سريع'));
    await tester.tap(find.textContaining('دخول تجريبي سريع'));
    await tester.pumpAndSettle();

    // Verify MainNavigationScaffold items (Header, Calendar, Egyptian Pound Ledger, Bottom Nav)
    expect(find.textContaining('نظام شِفْتَك'), findsOneWidget);
    expect(find.textContaining('كمال سرور'), findsOneWidget);
    expect(find.text('تقويم الورديات (تصفح شهر بشهر)'), findsOneWidget);
    expect(find.text('عليا فلوس (I OWE)'), findsOneWidget);
    expect(find.text('ليا فلوس (OWED TO ME)'), findsOneWidget);
    expect(find.text('٤٠٠ ج.م'), findsOneWidget);
    expect(find.text('٨٠٠ ج.م'), findsOneWidget);

    // Verify Bottom Nav items
    expect(find.text('الجدول والورديات'), findsOneWidget);
    expect(find.text('سوق التبادلات'), findsOneWidget);

    // Tap 'حسابي' (Account / Profile tab)
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();

    // Verify Account Profile screen & Logout button
    expect(find.text('حسابي والملف الشخصي'), findsOneWidget);
    expect(find.text('إدارة الجلسة الحالية'), findsOneWidget);
    expect(find.textContaining('تسجيل الخروج من نظام شِفْتَك'), findsOneWidget);

    // Tap logout button and verify confirmation dialog opens
    await tester.ensureVisible(find.textContaining('تسجيل الخروج من نظام شِفْتَك'));
    await tester.tap(find.textContaining('تسجيل الخروج من نظام شِفْتَك'));
    await tester.pumpAndSettle();

    expect(find.text('هل أنت متأكد من رغبتك في تسجيل الخروج من نظام شِفْتَك وإخلاء الجلسة المؤقتة من هذا الجهاز؟'), findsOneWidget);
    expect(find.text('إلغاء'), findsOneWidget);

    // Cancel logout dialog
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
  });

  testWidgets('Phase 5 interactive tabs (Marketplace, Ledger EGP, Notifications) render and navigate seamlessly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(
            Dio(
              BaseOptions(
                baseUrl: 'http://localhost:8000',
                connectTimeout: const Duration(milliseconds: 100),
                receiveTimeout: const Duration(milliseconds: 100),
              ),
            ),
          ),
        ],
        child: const ShiftakApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap welcome screen button to enter LoginScreen
    await tester.tap(find.text('تسجيل الدخول للمناوبات'));
    await tester.pumpAndSettle();

    // Login
    await tester.ensureVisible(find.textContaining('دخول تجريبي سريع'));
    await tester.tap(find.textContaining('دخول تجريبي سريع'));
    await tester.pumpAndSettle();

    // 1. Navigate to Marketplace Tab (index 1)
    await tester.tap(find.text('سوق التبادلات'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('سوق تبادلات الورديات'), findsOneWidget);
    expect(find.text('التبادل الآمن بين الزملاء'), findsOneWidget);
    expect(find.textContaining('طلب تبادل جديد'), findsOneWidget);

    // 2. Navigate to Financial Ledger Tab (index 2)
    await tester.tap(find.text('المحفظة والمالية'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('المحفظة المالية والديون (EGP)'), findsOneWidget);
    expect(find.text('كل المعاملات المالية'), findsOneWidget);
    expect(find.textContaining('تسجيل مطالبة / سلفة'), findsOneWidget);

    // 3. Navigate to Notifications Tab (index 3)
    await tester.tap(find.text('الطلبات والإشعارات'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('الطلبات والتنبيهات الحية'), findsOneWidget);
    expect(find.textContaining('موافقة على طلب التبادل'), findsOneWidget);
  });

  testWidgets('Rapid Batch Shift Planner allows fast monthly stamping and saving', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(
            Dio(
              BaseOptions(
                baseUrl: 'http://localhost:8000',
                connectTimeout: const Duration(milliseconds: 100),
                receiveTimeout: const Duration(milliseconds: 100),
              ),
            ),
          ),
        ],
        child: const ShiftakApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to calendar screen
    await tester.tap(find.text('تسجيل الدخول للمناوبات'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('دخول تجريبي سريع'));
    await tester.tap(find.textContaining('دخول تجريبي سريع'));
    await tester.pumpAndSettle();

    // Open AddEditShiftModal via the floating Add Shift button
    expect(find.text('إضافة مناوبة'), findsOneWidget);
    await tester.tap(find.text('إضافة مناوبة'));
    await tester.pumpAndSettle();

    // Verify modal opened in Batch Planner mode by default
    expect(find.text('إدارة مناوبات القسم'), findsOneWidget);
    expect(find.textContaining('جدولة سريعة (شهر كامل)'), findsOneWidget);
    expect(find.textContaining('اختر الختم النشط أولاً'), findsOneWidget);

    // Verify Active stamps are shown
    expect(find.textContaining('🔴 سهر (Night)'), findsOneWidget);
    expect(find.textContaining('🟢 طويل (Long)'), findsOneWidget);
    expect(find.textContaining('⚪ راحة (Off)'), findsOneWidget);

    // Tap on a day cell (e.g., day '5' on the grid) to stamp it with the active stamp (night)
    await tester.ensureVisible(find.text('5').first);
    await tester.tap(find.text('5').first);
    await tester.pump();

    // Switch active stamp to long and tap day '10'
    await tester.tap(find.textContaining('🟢 طويل (Long)'));
    await tester.pump();
    await tester.ensureVisible(find.text('10').first);
    await tester.tap(find.text('10').first);
    await tester.pump();

    // Save batch shifts
    final saveButton = find.textContaining('اعتماد وحفظ المناوبات دفعة واحدة');
    expect(saveButton, findsOneWidget);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // wait for save and snackbar

    // Verify SnackBar success feedback
    expect(find.textContaining('تم اعتماد وحفظ'), findsOneWidget);
  });
}
