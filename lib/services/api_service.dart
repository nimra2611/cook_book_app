import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

/// API service for TheMealDB
class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/categories.php'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = data['categories'] as List<dynamic>;
        return categories.map((cat) => cat['strCategory'].toString()).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Fetch a random meal
  Future<Recipe?> getRandomMeal({bool isFavorite = false}) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/random.php'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List<dynamic>;
        if (meals.isNotEmpty) {
          return Recipe.fromTheMealDb(meals[0], isFavorite: isFavorite);
        }
        return null;
      } else {
        throw Exception('Failed to load random meal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching random meal: $e');
    }
  }

  /// Search meals by name
  Future<List<Recipe>> searchMeals(String query, {Set<String>? favoriteIds}) async {
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
            .map((meal) => Recipe.fromTheMealDb(
                  meal,
                  isFavorite: favoriteIds?.contains(meal['idMeal']) ?? false,
                ))
            .toList();
      } else {
        throw Exception('Failed to search meals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching meals: $e');
    }
  }

  /// Get meal by ID
  Future<Recipe?> getMealById(String id, {bool isFavorite = false}) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/lookup.php?i=$id'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List<dynamic>;
        
        if (meals.isNotEmpty) {
          return Recipe.fromTheMealDb(meals[0], isFavorite: isFavorite);
        }
        return null;
      } else {
        throw Exception('Failed to load meal details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching meal details: $e');
    }
  }

  /// Get meals by category
  Future<List<Recipe>> getMealsByCategory(
    String category, {
    Set<String>? favoriteIds,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/filter.php?c=$category'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'];
        
        if (meals == null) return [];
        
        // Filter only returns id, name, and thumbnail
        // Need to fetch full details for each meal
        final mealList = meals as List<dynamic>;
        final recipes = <Recipe>[];
        
        for (var meal in mealList) {
          final fullRecipe = await getMealById(
            meal['idMeal'].toString(),
            isFavorite: favoriteIds?.contains(meal['idMeal']) ?? false,
          );
          if (fullRecipe != null) {
            recipes.add(fullRecipe);
          }
        }
        
        return recipes;
      } else {
        throw Exception('Failed to load meals by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching meals by category: $e');
    }
  }

  /// Dispose the client
  void dispose() {
    _client.close();
  }
}
