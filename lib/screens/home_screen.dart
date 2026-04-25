import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe.dart';
import '../services/recipe_repository.dart';
import '../utils/constants.dart';
import '../widgets/chip_filter.dart';
import '../widgets/recipe_card.dart';
import '../widgets/rating_stars.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final RecipeRepository _recipeRepository = RecipeRepository();
  
  bool _isLoading = true;
  bool _isLoadingMore = false;
  Recipe? _featuredRecipe;
  List<Recipe> _recipes = [];
  List<String> _categories = ['All'];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadCategories(),
        _loadFeaturedRecipe(),
        _loadRecipes(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data. Please check your connection.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _recipeRepository.getCategories();
    if (mounted) {
      setState(() {
        _categories = ['All', ...categories];
      });
    }
  }

  Future<void> _loadFeaturedRecipe() async {
    final recipe = await _recipeRepository.getRandomMeal();
    if (mounted && recipe != null) {
      setState(() {
        _featuredRecipe = recipe;
      });
    }
  }

  Future<void> _loadRecipes() async {
    List<Recipe> recipes;
    
    if (searchQuery.isNotEmpty) {
      recipes = await _recipeRepository.searchMeals(searchQuery);
    } else {
      recipes = await _recipeRepository.getMealsByCategory(selectedCategory);
    }
    
    if (mounted) {
      setState(() {
        _recipes = recipes;
      });
    }
  }

  Future<void> _onSearchChanged(String value) async {
    setState(() {
      searchQuery = value;
    });
    
    if (value.isEmpty) {
      await _loadRecipes();
    }
  }

  Future<void> _onCategorySelected(String category) async {
    if (category == selectedCategory) return;
    
    setState(() {
      selectedCategory = category;
      searchQuery = '';
    });
    
    await _loadRecipes();
  }

  void _toggleFavorite(Recipe recipe) async {
    await _recipeRepository.toggleFavorite(recipe.id);
    setState(() {});
    // Reload to update favorite status
    await _loadRecipes();
    if (_featuredRecipe?.id == recipe.id) {
      await _loadFeaturedRecipe();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.cardBackgroundAlt,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null && _recipes.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.cardBackgroundAlt,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[700]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final featured = searchQuery.isNotEmpty ? null : _featuredRecipe;
    final recipes = _recipes;

    return Scaffold(
      backgroundColor: AppColors.cardBackgroundAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          AppConstants.appName,
          style: AppTextStyles.headingMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            const SizedBox(height: 20),
            _buildCategoryChips(),
            const SizedBox(height: 25),
            if (featured != null) ...[
              Text('Featured', style: AppTextStyles.titleLarge),
              const SizedBox(height: 15),
              _buildFeaturedCard(featured),
              const SizedBox(height: 30),
            ],
            Text(
              searchQuery.isNotEmpty ? 'Search Results' : 'Popular Recipes',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 15),
            if (_isLoadingMore)
              const Center(child: CircularProgressIndicator())
            else if (recipes.isEmpty)
              _buildNoRecipesFound()
            else
              _buildRecipeGrid(recipes),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: _onSearchChanged,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search recipes...',
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.cardBackgroundAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          return CategoryChip(
            label: category,
            isSelected: selectedCategory == category,
            onTap: () => _onCategorySelected(category),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecipeGrid(List<Recipe> recipes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        return CompactRecipeCard(
          recipe: recipes[index],
          onFavoriteTap: () => _toggleFavorite(recipes[index]),
        );
      },
    );
  }

  Widget _buildFeaturedCard(Recipe recipe) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.title, style: AppTextStyles.headingSmall),
                const SizedBox(height: 5),
                Row(
                  children: [
                    RatingStars(rating: recipe.rating, size: 18),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.star.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.textPrimary,
                            size: 14,
                          ),
                          Text(
                            ' ${recipe.time}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRecipesFound() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Icon(Icons.search_off, size: 100, color: Colors.grey[800]),
          const SizedBox(height: 15),
          const Text('No recipes found', style: AppTextStyles.titleSmall),
          const Text(
            'Try adjusting your search or category filter',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
