import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import '../services/recipe_repository.dart';
import '../utils/constants.dart';
import '../widgets/rating_stars.dart';

/// Screen for browsing recipes by category
class CategoryBrowserScreen extends StatefulWidget {
  const CategoryBrowserScreen({super.key});

  @override
  State<CategoryBrowserScreen> createState() => _CategoryBrowserScreenState();
}

class _CategoryBrowserScreenState extends State<CategoryBrowserScreen> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  
  bool _isLoading = true;
  Map<String, List<Recipe>> _categoryGroups = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _recipeRepository.getCategories();
      final groups = <String, List<Recipe>>{};
      
      for (final category in categories) {
        final recipes = await _recipeRepository.getMealsByCategory(category);
        if (recipes.isNotEmpty) {
          groups[category] = recipes;
        }
      }
      
      if (mounted) {
        setState(() {
          _categoryGroups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Browse by Category',
          style: AppTextStyles.titleSmall,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _categoryGroups.entries.map((entry) {
                  return _buildCategoryGroup(
                    context,
                    entry.key,
                    _getCategoryIcon(entry.key),
                    _getCategoryColor(entry.key),
                    entry.value,
                  );
                }).toList(),
              ),
            ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Breakfast':
        return Icons.wb_sunny;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      case 'Dessert':
        return Icons.cake;
      default:
        return Icons.restaurant;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Breakfast':
        return AppColors.accentOrange;
      case 'Lunch':
        return AppColors.primary;
      case 'Dinner':
        return AppColors.accentPurple;
      case 'Dessert':
        return AppColors.favorite;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildCategoryGroup(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Recipe> recipes,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.titleSmall),
              const SizedBox(width: 6),
              Text(
                '(${recipes.length})',
                style: AppTextStyles.bodySmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text('See All', style: TextStyle(color: color, fontSize: 14)),
                    Icon(Icons.chevron_right, color: color, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recipes.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildRecipeCard(recipes[0])),
                if (recipes.length > 1) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _buildRecipeCard(recipes[1])),
                ],
              ],
            ),
          if (recipes.length > 2) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildRecipeCard(recipes[2])),
                if (recipes.length > 3) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _buildRecipeCard(recipes[3])),
                ] else ...[
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: recipe.imagePath,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 120,
                    color: Colors.white10,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 120,
                    color: Colors.white10,
                    child: const Icon(Icons.fastfood, color: Colors.white24),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black38,
                  child: Icon(
                    recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: recipe.isFavorite ? AppColors.favorite : Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 6),
                RatingStars(
                  rating: recipe.rating,
                  size: 12,
                  showValue: true,
                  ratingValue: '${recipe.rating}.0',
                ),
                if (recipe.difficulty != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          recipe.difficulty!,
                          style: const TextStyle(
                            color: AppColors.successLight,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.access_time,
                        color: AppColors.textSecondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        recipe.time,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
