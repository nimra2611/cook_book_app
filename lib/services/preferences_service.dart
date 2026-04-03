import 'package:shared_preferences/shared_preferences.dart';


class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  static const String _darkThemeKey = 'dark_theme';
  static const String _compactCardsKey = 'compact_cards';
  static const String _favoriteMealIdsKey = 'favorite_meal_ids';

  static const String _cookingNotificationsKey = 'cooking_notifications';
  static const String _autoSyncKey = 'auto_sync';

  static const String _defaultCategoryKey = 'default_category';

  bool get isDarkTheme => _prefs?.getBool(_darkThemeKey) ?? true;

  Future<void> setDarkTheme(bool value) async {
    await _prefs?.setBool(_darkThemeKey, value);
  }

  bool get isCompactCards => _prefs?.getBool(_compactCardsKey) ?? false;

  Future<void> setCompactCards(bool value) async {
    await _prefs?.setBool(_compactCardsKey, value);
  }

  bool get isCookingNotificationsEnabled =>
      _prefs?.getBool(_cookingNotificationsKey) ?? true;

  Future<void> setCookingNotifications(bool value) async {
    await _prefs?.setBool(_cookingNotificationsKey, value);
  }

  bool get isAutoSyncEnabled => _prefs?.getBool(_autoSyncKey) ?? false;

  Future<void> setAutoSync(bool value) async {
    await _prefs?.setBool(_autoSyncKey, value);
  }

  String get defaultCategory => _prefs?.getString(_defaultCategoryKey) ?? 'Lunch';

  Future<void> setDefaultCategory(String value) async {
    await _prefs?.setString(_defaultCategoryKey, value);
  }

  /// Get favorite meal IDs
  Set<String> getFavoriteMealIds() {
    return Set<String>.from(_prefs?.getStringList(_favoriteMealIdsKey) ?? []);
  }

  /// Set favorite meal IDs
  Future<void> setFavoriteMealIds(Set<String> ids) async {
    await _prefs?.setStringList(_favoriteMealIdsKey, ids.toList());
  }

  /// Add a favorite meal ID
  Future<void> addFavoriteMealId(String id) async {
    final favorites = getFavoriteMealIds();
    favorites.add(id);
    await setFavoriteMealIds(favorites);
  }

  /// Remove a favorite meal ID
  Future<void> removeFavoriteMealId(String id) async {
    final favorites = getFavoriteMealIds();
    favorites.remove(id);
    await setFavoriteMealIds(favorites);
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
