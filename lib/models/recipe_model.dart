import 'ingredient.dart';

/// Main recipe model following Single Responsibility Principle
/// Only responsible for holding recipe data and serialization
class RecipeModel {
  final String id;
  final String title;
  final String category;
  final String time;
  final int rating;
  final String imagePath;
  final bool isFavorite;
  final bool isFeatured;
  final String? difficulty;
  final List<Ingredient> ingredients;
  final List<String> instructions;

  const RecipeModel({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    required this.rating,
    required this.imagePath,
    this.isFavorite = false,
    this.isFeatured = false,
    this.difficulty,
    this.ingredients = const [],
    this.instructions = const [],
  });

  /// Create RecipeModel from TheMealDB API response
  factory RecipeModel.fromTheMealDb(Map<String, dynamic> json, {bool isFavorite = false}) {
    return RecipeModel(
      id: json['idMeal']?.toString() ?? '',
      title: json['strMeal']?.toString() ?? 'Unknown Meal',
      category: _mapCategory(json['strCategory']?.toString()),
      time: _parseCookingTime(json),
      rating: _parseRating(json),
      imagePath: json['strMealThumb']?.toString() ?? '',
      isFavorite: isFavorite,
      difficulty: json['strDifficulty']?.toString(),
      ingredients: _parseIngredients(json),
      instructions: _parseInstructions(json),
    );
  }

  /// Create RecipeModel from JSON
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      time: json['time'] as String? ?? '30m',
      rating: json['rating'] as int? ?? 4,
      imagePath: json['imagePath'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      difficulty: json['difficulty'] as String?,
      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
              .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
      instructions: json['instructions'] != null
          ? (json['instructions'] as List).map((s) => s.toString()).toList()
          : [],
    );
  }

  /// Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'time': time,
      'rating': rating,
      'imagePath': imagePath,
      'isFavorite': isFavorite,
      'isFeatured': isFeatured,
      'difficulty': difficulty,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
    };
  }

  /// Map TheMealDB categories to app categories
  static String _mapCategory(String? apiCategory) {
    if (apiCategory == null) return 'Dinner';
    
    switch (apiCategory.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lamb':
      case 'chicken':
      case 'beef':
      case 'pork':
      case 'fish':
      case 'seafood':
        return 'Dinner';
      case 'vegetarian':
      case 'vegan':
      case 'side':
      case 'starter':
        return 'Lunch';
      case 'dessert':
        return 'Dessert';
      default:
        return 'Dinner';
    }
  }

  /// Parse cooking time from API data
  static String _parseCookingTime(Map<String, dynamic> json) {
    return '${json['strPrepTime']?.toString() ?? '30'}m';
  }

  /// Parse rating (TheMealDB doesn't have ratings, use default)
  static int _parseRating(Map<String, dynamic> json) {
    return 4;
  }

  /// Parse ingredients from TheMealDB response
  static List<Ingredient> _parseIngredients(Map<String, dynamic> json) {
    final ingredients = <Ingredient>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString().trim();
      final measure = json['strMeasure$i']?.toString().trim();
      
      if (ingredient != null && 
          ingredient.isNotEmpty && 
          measure != null && 
          measure.isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredient,
          amount: measure,
        ));
      }
    }
    return ingredients;
  }

  /// Parse instructions from TheMealDB response
  static List<String> _parseInstructions(Map<String, dynamic> json) {
    final instructionsStr = json['strInstructions']?.toString() ?? '';
    final instructionsList = instructionsStr
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();
    
    return instructionsList.isEmpty ? [instructionsStr] : instructionsList;
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? category,
    String? time,
    int? rating,
    String? imagePath,
    bool? isFavorite,
    bool? isFeatured,
    String? difficulty,
    List<Ingredient>? ingredients,
    List<String>? instructions,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      time: time ?? this.time,
      rating: rating ?? this.rating,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      isFeatured: isFeatured ?? this.isFeatured,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  String toString() => 'RecipeModel(title: $title, category: $category)';
}
