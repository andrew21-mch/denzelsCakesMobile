import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqItems = [
    {
      'category': 'Orders',
      'question': 'How do I track my order?',
      'answer':
          'You can track your order by going to the Orders section in your profile. You\'ll see real-time updates on your order status, from preparation to delivery.',
    },
    {
      'category': 'Orders',
      'question': 'Can I cancel my order?',
      'answer':
          'Yes, you can cancel your order within 30 minutes of placing it. After that, please contact our support team for assistance.',
    },
    {
      'category': 'Orders',
      'question': 'What if my order is delayed?',
      'answer':
          'If your order is delayed, you\'ll receive a notification with the updated delivery time. You can also contact our support team for more information.',
    },
    {
      'category': 'Payment',
      'question': 'What payment methods do you accept?',
      'answer':
          'We accept all major credit cards (Visa, Mastercard, Amex) and mobile money payments (M-Pesa, Airtel Money, MTN Mobile Money).',
    },
    {
      'category': 'Payment',
      'question': 'Is my payment information secure?',
      'answer':
          'Yes, we use industry-standard encryption to protect your payment information. We never store your full card details on our servers.',
    },
    {
      'category': 'Delivery',
      'question': 'What are your delivery hours?',
      'answer':
          'We deliver from 9:00 AM to 9:00 PM, Monday through Sunday. Same-day delivery is available for orders placed before 2:00 PM.',
    },
    {
      'category': 'Delivery',
      'question': 'Do you deliver to my area?',
      'answer':
          'We currently deliver within a 25km radius of our bakery. Enter your address during checkout to see if delivery is available.',
    },
    {
      'category': 'Cakes',
      'question': 'Can I customize my cake?',
      'answer':
          'Yes! We offer custom cakes for special occasions. Contact us at least 48 hours in advance for custom orders.',
    },
    {
      'category': 'Cakes',
      'question': 'Do you have sugar-free options?',
      'answer':
          'Yes, we offer sugar-free and diabetic-friendly cake options. Look for the "Sugar-Free" tag in our cake listings.',
    },
    {
      'category': 'Account',
      'question': 'How do I reset my password?',
      'answer':
          'Go to the login screen and tap "Forgot Password". Enter your email address and we\'ll send you a reset link.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFAQs {
    if (_searchQuery.isEmpty) return _faqItems;

    return _faqItems.where((item) {
      return item['question']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item['answer'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['category'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedFAQs {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in _filteredFAQs) {
      final category = item['category'] as String;
      grouped.putIfAbsent(category, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.helpCenter),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchForHelp,
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.accentColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Quick Actions
          if (_searchQuery.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.quickActions,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.chat_outlined,
                          title: AppLocalizations.of(context)!.contactSupport,
                          subtitle: AppLocalizations.of(context)!.whatsappOrCall,
                          onTap: () => _startLiveChat(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.phone_outlined,
                          title: AppLocalizations.of(context)!.callUs,
                          subtitle: '683 252 520',
                          onTap: () => _callSupport(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // FAQ Section
          Expanded(
            child: _filteredFAQs.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_searchQuery.isEmpty)
                        Text(
                          AppLocalizations.of(context)!.frequentlyAskedQuestions,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                        ),
                      if (_searchQuery.isEmpty) const SizedBox(height: 16),
                      ..._groupedFAQs.entries.map((entry) {
                        return _buildCategorySection(entry.key, entry.value);
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.cardShadowColor,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.accentColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      String category, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchQuery.isEmpty) ...[
          Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
          ),
          const SizedBox(height: 8),
        ],
        ...items.map((item) => _buildFAQItem(item)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          item['question'],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item['answer'],
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noResultsFound,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.trySearchingWithDifferentKeywords,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _startLiveChat(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.contactSupport),
          ),
        ],
      ),
    );
  }

  void _startLiveChat() {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contactSupport),
        content: Text(l10n.chooseHowToContact),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openWhatsApp();
            },
            child: Text(l10n.whatsapp),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _callSupport();
            },
            child: Text(l10n.callUs),
          ),
        ],
      ),
    );
  }

  void _callSupport() async {
    HapticFeedback.lightImpact();
    _makePhoneCall('683252520');
  }

  void _makePhoneCall(String phoneNumber) async {
    // Try different phone URI formats
    final List<String> phoneFormats = [
      'tel:683252520',
      'tel:+237683252520',
      'tel://683252520',
      'tel://+237683252520'
    ];

    bool callMade = false;

    for (String phoneFormat in phoneFormats) {
      try {
        final Uri phoneUri = Uri.parse(phoneFormat);

        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
          callMade = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!callMade) {
      // Last resort - try without checking canLaunchUrl
      try {
        final Uri directUri = Uri.parse('tel:683252520');
        await launchUrl(directUri);
        callMade = true;
      } catch (e) {
        _showErrorMessage(
            'Phone app not available. Please dial 683 252 520 manually.');
      }
    }
  }

  void _openWhatsApp() async {
    HapticFeedback.lightImpact();
    const phoneNumber = '237683252520'; // Country code + number
    final List<Uri> whatsappUris = [
      Uri.parse('whatsapp://send?phone=$phoneNumber'), // WhatsApp app
      Uri.parse('https://wa.me/$phoneNumber'), // WhatsApp web
      Uri.parse(
          'https://api.whatsapp.com/send?phone=$phoneNumber'), // Alternative web
    ];

    bool opened = false;
    for (final uri in whatsappUris) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          opened = true;
          break;
        }
      } catch (e) {
        // Try next option
        continue;
      }
    }

    if (!opened) {
      _showErrorMessage(
          'WhatsApp not available. Please message us at +237 683 252 520');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
