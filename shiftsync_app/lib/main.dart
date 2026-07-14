import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveCacheService.init();

  runApp(
    const ProviderScope(
      child: ShiftakApp(),
    ),
  );
}

class ShiftakApp extends StatelessWidget {
  const ShiftakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shiftak • شِفْتَك',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const WelcomeScreen(),
    );
  }
}
