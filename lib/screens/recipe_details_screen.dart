import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import '../services/recipe_repository.dart';
import '../utils/constants.dart';
import '../widgets/rating_stars.dart';


class RecipeDetailsScreen extends StatefulWidget {
  final String? recipeId;

  const RecipeDetailsScreen({
    super.key,
    this.recipeId,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  
  bool _isLoading = true;
  Recipe? _recipe;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    if (widget.recipeId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No recipe ID provided';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recipe = await _recipeRepository.getMealById(widget.recipeId!);
      if (mounted) {
        setState(() {
          _recipe = recipe;
          _isLoading = false;
          if (recipe == null) {
            _errorMessage = 'Recipe not found';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load recipe details';
        });
      }
    }
  }

  void _toggleFavorite(Recipe recipe) async {
    await _recipeRepository.toggleFavorite(recipe.id);
    await _loadRecipe();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || _recipe == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Recipe not found',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final recipe = _recipe!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(recipe),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recipe.title, style: AppTextStyles.headingLarge),
                      const SizedBox(height: 12),
                      _buildRecipeMeta(recipe),
                      const SizedBox(height: 32),
                      Text('Ingredients', style: AppTextStyles.titleSmall),
                      const SizedBox(height: 16),
                      ...recipe.ingredients.map(
                        (i) => _buildIngredientTile(i),
                      ),
                      const SizedBox(height: 32),
                      Text('Instructions', style: AppTextStyles.titleSmall),
                      const SizedBox(height: 16),
                      ...recipe.instructions.asMap().entries.map(
                        (e) => _buildStep(e.key + 1, e.value),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomActions(recipe),
        ],
      ),
    );
  }

  Widget _buildAppBar(Recipe recipe) {
    return SliverAppBar(
      expandedHeight: 350,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: const BackButton(color: AppColors.textPrimary),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.3),
            child: IconButton(
              icon: Icon(
                recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: recipe.isFavorite
                    ? AppColors.favorite
                    : AppColors.textPrimary,
                size: 20,
              ),
              onPressed: () => _toggleFavorite(recipe),
            ),
          ),
        ),
      ],
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: recipe.imagePath,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[900],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[900],
            child: const Icon(Icons.broken_image, color: Colors.white24),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeMeta(Recipe recipe) {
    return Row(
      children: [
        RatingStars(rating: recipe.rating, size: 18),
        const SizedBox(width: 8),
        Text('${recipe.rating}.0', style: AppTextStyles.bodySmall),
        const SizedBox(width: 15),
        if (recipe.difficulty != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.star.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              recipe.difficulty!,
              style: const TextStyle(
                color: AppColors.star,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const Spacer(),
        const Icon(
          Icons.access_time,
          color: AppColors.textSecondary,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(recipe.time, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildIngredientTile(Ingredient ingredient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            ingredient.isChecked
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  ingredient.amount,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.white.withOpacity(0.08),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textMuted,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(Recipe recipe) {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                elevation: 8,
                shadowColor: AppColors.primary.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.local_fire_department, size: 20),
              label: const Text(
                'Start Cooking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.textPrimary, size: 24),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}