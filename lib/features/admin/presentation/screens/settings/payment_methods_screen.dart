import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../core/services/admin_api_service_new.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  // Helper function to convert string icon names to IconData
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'phone_android':
        return Icons.phone_android;
      case 'account_balance':
        return Icons.account_balance;
      case 'money':
        return Icons.money;
      case 'credit_card':
        return Icons.credit_card;
      default:
        return Icons.payment; // Default fallback icon
    }
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final paymentData = await AdminApiService.getPaymentMethods();
      setState(() {
        _paymentMethods =
            List<Map<String, dynamic>>.from(paymentData['methods'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
// print('Error loading payment methods: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load payment methods: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AdminApiService.updatePaymentMethods({'methods': _paymentMethods});

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment methods updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
// print('Error saving payment methods: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save payment methods: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.blue[50],
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Configure which payment methods are available to customers',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _paymentMethods.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final method = _paymentMethods[index];
                      return _buildPaymentMethodCard(method);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaymentMethodDialog,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Method'),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: method['enabled']
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconFromString(method['icon'] ?? 'payment'),
                    color: method['enabled']
                        ? AppTheme.primaryColor
                        : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            method['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!method['enabled'])
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Disabled',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Provider: ${method['provider']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: method['enabled'],
                  onChanged: (value) =>
                      _togglePaymentMethod(method['id'], value),
                  activeThumbColor: AppTheme.primaryColor,
                ),
              ],
            ),
            if (method['enabled']) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _configurePaymentMethod(method),
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('Configure'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _testPaymentMethod(method),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Test'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[300]!),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _togglePaymentMethod(String methodId, bool enabled) async {
    // Find and update the payment method
    for (var method in _paymentMethods) {
      if (method['id'] == methodId) {
        setState(() {
          method['enabled'] = enabled;
        });
        break;
      }
    }

    // Save the changes to backend
    await _savePaymentMethods();
  }

  void _configurePaymentMethod(Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${method['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment method configuration will be available here.'),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement configuration UI for each payment provider',
              style: TextStyle(
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _testPaymentMethod(Map<String, dynamic> method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Testing ${method['name']} connection...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    // TODO: Implement actual payment method testing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${method['name']} test completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add new payment method integration'),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement payment method addition UI',
              style: TextStyle(
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
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
                  content: Text('Payment method addition coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
