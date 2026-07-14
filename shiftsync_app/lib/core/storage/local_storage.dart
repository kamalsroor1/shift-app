import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// SecureStorageService — Manages JWT token pair and user credentials securely.
class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'jwt_access_token';
  static const _refreshTokenKey = 'jwt_refresh_token';
  static const _userPhoneKey = 'user_phone';
  static const _userIdKey = 'user_id';

  Future<void> saveTokenPair(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);

  Future<void> saveUserInfo(String phone, String userId) async {
    await _storage.write(key: _userPhoneKey, value: phone);
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserPhone() async => await _storage.read(key: _userPhoneKey);
  Future<String?> getUserId() async => await _storage.read(key: _userIdKey);

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

/// HiveCacheService — Manages offline box storage for schedules, EGP ledger snapshots, and theme preferences.
class HiveCacheService {
  static const String scheduleBoxName = 'schedule_cache_box';
  static const String ledgerBoxName = 'ledger_cache_box';
  static const String themeBoxName = 'theme_settings_box';

  static Future<void> init({String? testPath}) async {
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }
    await Hive.openBox(scheduleBoxName);
    await Hive.openBox(ledgerBoxName);
    await Hive.openBox(themeBoxName);
  }

  static Box getScheduleBox() => Hive.box(scheduleBoxName);
  static Box getLedgerBox() => Hive.box(ledgerBoxName);
  static Box getThemeBox() => Hive.box(themeBoxName);

  static Future<void> clearCache() async {
    await getScheduleBox().clear();
    await getLedgerBox().clear();
  }
}
