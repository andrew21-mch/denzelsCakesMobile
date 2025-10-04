import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, dynamic>> _languages = [
    {
      'name': 'English',
      'nativeName': 'English',
      'code': 'en',
      'flag': '🇺🇸',
      'isDefault': true,
    },
    {
      'name': 'French',
      'nativeName': 'Français',
      'code': 'fr',
      'flag': '🇫🇷',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Language'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveLanguageSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Current Language Info
            _buildCurrentLanguageSection(),

            const SizedBox(height: 24),

            // Language Selection
            _buildLanguageSelectionSection(),

            // const SizedBox(height: 24),

            // Additional Settings
            // _buildAdditionalSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLanguageSection() {
    final currentLang = _languages.firstWhere(
      (lang) => lang['name'] == _selectedLanguage,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.language,
                color: AppTheme.accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Current Language',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text(
                  currentLang['flag'],
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentLang['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        currentLang['nativeName'],
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (currentLang['isDefault'])
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Languages',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),

          // Official Languages Section
          _buildLanguageGroup(
            'Official Languages',
            _languages
                .where((lang) => ['English', 'French'].contains(lang['name']))
                .toList(),
          ),

          const SizedBox(height: 20),

          // Local Languages Section
          _buildLanguageGroup(
            'Local Languages',
            _languages
                .where((lang) => !['English', 'French'].contains(lang['name']))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageGroup(
      String title, List<Map<String, dynamic>> languages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        ...languages.map((language) => _buildLanguageOption(language)),
      ],
    );
  }

  Widget _buildLanguageOption(Map<String, dynamic> language) {
    final isSelected = language['name'] == _selectedLanguage;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedLanguage = language['name'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor.withValues(alpha: 0.1)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              language['flag'],
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.accentColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    language['nativeName'],
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.accentColor.withValues(alpha: 0.7)
                          : AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (language['isDefault'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.accentColor,
                size: 20,
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: AppTheme.textTertiary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // Widget _buildAdditionalSettingsSection() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: AppTheme.surfaceColor,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: const [
  //         BoxShadow(
  //           color: AppTheme.cardShadowColor,
  //           blurRadius: 8,
  //           offset: Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Additional Settings',
  //           style: const TextStyle(
  //             fontSize: 18,
  //             fontWeight: FontWeight.bold,
  //             color: AppTheme.textPrimary,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         // Additional settings content...
  //       ],
  //     ),
  //   );
  // }

  void _saveLanguageSettings() {
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $_selectedLanguage'),
        backgroundColor: AppTheme.successColor,
        action: SnackBarAction(
          label: 'Restart App',
          textColor: Colors.white,
          onPressed: () {
            // In a real app, this would restart the app
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('App restart required for changes to take effect'),
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  void _showAutoDetectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-detect Language'),
        content: const Text(
          'This will automatically set the app language based on your device\'s language settings. '
          'You can always change it manually later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _selectedLanguage = 'English'; // Simulate auto-detection
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Auto-detection enabled'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showDownloadLanguagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Languages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select languages to download for offline use:'),
            const SizedBox(height: 16),
            ..._languages.map((lang) => CheckboxListTile(
                  title: Text('${lang['flag']} ${lang['name']}'),
                  subtitle: Text(lang['nativeName']),
                  value: lang['name'] == 'English', // English is pre-downloaded
                  onChanged: lang['name'] == 'English'
                      ? null
                      : (value) {
                          // Handle download
                        },
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Languages download started'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showTranslationQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translation Quality'),
        content: const Text(
          'Help us improve translations by reporting issues or suggesting better translations. '
          'Your feedback helps make the app better for everyone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for helping improve translations!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Report Issue'),
          ),
        ],
      ),
    );
  }
}
