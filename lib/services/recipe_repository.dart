import '../models/models.dart';
import 'recipe_service.dart';
import 'favorite_service.dart';

/// Repository class responsible for business logic
/// Single Responsibility: Orchestrate services and manage data flow
class RecipeRepository {
  final RecipeService _apiService;
  final FavoriteService _favoriteService;

  // Cache for categories
  List<String>? _cachedCategories;
  
  // Cache for meals by category
  final Map<String, List<RecipeModel>> _mealsByCategoryCache = {};

  RecipeRepository({
    RecipeService? apiService,
    FavoriteService? favoriteService,
  })  : _apiService = apiService ?? RecipeService(),
        _favoriteService = favoriteService ?? FavoriteService();

  /// Initialize repository
  Future<void> init() async {
    await _favoriteService.init();
  }

  // ==================== FAVORITES ====================

  /// Check if a meal is favorited
  bool isFavorite(String id) {
    return _favoriteService.isFavorite(id);
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    await _favoriteService.toggleFavorite(id);
  }

  /// Get all favorite IDs
  Set<String> getFavoriteIds() {
    return _favoriteService.getFavoriteIds();
  }

  /// Get all favorite recipes with full details
  Future<List<RecipeModel>> getFavoriteRecipes() async {
    final favoriteIds = _favoriteService.getFavoriteIds();
    final favorites = <RecipeModel>[];
    
    for (final id in favoriteIds) {
      try {
        final recipe = await _apiService.fetchMealById(id);
        if (recipe != null) {
          favorites.add(recipe.copyWith(isFavorite: true));
        }
      } catch (e) {
        print('Error loading favorite $id: $e');
      }
    }
    
    return favorites;
  }

  // ==================== CATEGORIES ====================

  /// Get all categories (from cache or API)
  Future<List<String>> getCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    try {
      final categories = await _apiService.fetchCategoryNames();
      _cachedCategories = categories;
      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  /// Get category models with full details
  Future<List<CategoryModel>> getCategoryModels() async {
    try {
      return await _apiService.fetchCategories();
    } catch (e) {
      print('Error fetching category models: $e');
      return [];
    }
  }

  // ==================== RECIPES ====================

  /// Get a random meal for featured section
  Future<RecipeModel?> getRandomMeal() async {
    try {
      final meal = await _apiService.fetchRandomMeal();
      
      if (meal != null) {
        final isFav = _favoriteService.isFavorite(meal.id);
        return meal.copyWith(isFavorite: isFav);
      }
      return null;
    } catch (e) {
      print('Error fetching random meal: $e');
      return null;
    }
  }

  /// Search meals by name
  Future<List<RecipeModel>> searchMeals(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final meals = await _apiService.searchMeals(query);
      
      // Update favorite status
      return meals.map((meal) {
        return meal.copyWith(
          isFavorite: _favoriteService.isFavorite(meal.id),
        );
      }).toList();
    } catch (e) {
      print('Error searching meals: $e');
      return [];
    }
  }

  /// Get meal by ID with full details
  Future<RecipeModel?> getMealById(String id) async {
    try {
      final meal = await _apiService.fetchMealById(id);
      
      if (meal != null) {
        final isFav = _favoriteService.isFavorite(id);
        return meal.copyWith(isFavorite: isFav);
      }
      return null;
    } catch (e) {
      print('Error fetching meal by ID: $e');
      return null;
    }
  }

  /// Get meals by category (with caching)
  Future<List<RecipeModel>> getMealsByCategory(String category) async {
    if (category == 'All') {
      return _getAllMeals();
    }

    // Check cache first
    if (_mealsByCategoryCache.containsKey(category)) {
      return _mealsByCategoryCache[category]!;
    }

    try {
      final recipes = await _apiService.fetchMealsByCategory(category);
      
      // Update favorite status
      final updatedRecipes = recipes.map((recipe) {
        return recipe.copyWith(
          isFavorite: _favoriteService.isFavorite(recipe.id),
        );
      }).toList();
      
      // Cache the result
      _mealsByCategoryCache[category] = updatedRecipes;
      return updatedRecipes;
    } catch (e) {
      print('Error fetching meals by category: $e');
      return [];
    }
  }

  /// Get all meals from multiple categories
  Future<List<RecipeModel>> _getAllMeals() async {
    final allRecipes = <RecipeModel>[];
    final categories = _cachedCategories ?? await getCategories();
    
    // Limit to first 5 categories to avoid too many API calls
    for (final category in categories.take(5)) {
      try {
        final recipes = await getMealsByCategory(category);
        allRecipes.addAll(recipes);
      } catch (e) {
        print('Error fetching meals for category $category: $e');
      }
    }
    
    return allRecipes;
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Clear all caches
  void clearCache() {
    _cachedCategories = null;
    _mealsByCategoryCache.clear();
  }

  /// Clear cache for specific category
  void clearCategoryCache(String category) {
    _mealsByCategoryCache.remove(category);
  }

  /// Dispose resources
  void dispose() {
    _apiService.dispose();
  }
}
