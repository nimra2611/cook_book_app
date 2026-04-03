import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../utils/constants.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesService _prefs = PreferencesService();

  // States for toggles
  bool _darkTheme = true;
  bool _compactCards = false;
  bool _cookingNotifications = true;
  bool _autoSync = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _darkTheme = _prefs.isDarkTheme;
      _compactCards = _prefs.isCompactCards;
      _cookingNotifications = _prefs.isCookingNotificationsEnabled;
      _autoSync = _prefs.isAutoSyncEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDarker,
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.titleSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          _buildCard([
            _buildSwitchTile(
              'Dark Theme',
              'Currently using dark mode',
              Icons.nightlight_round,
              _darkTheme,
              (val) {
                setState(() => _darkTheme = val);
                _prefs.setDarkTheme(val);
              },
            ),
            _buildSwitchTile(
              'Compact Cards',
              'Use smaller cards to show more content',
              Icons.grid_view_rounded,
              _compactCards,
              (val) {
                setState(() => _compactCards = val);
                _prefs.setCompactCards(val);
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preview:', style: AppTextStyles.caption),
                  SizedBox(height: 8),
                  SampleRecipePreview(),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _buildSectionHeader('Preferences'),
          _buildCard([
            _buildActionTile(
              'Default Category',
              'New recipes will default to Lunch',
              Icons.category_outlined,
              trailingText: _prefs.defaultCategory,
            ),
            _buildSwitchTile(
              'Cooking Notifications',
              'Get reminders for cooking times',
              Icons.notifications,
              _cookingNotifications,
              (val) {
                setState(() => _cookingNotifications = val);
                _prefs.setCookingNotifications(val);
              },
            ),
            _buildSwitchTile(
              'Auto Sync',
              'Automatically sync recipes across devices',
              Icons.sync,
              _autoSync,
              (val) {
                setState(() => _autoSync = val);
                _prefs.setAutoSync(val);
              },
            ),
          ]),
          const SizedBox(height: 20),
          _buildSectionHeader('Data'),
          _buildCard([
            _buildActionTile(
              'Export Recipes',
              'Save your recipes as a backup file',
              Icons.archive_outlined,
            ),
            _buildActionTile(
              'Clear Cache',
              'Free up storage space',
              Icons.delete_outline,
            ),
          ]),
          const SizedBox(height: 20),
          _buildAboutSection(),
          const SizedBox(height: 20),
          _buildCard([
            _buildActionTile(
              'Help & Support',
              'Get help with using the app',
              Icons.help_outline,
            ),
            _buildActionTile(
              'Rate App',
              'Rate us on the App Store',
              Icons.star_border,
            ),
            _buildActionTile(
              'Privacy Policy',
              'Review our privacy practices',
              Icons.description_outlined,
            ),
          ]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }



  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: AppTextStyles.titleSmall),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDarker,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: CircleAvatar(
        backgroundColor: AppColors.primaryAlt.withOpacity(0.2),
        child: Icon(icon, color: AppColors.primaryAlt),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      value: value,
      activeColor: AppColors.primaryAlt,
      onChanged: onChanged,
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon, {
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryAlt.withOpacity(0.2),
        child: Icon(icon, color: AppColors.primaryAlt),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(color: AppColors.primaryAlt)),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDarker,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: AppColors.textPrimary,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConstants.appName, style: AppTextStyles.titleSmall),
              Text(
                'Version ${AppConstants.appVersion}',
                style: AppTextStyles.caption,
              ),
              const Text(
                'Your personal recipe collection...',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sample recipe preview widget for settings
class SampleRecipePreview extends StatelessWidget {
  const SampleRecipePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sample Recipe', style: AppTextStyles.bodyMedium),
              Text(
                '30 minutes • Rating: 4.5 stars',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}