import 'api_service.dart';
import 'preferences_service.dart';
import '../models/recipe.dart';

/// Repository for managing recipes with API integration
class RecipeRepository {
  final ApiService _apiService;
  final PreferencesService _preferencesService;

  // Cache for categories
  List<String>? _cachedCategories;
  
  // Cache for meals by category
  final Map<String, List<Recipe>> _mealsByCategoryCache = {};

  RecipeRepository({
    ApiService? apiService,
    PreferencesService? preferencesService,
  })  : _apiService = apiService ?? ApiService(),
        _preferencesService = preferencesService ?? PreferencesService();

  /// Get favorite meal IDs from storage
  Future<Set<String>> getFavoriteIds() async {
    await _preferencesService.init();
    return _preferencesService.getFavoriteMealIds();
  }

  /// Check if a meal is favorite
  Future<bool> isFavorite(String id) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(id);
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    final favorites = await getFavoriteIds();
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    await _preferencesService.setFavoriteMealIds(favorites);
  }

  /// Get all categories (from API or cache)
  Future<List<String>> getCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    try {
      final categories = await _apiService.getCategories();
      _cachedCategories = categories;
      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  /// Get a random meal for featured section
  Future<Recipe?> getRandomMeal() async {
    try {
      final favoriteIds = await getFavoriteIds();
      final meal = await _apiService.getRandomMeal(
        isFavorite: favoriteIds.isNotEmpty && favoriteIds.contains(null),
      );
      
      if (meal != null) {
        final isFav = await isFavorite(meal.id);
        return meal.copyWith(isFavorite: isFav);
      }
      return null;
    } catch (e) {
      print('Error fetching random meal: $e');
      return null;
    }
  }

  /// Search meals by name
  Future<List<Recipe>> searchMeals(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final favoriteIds = await getFavoriteIds();
      return await _apiService.searchMeals(query, favoriteIds: favoriteIds);
    } catch (e) {
      print('Error searching meals: $e');
      return [];
    }
  }

  /// Get meal by ID
  Future<Recipe?> getMealById(String id) async {
    try {
      final isFav = await isFavorite(id);
      return await _apiService.getMealById(id, isFavorite: isFav);
    } catch (e) {
      print('Error fetching meal by ID: $e');
      return null;
    }
  }

  /// Get meals by category
  Future<List<Recipe>> getMealsByCategory(String category) async {
    if (category == 'All') {
      // For "All" category, fetch from multiple categories
      return _getAllMeals();
    }

    // Check cache first
    if (_mealsByCategoryCache.containsKey(category)) {
      return _mealsByCategoryCache[category]!;
    }

    try {
      final favoriteIds = await getFavoriteIds();
      final recipes = await _apiService.getMealsByCategory(
        category,
        favoriteIds: favoriteIds,
      );
      
      // Cache the result
      _mealsByCategoryCache[category] = recipes;
      return recipes;
    } catch (e) {
      print('Error fetching meals by category: $e');
      return [];
    }
  }

  /// Get all meals (fetch from multiple categories)
  Future<List<Recipe>> _getAllMeals() async {
    final allRecipes = <Recipe>[];
    final categories = _cachedCategories ?? await getCategories();
    
    for (final category in categories.take(5)) { // Limit to 5 categories to avoid too many API calls
      try {
        final recipes = await getMealsByCategory(category);
        allRecipes.addAll(recipes);
      } catch (e) {
        print('Error fetching meals for category $category: $e');
      }
    }
    
    return allRecipes;
  }

  /// Clear caches
  void clearCache() {
    _cachedCategories = null;
    _mealsByCategoryCache.clear();
  }

  /// Dispose resources
  void dispose() {
    _apiService.dispose();
  }
}
