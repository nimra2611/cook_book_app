import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_repository.dart';
import '../utils/constants.dart';
import '../widgets/recipe_card.dart';

/// Screen displaying favorite recipes
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  
  bool _isLoading = true;
  List<Recipe> _favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favoriteIds = await _recipeRepository.getFavoriteIds();
      final favorites = <Recipe>[];
      
      for (final id in favoriteIds) {
        final recipe = await _recipeRepository.getMealById(id);
        if (recipe != null) {
          favorites.add(recipe);
        }
      }
      
      if (mounted) {
        setState(() {
          _favoriteRecipes = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleFavorite(Recipe recipe) async {
    await _recipeRepository.toggleFavorite(recipe.id);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final recipes = _favoriteRecipes;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Favorites', style: AppTextStyles.headingMedium),
                    _buildFilterButton(),
                  ],
                ),
              ),
            ),
            if (recipes.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No favorites yet',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => RecipeCard(
                      recipe: recipes[index],
                      onFavoriteTap: () => _toggleFavorite(recipes[index]),
                    ),
                    childCount: recipes.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 18, color: AppColors.primaryAlt),
          const SizedBox(width: 8),
          const Text(
            'Cook time (low → high)',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }
}
