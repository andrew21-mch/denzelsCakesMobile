import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/payment_method_service.dart';
import '../../../../core/models/user_model.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, dynamic>> _paymentMethods = [];
  Map<String, dynamic> _availablePaymentMethods = {};
  bool _isLoading = false;
  bool _hasModifications = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user data to get stored payment methods
      final userData = await StorageService.getUserData();
      if (userData != null) {
        final user = User.fromJson(userData);
        setState(() {
          _currentUser = user;
        });
      }

      // Load payment methods from backend using the payment method service
      final paymentMethods = await PaymentMethodService.getUserPaymentMethods();
      final methodsData = paymentMethods
          .map((method) => {
                'id': method.id,
                'type': method.type,
                'displayName': method.displayName,
                'lastFour': method.lastFourDigits,
                'lastFourDigits': method.lastFourDigits,
                'phoneNumber': method.phoneNumber,
                'brand': method.brand,
                'cardType': method.brand,
                'isDefault': method.isDefault,
                'expiryDate': method.expiryDate?.toIso8601String(),
                'expiryMonth': method.expiryDate?.month.toString(),
                'expiryYear': method.expiryDate?.year.toString(),
                'holderName': _currentUser?.name ?? 'User',
                'provider': method.type == 'mobile_money'
                    ? method.displayName
                    : method.brand,
                'isDemo': method.id.startsWith('demo_'),
              })
          .toList();

      setState(() {
        _paymentMethods = methodsData;
      });

      // Load available payment methods from backend
      await _loadAvailablePaymentMethods();
    } catch (e) {
// print('DEBUG: Error loading payment methods: $e');

      // Fallback to local storage if backend fails
      try {
        final methods = await _getStoredPaymentMethods();
        setState(() {
          _paymentMethods = methods;
        });
        await _loadAvailablePaymentMethods();
      } catch (fallbackError) {
// print('DEBUG: Fallback error: $fallbackError');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error loading payment methods: ${fallbackError.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailablePaymentMethods() async {
    try {
      final response = await ApiService.get('/payments/methods?currency=XAF');

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _availablePaymentMethods = response.data['data'] ?? {};
        });
// print('DEBUG: Available payment methods: $_availablePaymentMethods');
      }
    } catch (e) {
// print('DEBUG: Error loading available payment methods: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getStoredPaymentMethods() async {
    final List<Map<String, dynamic>> allMethods = [];

    try {
      // Try to load payment methods from backend first
      final response = await ApiService.get('/payments/user-methods');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> methods = response.data['data'] ?? [];
        allMethods.addAll(methods.cast<Map<String, dynamic>>());
      }
    } catch (e) {
// print('DEBUG: Error loading payment methods from backend: $e');
    }

    // Load user-added payment methods from local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final userMethodsJson = prefs.getString('user_payment_methods');
      if (userMethodsJson != null) {
        final List<dynamic> userMethods = jsonDecode(userMethodsJson);
        allMethods.addAll(userMethods.cast<Map<String, dynamic>>());
      }
    } catch (e) {
// print('DEBUG: Error loading user payment methods from storage: $e');
    }

    // If no user methods, check if we should show demo methods
    final prefs = await SharedPreferences.getInstance();
    final showDemoMethods = prefs.getBool('show_demo_payment_methods') ?? true;
    final cardDeleted = prefs.getBool('demo_card_deleted') ?? false;
    final momoDeleted = prefs.getBool('demo_momo_deleted') ?? false;

    if (showDemoMethods && allMethods.isEmpty) {
      // Add demo card if not deleted
      if (!cardDeleted) {
        allMethods.add({
          'id': 'demo_card_1',
          'type': 'card',
          'cardType': 'visa',
          'lastFour': '4242',
          'expiryMonth': '12',
          'expiryYear': '25',
          'holderName': _currentUser?.name ?? 'User',
          'isDefault': true,
          'isDemo': true,
        });
      }

      // Add demo mobile money if not deleted
      if (!momoDeleted) {
        allMethods.add({
          'id': 'demo_momo_1',
          'type': 'mobile_money',
          'provider': 'M-Pesa',
          'phoneNumber': '+237 6XX XXX XXX',
          'isDefault': !cardDeleted, // Make it default if card is deleted
          'isDemo': true,
        });
      }
    }

    return allMethods;
  }

  String _getCardType(String cardNumber) {
    // Remove spaces and non-digits
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.startsWith('4')) {
      return 'visa';
    } else if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) {
      return 'mastercard';
    } else if (cleanNumber.startsWith('3')) {
      return 'amex';
    } else {
      return 'unknown';
    }
  }

  Future<void> _savePaymentMethodsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userPaymentMethods =
          _paymentMethods.where((method) => method['isDemo'] != true).toList();
      final jsonString = jsonEncode(userPaymentMethods);
      await prefs.setString('user_payment_methods', jsonString);
    } catch (e) {
// print('DEBUG: Error saving payment methods: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.of(context).pop(_hasModifications);
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: const Text('Payment Methods'),
            backgroundColor: AppTheme.surfaceColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(_hasModifications),
            ),
            actions: [
              IconButton(
                onPressed: _loadPaymentMethods,
                icon: const Icon(Icons.refresh, color: AppTheme.accentColor),
              ),
              IconButton(
                onPressed: () => _showAddPaymentDialog(),
                icon: const Icon(Icons.add, color: AppTheme.accentColor),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  ),
                )
              : _paymentMethods.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        if (_availablePaymentMethods.isNotEmpty)
                          _buildAvailableMethodsInfo(),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _paymentMethods.length,
                            itemBuilder: (context, index) {
                              final method = _paymentMethods[index];
                              return _buildPaymentCard(method, index);
                            },
                          ),
                        ),
                      ],
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddPaymentDialog(),
            backgroundColor: AppTheme.accentColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ));
  }

  Widget _buildAvailableMethodsInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppTheme.accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Available Payment Methods',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Powered by Stripe • Secure payments for Cameroon (XAF)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          if (_availablePaymentMethods.containsKey('stripe')) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildMethodChip('💳 Cards'),
                _buildMethodChip('📱 Mobile Money'),
                _buildMethodChip('🍎 Apple Pay'),
                _buildMethodChip('🤖 Google Pay'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMethodChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.payment_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No payment methods added',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your cards or mobile money accounts to make payments easier and faster.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddPaymentDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Payment Method'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            if (_availablePaymentMethods.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Secure payments powered by Stripe',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> method, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: method['isDefault']
            ? Border.all(color: AppTheme.accentColor, width: 2)
            : null,
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: method['type'] == 'card'
          ? _buildCardTile(method, index)
          : _buildMobileMoneyTile(method, index),
    );
  }

  Widget _buildCardTile(Map<String, dynamic> method, int index) {
    final isDemo = method['isDemo'] == true;

    return ListTile(
      leading: Container(
        width: 50,
        height: 32,
        decoration: BoxDecoration(
          color: _getCardColor(method['cardType']),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getCardIcon(method['cardType']),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
            '**** **** **** ${method['lastFour']}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          if (method['isDefault']) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Default',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (isDemo) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.warningColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Demo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            method['holderName'],
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Expires ${method['expiryMonth']}/${method['expiryYear']}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isDemo) ...[
                const SizedBox(width: 8),
                const Flexible(
                  child: Text(
                    '• Demo card for testing',
                    style: TextStyle(
                      color: AppTheme.warningColor,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handlePaymentAction(value, index),
        itemBuilder: (context) => [
          if (!method['isDefault'])
            const PopupMenuItem(
              value: 'default',
              child: Row(
                children: [
                  Icon(Icons.star, size: 20),
                  SizedBox(width: 8),
                  Text('Set as Default'),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                SizedBox(width: 8),
                Text('Remove', style: TextStyle(color: AppTheme.errorColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMoneyTile(Map<String, dynamic> method, int index) {
    final isDemo = method['isDemo'] == true;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.phone_android,
          color: AppTheme.successColor,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              method['provider'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (method['isDefault']) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Default',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (isDemo) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.warningColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Demo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            method['phoneNumber'],
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          if (isDemo) ...[
            const SizedBox(height: 2),
            const Text(
              'Demo account for testing',
              style: TextStyle(
                color: AppTheme.warningColor,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handlePaymentAction(value, index),
        itemBuilder: (context) => [
          if (!method['isDefault'])
            const PopupMenuItem(
              value: 'default',
              child: Row(
                children: [
                  Icon(Icons.star, size: 20),
                  SizedBox(width: 8),
                  Text('Set as Default'),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                SizedBox(width: 8),
                Text('Remove', style: TextStyle(color: AppTheme.errorColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF006FCF);
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
      case 'mastercard':
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  void _handlePaymentAction(String action, int index) async {
    HapticFeedback.lightImpact();

    switch (action) {
      case 'default':
        try {
          final paymentMethodId = _paymentMethods[index]['id'];

          // Skip demo methods - only save real methods to backend
          if (_paymentMethods[index]['isDemo'] == true) {
            // Handle demo methods locally
            setState(() {
              // Remove default from all methods
              for (var method in _paymentMethods) {
                method['isDefault'] = false;
              }
              // Set this method as default
              _paymentMethods[index]['isDefault'] = true;
              _hasModifications = true;
            });

            // Save to storage immediately
            await _savePaymentMethodsToStorage();
          } else {
            // Use backend for real payment methods
            await PaymentMethodService.setDefaultPaymentMethod(paymentMethodId);

            setState(() {
              // Update local state to reflect backend change
              for (var method in _paymentMethods) {
                method['isDefault'] = false;
              }
              _paymentMethods[index]['isDefault'] = true;
              _hasModifications = true;
            });
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Default payment method updated'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        } catch (e) {
// print('DEBUG: Error setting default payment method: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to set default payment method: $e'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
        break;
      case 'delete':
        _showDeleteDialog(index);
        break;
    }
  }

  void _showDeleteDialog(int index) {
    final method = _paymentMethods[index];
    final isCard = method['type'] == 'card';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.errorColor,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Remove Payment Method',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    isCard
                        ? 'Are you sure you want to remove this card ending in ${method['lastFour']}?'
                        : 'Are you sure you want to remove this ${method['provider']} account?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: AppTheme.textTertiary
                                      .withValues(alpha: 0.3)),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final method = _paymentMethods[index];
                            final navigator = Navigator.of(context);
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);

                            try {
                              // If it's a demo method, handle locally
                              if (method['isDemo'] == true) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                if (method['id'] == 'demo_card_1') {
                                  await prefs.setBool(
                                      'demo_card_deleted', true);
                                } else if (method['id'] == 'demo_momo_1') {
                                  await prefs.setBool(
                                      'demo_momo_deleted', true);
                                }

                                // If both demo methods are deleted, hide all demo methods
                                final cardDeleted =
                                    prefs.getBool('demo_card_deleted') ?? false;
                                final momoDeleted =
                                    prefs.getBool('demo_momo_deleted') ?? false;
                                if (cardDeleted && momoDeleted) {
                                  await prefs.setBool(
                                      'show_demo_payment_methods', false);
                                }
                              } else {
                                // Use backend for real payment methods
                                await PaymentMethodService.deletePaymentMethod(
                                    method['id']);
                              }

                              if (mounted) {
                                setState(() {
                                  _paymentMethods.removeAt(index);
                                  _hasModifications = true;
                                });
                                navigator.pop();
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Payment method removed'),
                                    backgroundColor: AppTheme.successColor,
                                  ),
                                );
                              }
                            } catch (e) {
// print('DEBUG: Error deleting payment method: $e');
                              if (mounted) {
                                navigator.pop();
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Failed to remove payment method: $e'),
                                    backgroundColor: AppTheme.errorColor,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Remove'),
                        ),
                      ),
                    ],
                  ),

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Payment Method',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Security info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.security,
                            color: AppTheme.accentColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Secure payments powered by Stripe',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment method options
                  _buildPaymentMethodOption(
                    icon: Icons.credit_card,
                    iconColor: AppTheme.accentColor,
                    title: 'Credit/Debit Card',
                    subtitle: _availablePaymentMethods.containsKey('stripe')
                        ? 'Visa, Mastercard, Amex • Secure & Fast'
                        : 'Visa, Mastercard, Amex',
                    isAvailable: _availablePaymentMethods.containsKey('stripe'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAddCardBottomSheet();
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildPaymentMethodOption(
                    icon: Icons.phone_android,
                    iconColor: AppTheme.successColor,
                    title: 'Mobile Money',
                    subtitle: _availablePaymentMethods.containsKey('stripe')
                        ? 'M-Pesa, Airtel Money, MTN • Available in Cameroon'
                        : 'M-Pesa, Airtel Money, etc.',
                    isAvailable: _availablePaymentMethods.containsKey('stripe'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAddMobileMoneyBottomSheet();
                    },
                  ),

                  // Bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.textTertiary.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isAvailable ? AppTheme.successColor : AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: isAvailable
            ? const Icon(Icons.check_circle,
                color: AppTheme.successColor, size: 20)
            : const Icon(Icons.arrow_forward_ios,
                color: AppTheme.textTertiary, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showAddCardBottomSheet() {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.credit_card,
                        color: AppTheme.accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Credit/Debit Card',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                        ),
                        Text(
                          'Secure payment with Stripe',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon:
                        const Icon(Icons.close, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        hintText: '1234 5678 9012 3456',
                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: expiryController,
                            decoration: InputDecoration(
                              labelText: 'MM/YY',
                              hintText: '12/25',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppTheme.backgroundColor,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: cvvController,
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppTheme.backgroundColor,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Cardholder Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Security info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                AppTheme.successColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock,
                              color: AppTheme.successColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your card information is encrypted and secure. We never store your full card details.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.successColor,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                border: Border(
                  top: BorderSide(
                      color: AppTheme.textTertiary.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color:
                                  AppTheme.textTertiary.withValues(alpha: 0.3)),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        // Validate input
                        if (cardNumberController.text.isEmpty ||
                            expiryController.text.isEmpty ||
                            cvvController.text.isEmpty ||
                            nameController.text.isEmpty) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }

                        // Add the new card to the list
                        try {
                          // Create the payment method data
                          final paymentMethodData = {
                            'cardBrand':
                                _getCardType(cardNumberController.text),
                            'lastFourDigits':
                                cardNumberController.text.length >= 4
                                    ? cardNumberController.text.substring(
                                        cardNumberController.text.length - 4)
                                    : cardNumberController.text,
                            'expiryMonth': int.tryParse(
                                    expiryController.text.length >= 2
                                        ? expiryController.text.substring(0, 2)
                                        : expiryController.text) ??
                                12,
                            'expiryYear': int.tryParse(expiryController
                                            .text.length >=
                                        4
                                    ? '20${expiryController.text.substring(2, 4)}'
                                    : expiryController.text.length >= 3
                                        ? '20${expiryController.text.substring(2)}'
                                        : '2025') ??
                                2025,
                            'holderName': nameController.text,
                            'isDefault': _paymentMethods.isEmpty,
                          };

                          // Add to backend
                          final paymentMethod =
                              await PaymentMethodService.addPaymentMethod(
                            type: 'card',
                            details: paymentMethodData,
                          );

                          // Convert to local format for state management
                          final newCard = {
                            'id': paymentMethod.id,
                            'type': 'card',
                            'cardType': paymentMethod.brand ?? 'card',
                            'lastFour': paymentMethod.lastFourDigits ?? '',
                            'expiryMonth':
                                paymentMethod.expiryDate?.month.toString() ??
                                    '12',
                            'expiryYear': paymentMethod.expiryDate?.year
                                    .toString()
                                    .substring(2) ??
                                '25',
                            'holderName': nameController.text,
                            'isDefault': paymentMethod.isDefault,
                            'isDemo': false,
                          };

                          setState(() {
                            _paymentMethods.add(newCard);
                            _hasModifications = true;
                          });

                          navigator.pop();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _availablePaymentMethods
                                              .containsKey('stripe')
                                          ? 'Card added successfully! Ready for payments.'
                                          : 'Card added successfully!',
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        } catch (e) {
// print('DEBUG: Error adding card: $e');
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed to add card: $e'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_availablePaymentMethods
                              .containsKey('stripe')) ...[
                            const Icon(Icons.security, size: 16),
                            const SizedBox(width: 4),
                          ],
                          const Text('Add Card'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMobileMoneyBottomSheet() {
    final phoneController = TextEditingController();
    String selectedProvider = 'M-Pesa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phone_android,
                          color: AppTheme.successColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Mobile Money',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          Text(
                            'Connect your mobile money account',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close,
                          color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedProvider,
                        decoration: InputDecoration(
                          labelText: 'Provider',
                          prefixIcon: const Icon(Icons.phone_android),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                        ),
                        items: [
                          'M-Pesa',
                          'Airtel Money',
                          'MTN Mobile Money',
                          'Orange Money'
                        ]
                            .map((provider) => DropdownMenuItem(
                                  value: provider,
                                  child: Text(provider),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProvider = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+237 6XX XXX XXX',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),

                      // Info about mobile money
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  AppTheme.accentColor.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: AppTheme.accentColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Mobile Money in Cameroon',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: AppTheme.accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• Payments processed securely through Stripe\n• Supports major Cameroon mobile money providers\n• Instant payment confirmation',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
              Container(
                padding: EdgeInsets.fromLTRB(
                    20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  border: Border(
                    top: BorderSide(
                        color: AppTheme.textTertiary.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: AppTheme.textTertiary
                                    .withValues(alpha: 0.3)),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
                          // Validate input
                          if (phoneController.text.isEmpty) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a phone number'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                            return;
                          }

                          try {
                            // Create the payment method data
                            final paymentMethodData = {
                              'type': 'mobile_money',
                              'provider': selectedProvider,
                              'phoneNumber': phoneController.text,
                              'isDefault': _paymentMethods.isEmpty,
                            };

                            // Add to backend
                            final paymentMethod =
                                await PaymentMethodService.addPaymentMethod(
                              type: 'mobile_money',
                              details: paymentMethodData,
                            );

                            // Convert to local format for state management
                            final newMobileMoneyAccount = {
                              'id': paymentMethod.id,
                              'type': 'mobile_money',
                              'provider': selectedProvider,
                              'phoneNumber': phoneController.text,
                              'isDefault': paymentMethod.isDefault,
                              'isDemo': false,
                            };

                            setState(() {
                              _paymentMethods.add(newMobileMoneyAccount);
                              _hasModifications = true;
                            });

                            navigator.pop();
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                          '$selectedProvider account added successfully!'),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          } catch (e) {
// print('DEBUG: Error adding mobile money account: $e');
                            navigator.pop();
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to add mobile money account: $e'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_availablePaymentMethods
                                .containsKey('stripe')) ...[
                              const Icon(Icons.phone_android, size: 16),
                              const SizedBox(width: 4),
                            ],
                            const Text('Add Account'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
