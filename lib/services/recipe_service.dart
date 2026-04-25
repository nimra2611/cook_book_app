import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Service class responsible ONLY for API communication
/// Single Responsibility: Handle HTTP requests to TheMealDB API
class RecipeService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  
  final http.Client _client;
  
  RecipeService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all categories from API
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/categories.php'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = data['categories'] as List<dynamic>;
        return categories
            .map((cat) => CategoryModel.fromTheMealDb(cat))
            .toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Fetch category names only (for backward compatibility)
  Future<List<String>> fetchCategoryNames() async {
    final categories = await fetchCategories();
    return categories.map((c) => c.name).toList();
  }

  /// Fetch a random meal from API
  Future<RecipeModel?> fetchRandomMeal() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/random.php'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List<dynamic>;
        if (meals.isNotEmpty) {
          return RecipeModel.fromTheMealDb(meals[0]);
        }
        return null;
      } else {
        throw Exception('Failed to load random meal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching random meal: $e');
    }
  }

  /// Search meals by name from API
  Future<List<RecipeModel>> searchMeals(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/search.php?s=$query'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'];
        
        if (meals == null) return [];
        
        return (meals as List<dynamic>)
            .map((meal) => RecipeModel.fromTheMealDb(meal))
            .toList();
      } else {
        throw Exception('Failed to search meals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching meals: $e');
    }
  }

  /// Get meal details by ID from API
  Future<RecipeModel?> fetchMealById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/lookup.php?i=$id'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List<dynamic>;
        
        if (meals.isNotEmpty) {
          return RecipeModel.fromTheMealDb(meals[0]);
        }
        return null;
      } else {
        throw Exception('Failed to load meal details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching meal details: $e');
    }
  }

  /// Get meals by category from API (returns basic info)
  Future<List<RecipeModel>> fetchMealsByCategory(String category) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/filter.php?c=$category'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'];
        
        if (meals == null) return [];
        
        // Filter only returns id, name, and thumbnail
        final mealList = meals as List<dynamic>;
        
        // Convert to RecipeModel with limited data
        return mealList.map((meal) {
          return RecipeModel(
            id: meal['idMeal'].toString(),
            title: meal['strMeal'].toString(),
            category: category,
            time: '30m',
            rating: 4,
            imagePath: meal['strMealThumb'].toString(),
          );
        }).toList();
      } else {
        throw Exception('Failed to load meals by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching meals by category: $e');
    }
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
