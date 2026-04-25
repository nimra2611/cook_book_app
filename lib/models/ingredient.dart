/// Represents a single ingredient with name and amount
class Ingredient {
  final String name;
  final String amount;
  final bool isChecked;

  const Ingredient({
    required this.name,
    required this.amount,
    this.isChecked = false,
  });

  /// Create Ingredient from JSON
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      amount: json['amount'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'isChecked': isChecked,
    };
  }

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

  @override
  String toString() => '$name ($amount)';
}
