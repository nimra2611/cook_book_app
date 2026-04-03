import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_repository.dart';
import '../utils/constants.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddEditRecipeScreen({
    super.key,
    this.recipe,
  });

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  final _formKey = GlobalKey<FormState>();


  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isFormInvalid = false;
  String _selectedCategory = 'Lunch';
  String _selectedDifficulty = 'Medium';
  double _rating = 3.0;
  final List<Ingredient> _ingredients = [];
  final List<String> _steps = [];

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadRecipeData();
    }
  }

  void _loadRecipeData() {
    final recipe = widget.recipe!;
    _titleController.text = recipe.title;
    _timeController.text = recipe.time.replaceAll('m', '');
    _imageUrlController.text = recipe.imagePath;
    _selectedCategory = recipe.category;
    _selectedDifficulty = recipe.difficulty ?? 'Medium';
    _rating = recipe.rating.toDouble();
    _ingredients.addAll(recipe.ingredients);
    _steps.addAll(recipe.instructions);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        title: Text(
          _isEditing ? 'Edit Recipe' : 'Add Recipe',
          style: AppTextStyles.titleSmall,
        ),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: const Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_isFormInvalid)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.error,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.textPrimary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Form is Invalid',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Recipe Title *'),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'Enter recipe title',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Title is required' : null,
                    ),
                    _buildLabel('Category'),
                    _buildCategoryDropdown(),
                    _buildLabel('Cook Time (minutes) *'),
                    _buildTextField(
                      controller: _timeController,
                      hint: '30',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Cook time is required' : null,
                    ),
                    _buildLabel('Difficulty'),
                    _buildDifficultyToggle(),
                    _buildLabel('Image URL (optional)'),
                    _buildTextField(
                      controller: _imageUrlController,
                      hint: 'https://example.com/image.jpg',
                    ),
                    _buildLabel('Rating: ${_rating.toStringAsFixed(1)}'),
                    Slider(
                      value: _rating,
                      onChanged: (val) => setState(() => _rating = val),
                      min: 0,
                      max: 5,
                      divisions: 10,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.cardBackground,
                    ),
                    _buildSectionHeader('Ingredients *'),
                    ..._ingredients.asMap().entries.map((e) => _buildIngredientRow(e.value, e.key)),
                    _buildAddButton('Add Ingredient', _addIngredient),
                    _buildSectionHeader('Cooking Steps *'),
                    ..._steps.asMap().entries.map((e) => _buildStepRow(e.value, e.key)),
                    _buildAddButton('Add Step', _addStep),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(const Ingredient(name: '', amount: ''));
    });
  }

  void _addStep() {
    setState(() {
      _steps.add('');
    });
  }

  void _saveRecipe() {
    if (_formKey.currentState?.validate() ?? false) {
      // Save logic here
      Navigator.pop(context);
    } else {
      setState(() => _isFormInvalid = true);
    }
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(label, style: AppTextStyles.bodyMedium),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 12),
      child: Text(title, style: AppTextStyles.titleSmall),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHintDark),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: AppColors.cardBackground,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          items: AppCategories.all
              .where((c) => c != 'All')
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: AppColors.textPrimary)),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCategory = val);
          },
        ),
      ),
    );
  }

  Widget _buildDifficultyToggle() {
    return Row(
      children: AppCategories.difficulties.map((level) {
        bool isSelected = _selectedDifficulty == level;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = level),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  level,
                  style: TextStyle(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIngredientRow(Ingredient ingredient, int index) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildTextField(
            controller: TextEditingController(text: ingredient.name),
            hint: 'Ingredient name',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
            controller: TextEditingController(text: ingredient.amount),
            hint: 'Qty',
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _ingredients.removeAt(index)),
          icon: const Icon(Icons.delete_rounded, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStepRow(String step, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.primary,
          child: Text('${index + 1}', style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
            controller: TextEditingController(text: step),
            hint: 'Describe this step...',
            maxLines: 3,
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _steps.removeAt(index)),
          icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildAddButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(Icons.add, color: AppColors.primary, size: 18),
          label: Text(label, style: const TextStyle(color: AppColors.primary)),
        ),
      ),
    );
  }
}
