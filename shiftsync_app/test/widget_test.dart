import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftsync_app/main.dart';

void main() {
  testWidgets('ShiftSyncApp Arabic token showcase screen renders correctly', (WidgetTester tester) async {
    // Build our Arabic-First app inside ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ShiftSyncApp(),
      ),
    );

    // Allow Google Fonts and localization delegates to settle
    await tester.pumpAndSettle();

    // Verify that our Arabic headings render properly using exact matching where appropriate
    expect(find.textContaining('نظام شِفْت سينك'), findsOneWidget);
    expect(find.textContaining('كمال سرور'), findsOneWidget);
    expect(find.textContaining('الورديات القادمة هذا الأسبوع'), findsOneWidget);
    expect(find.text('صباحية طويلة'), findsOneWidget);
    expect(find.text('سهر ليلي'), findsOneWidget);
    expect(find.text('عليا فلوس (I OWE)'), findsOneWidget);
    expect(find.text('ليا فلوس (OWED TO ME)'), findsOneWidget);
  });
}
