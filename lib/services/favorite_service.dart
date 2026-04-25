import 'package:shared_preferences/shared_preferences.dart';

/// Service class responsible ONLY for managing favorites
/// Single Responsibility: Handle favorite state persistence
class FavoriteService {
  static const String _favoriteIdsKey = 'favorite_meal_ids';
  
  SharedPreferences? _prefs;
  Set<String>? _cachedFavorites;

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _cachedFavorites = getFavoriteIds();
  }

  /// Get all favorite meal IDs
  Set<String> getFavoriteIds() {
    return Set<String>.from(_prefs?.getStringList(_favoriteIdsKey) ?? []);
  }

  /// Check if a meal is favorited
  bool isFavorite(String id) {
    return getFavoriteIds().contains(id);
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    final favorites = getFavoriteIds();
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    await _prefs?.setStringList(_favoriteIdsKey, favorites.toList());
    _cachedFavorites = favorites;
  }

  /// Add a favorite meal ID
  Future<void> addFavorite(String id) async {
    final favorites = getFavoriteIds();
    if (!favorites.contains(id)) {
      favorites.add(id);
      await _prefs?.setStringList(_favoriteIdsKey, favorites.toList());
      _cachedFavorites = favorites;
    }
  }

  /// Remove a favorite meal ID
  Future<void> removeFavorite(String id) async {
    final favorites = getFavoriteIds();
    if (favorites.contains(id)) {
      favorites.remove(id);
      await _prefs?.setStringList(_favoriteIdsKey, favorites.toList());
      _cachedFavorites = favorites;
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    await _prefs?.remove(_favoriteIdsKey);
    _cachedFavorites = {};
  }

  /// Get cached favorites (faster, no disk read)
  Set<String> getCachedFavorites() {
    return _cachedFavorites ?? getFavoriteIds();
  }
}
