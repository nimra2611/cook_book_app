/// Represents a meal category
class CategoryModel {
  final String id;
  final String name;
  final String? thumbnail;
  final String? description;

  const CategoryModel({
    required this.id,
    required this.name,
    this.thumbnail,
    this.description,
  });

  /// Create CategoryModel from TheMealDB API response
  factory CategoryModel.fromTheMealDb(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['idCategory']?.toString() ?? '',
      name: json['strCategory']?.toString() ?? '',
      thumbnail: json['strCategoryThumb'],
      description: json['strCategoryDescription'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'idCategory': id,
      'strCategory': name,
      'strCategoryThumb': thumbnail,
      'strCategoryDescription': description,
    };
  }

  @override
  String toString() => 'CategoryModel(name: $name)';
}
