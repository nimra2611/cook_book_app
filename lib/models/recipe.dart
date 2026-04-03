
class Recipe {
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

  const Recipe({
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

  /// Create Recipe from TheMealDB API response
  factory Recipe.fromTheMealDb(Map<String, dynamic> json, {bool isFavorite = false}) {
    // Extract ingredients (strIngredient1-20 with corresponding measures)
    final ingredients = <Ingredient>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString().trim();
      final measure = json['strMeasure$i']?.toString().trim();
      
      if (ingredient != null && ingredient.isNotEmpty && measure != null && measure.isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredient,
          amount: measure,
        ));
      }
    }

    // Parse instructions into steps
    final instructionsStr = json['strInstructions']?.toString() ?? '';
    final instructionsList = instructionsStr
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();

    // Map category or use a default
    String category = json['strCategory']?.toString() ?? 'Dinner';
    
    return Recipe(
      id: json['idMeal']?.toString() ?? '',
      title: json['strMeal']?.toString() ?? 'Unknown Meal',
      category: _mapCategory(category),
      time: _parseCookingTime(json),
      rating: _parseRating(json),
      imagePath: json['strMealThumb']?.toString() ?? '',
      isFavorite: isFavorite,
      difficulty: json['strDifficulty'] != null 
          ? json['strDifficulty'].toString() 
          : null,
      ingredients: ingredients,
      instructions: instructionsList.isEmpty 
          ? [instructionsStr] 
          : instructionsList,
    );
  }

  /// Map TheMealDB categories to app categories
  static String _mapCategory(String apiCategory) {
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
    // TheMealDB doesn't provide cook time, estimate based on complexity
    return '${json['strPrepTime']?.toString() ?? '30'}m';
  }

  /// Parse rating (TheMealDB doesn't have ratings, use default)
  static int _parseRating(Map<String, dynamic> json) {
    return 4; // Default rating
  }

  Recipe copyWith({
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
    return Recipe(
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
}

class Ingredient {
  final String name;
  final String amount;
  final bool isChecked;

  const Ingredient({
    required this.name,
    required this.amount,
    this.isChecked = false,
  });

  Ingredient copyWith({
    String? name,
    String? amount,
    bool? isChecked,
  }) {
    return Ingredient(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
