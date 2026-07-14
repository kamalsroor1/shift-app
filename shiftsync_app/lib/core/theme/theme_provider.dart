import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Riverpod NotifierProvider for managing and persisting ThemeMode (`light`, `dark`, `system`).
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _boxName = 'theme_settings_box';
  static const String _themeKey = 'user_theme_mode';

  @override
  ThemeMode build() {
    _initAndLoadTheme();
    return ThemeMode.light;
  }

  void _initAndLoadTheme() {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box(_boxName);
        final String? savedTheme = box.get(_themeKey) as String?;
        if (savedTheme != null) {
          state = _parseThemeMode(savedTheme);
        }
      } else {
        Hive.openBox(_boxName).then((box) {
          final String? savedTheme = box.get(_themeKey) as String?;
          if (savedTheme != null) {
            state = _parseThemeMode(savedTheme);
          }
        }).catchError((e) {
          debugPrint('Error opening theme box safely: $e');
        });
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
      }
      final box = Hive.box(_boxName);
      await box.put(_themeKey, mode.name);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  ThemeMode _parseThemeMode(String modeStr) {
    switch (modeStr) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }
}
