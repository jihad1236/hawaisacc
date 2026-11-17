import 'package:flutter/material.dart';
import 'package:hawiisaac/features/authentication/model/auth_token_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _tokenTypeKey = 'auth_token_type';
  static const String _usernameKey = 'auth_username';
  static const String _themeModeKey = 'theme_mode';
  static const String _hasSelectedUnitsKey = 'has_selected_units';
  static const String _bookmarkedExpertTipsKey = 'bookmarked_expert_tips_ids';

  static String _accessToken = '';
  static String _refreshToken = '';
  static String _username = '';
  static String _tokenType = 'bearer';
  static ThemeMode _themeMode = ThemeMode.system;
  static bool _hasSelectedUnits = false;
  static Set<int> _bookmarkedExpertTipIds = <int>{};

  static String get accessToken => _accessToken;
  static String get refreshToken => _refreshToken;
  static String get username => _username;
  static String get tokenType => _tokenType;
  static ThemeMode get themeMode => _themeMode;
  static bool get hasSelectedUnits => _hasSelectedUnits;
  static bool get hasAccessToken => _accessToken.isNotEmpty;
  static bool get hasRefreshToken => _refreshToken.isNotEmpty;
  static bool get hasAuthTokens => hasAccessToken && hasRefreshToken;

  static bool isExpertTipBookmarked(int id) =>
      _bookmarkedExpertTipIds.contains(id);

  static Set<int> get bookmarkedExpertTipIds =>
      Set.unmodifiable(_bookmarkedExpertTipIds);

  static Future<bool> toggleExpertTipBookmark(int id) async {
    final preferences = await SharedPreferences.getInstance();
    final isSaved = _bookmarkedExpertTipIds.contains(id);
    if (isSaved) {
      _bookmarkedExpertTipIds.remove(id);
    } else {
      _bookmarkedExpertTipIds.add(id);
    }
    await preferences.setStringList(
      _bookmarkedExpertTipsKey,
      _bookmarkedExpertTipIds.map((e) => e.toString()).toList(),
    );
    return !isSaved;
  }

  static Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    _accessToken = preferences.getString(_accessTokenKey) ?? '';
    _refreshToken = preferences.getString(_refreshTokenKey) ?? '';
    _tokenType = preferences.getString(_tokenTypeKey) ?? 'bearer';
    _username = preferences.getString(_usernameKey) ?? '';
    _themeMode = _themeModeFromValue(preferences.getString(_themeModeKey));
    _hasSelectedUnits = preferences.getBool(_hasSelectedUnitsKey) ?? false;
    final savedTipIds =
        preferences.getStringList(_bookmarkedExpertTipsKey) ?? const [];
    _bookmarkedExpertTipIds = savedTipIds
        .map((e) => int.tryParse(e) ?? 0)
        .where((e) => e > 0)
        .toSet();
    debugPrint(
      'Auth storage init: hasTokens=$hasAuthTokens, '
      'username=$_username, '
      'hasSelectedUnits=$_hasSelectedUnits, '
      'bookmarkedTips=${_bookmarkedExpertTipIds.length}, '
      'access=${_tokenPreview(_accessToken)}, '
      'refresh=${_tokenPreview(_refreshToken)}',
    );
  }

  static Future<void> updateAccessToken(String token) async {
    _accessToken = token;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accessTokenKey, token);
  }

  static Future<void> saveUsername(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return;
    _username = clean;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_usernameKey, clean);
  }

  static Future<bool> saveAuthSession(AuthTokenResponse response) async {
    if (response.accessToken.isEmpty || response.refreshToken.isEmpty) {
      debugPrint(
        'Auth session save skipped: empty token received, '
        'access=${_tokenPreview(response.accessToken)}, '
        'refresh=${_tokenPreview(response.refreshToken)}',
      );
      return false;
    }

    _accessToken = response.accessToken;
    _refreshToken = response.refreshToken;
    _tokenType = response.tokenType;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accessTokenKey, _accessToken);
    await preferences.setString(_refreshTokenKey, _refreshToken);
    await preferences.setString(_tokenTypeKey, _tokenType);

    if (response.username.isNotEmpty) {
      _username = response.username.trim();
      await preferences.setString(_usernameKey, _username);
    }

    debugPrint(
      'Auth session saved: tokenType=$_tokenType, username=$_username, '
      'access=${_tokenPreview(_accessToken)}, '
      'refresh=${_tokenPreview(_refreshToken)}',
    );
    return true;
  }

  static Future<void> setHasSelectedUnits(bool value) async {
    _hasSelectedUnits = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_hasSelectedUnitsKey, value);
    debugPrint('Auth storage setHasSelectedUnits: $value');
  }

  static Future<void> clearAuthSession() async {
    _accessToken = '';
    _refreshToken = '';
    _tokenType = 'bearer';
    _hasSelectedUnits = false;

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
    await preferences.remove(_tokenTypeKey);
    await preferences.remove(_hasSelectedUnitsKey);
    debugPrint('Auth session cleared');
  }

  static Future<void> saveThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, themeMode.name);
  }

  static ThemeMode _themeModeFromValue(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _tokenPreview(String token) {
    if (token.isEmpty) return 'empty';
    if (token.length <= 12) return 'len=${token.length}';

    return '${token.substring(0, 6)}...${token.substring(token.length - 6)} '
        '(len=${token.length})';
  }
}
