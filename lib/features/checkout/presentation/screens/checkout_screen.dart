import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/services/payment_method_service.dart';
import '../../../../core/services/country_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/cart_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/payment_method_model.dart';
import '../../../../core/models/country_model.dart';
import '../../../profile/presentation/screens/payment_methods_screen.dart';
import '../../../profile/presentation/screens/add_address_with_map_screen.dart';
import 'payment_waiting_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  String _selectedAddress = 'home';
  String _selectedPayment = 'card';

  final _instructionsController = TextEditingController();
  String? _targetGender; // Gender specification for the order

  // Cake customization state - per item
  Map<String, Map<String, dynamic>> _itemCustomizations = {};
  Map<String, TextEditingController> _instructionControllers = {};
  final ImagePicker _imagePicker = ImagePicker();

  // Payment detail controllers
  final _phoneController = TextEditingController();
  // Card details are handled securely by payment provider - not collected in app

  // Quick location entry controllers
  final _quickStreetController = TextEditingController();
  final _quickCityController = TextEditingController();
  final _quickStateController = TextEditingController();
  String _quickCountry = 'CM'; // Default country code, will be made dynamic

  Cart _cart = const Cart();
  List<Address> _addresses = [];
  List<PaymentMethodModel> _savedPaymentMethods = [];
  List<Country> _countries = [];
  bool _isLoading = true;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Add listeners to payment form controllers to update UI when text changes
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _phoneController.dispose();
    _quickStreetController.dispose();
    _quickCityController.dispose();
    _quickStateController.dispose();
    // Dispose instruction controllers
    for (final controller in _instructionControllers.values) {
      controller.dispose();
    }
    // Card detail controllers removed for security - we don't collect card details in the app
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load cart from local storage
      final cart = await CartService.loadCart();

      // Load user addresses from backend
      final addresses = await AddressService.getUserAddresses();

      // Load user's saved payment methods
      final paymentMethods = await PaymentMethodService.getUserPaymentMethods();

      // Load countries
      final countries = await CountryService.getCountries();

      setState(() {
        _cart = cart;
        _addresses = addresses;
        _savedPaymentMethods = paymentMethods;
        _countries = countries;
        _isLoading = false;

        // Select default address if available
        if (addresses.isNotEmpty) {
          final defaultAddress = addresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => addresses.first,
          );
          _selectedAddress = defaultAddress.id ?? defaultAddress.type;
        }

        // Select default payment method if available
        if (paymentMethods.isNotEmpty) {
          final defaultPaymentMethod = paymentMethods.firstWhere(
            (method) => method.isDefault,
            orElse: () => paymentMethods.first,
          );
          _selectedPayment = defaultPaymentMethod.type;
        }
      });
    } catch (e) {
// print('DEBUG: Error loading checkout data: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.of(context).push<Address>(
      MaterialPageRoute(
        builder: (context) => AddAddressWithMapScreen(
          onSave: (address) {
            Navigator.of(context).pop(address);
          },
        ),
      ),
    );

    if (result != null) {
      // Add the new address to the list and select it
      setState(() {
        _addresses.add(result);
        _selectedAddress = result.id ?? result.type;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address added successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: _buildStepContent(),
          ),

          // Bottom Navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Address', _currentStep >= 0),
          Expanded(child: _buildStepLine(_currentStep >= 1)),
          _buildStepIndicator(1, 'Payment', _currentStep >= 1),
          Expanded(child: _buildStepLine(_currentStep >= 2)),
          _buildStepIndicator(2, 'Customize', _currentStep >= 2),
          Expanded(child: _buildStepLine(_currentStep >= 3)),
          _buildStepIndicator(3, 'Review', _currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.accentColor : AppTheme.textTertiary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.accentColor : AppTheme.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: isActive ? AppTheme.accentColor : AppTheme.textTertiary,
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep();
      case 1:
        return _buildPaymentStep();
      case 2:
        return _buildCustomizationStep();
      case 3:
        return _buildReviewStep();
      default:
        return _buildAddressStep();
    }
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),

          // Address Options from backend
          if (_addresses.isNotEmpty) ...[
            ..._addresses.map((address) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAddressOption(
                    address.id ?? address.type,
                    _getAddressTypeDisplayName(address.type),
                    address.fullAddress,
                    _getAddressIcon(address.type),
                    isDefault: address.isDefault,
                  ),
                )),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.location_off_outlined,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No addresses found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please add an address to continue',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          // Add new address option
          const SizedBox(height: 12),
          _buildAddressOption(
            'add_new',
            'Add New Address',
            'Add a new delivery address',
            Icons.add_location_outlined,
            isAddNew: true,
          ),

          // Quick location entry option
          const SizedBox(height: 8),
          _buildAddressOption(
            'enter_location',
            'Enter Location Directly',
            'Quickly enter your delivery location',
            Icons.edit_location_outlined,
            isQuickEntry: true,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAddressOption(
      String value, String title, String address, IconData icon,
      {bool isDefault = false,
      bool isAddNew = false,
      bool isQuickEntry = false}) {
    final isSelected = _selectedAddress == value;

    return GestureDetector(
      onTap: () {
        if (isAddNew) {
          _navigateToAddAddress();
        } else if (isQuickEntry) {
          _showQuickLocationDialog();
        } else {
          setState(() {
            _selectedAddress = value;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentColor.withValues(alpha: 0.1)
                    : AppTheme.textTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color:
                    isSelected ? AppTheme.accentColor : AppTheme.textTertiary,
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
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                      ),
                      if (isDefault && !isAddNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected && !isAddNew)
              const Icon(
                Icons.check_circle,
                color: AppTheme.accentColor,
              ),
          ],
        ),
      ),
    );
  }

  String _getAddressTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return 'Home';
      case 'work':
        return 'Work';
      case 'office':
        return 'Office';
      default:
        return type.substring(0, 1).toUpperCase() + type.substring(1);
    }
  }

  IconData _getAddressIcon(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
      case 'office':
        return Icons.business_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),

          // Saved Payment Methods Section
          if (_savedPaymentMethods.isNotEmpty) ...[
            Text(
              'Saved Payment Methods',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            ..._savedPaymentMethods.map((method) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSavedPaymentMethodOption(method),
                )),

            // Add Payment Method Option
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAddPaymentMethodOption(),
            ),

            const SizedBox(height: 24),
            Text(
              'Or Choose New Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            // No saved payment methods - show message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.payment_outlined,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Saved Payment Methods',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a payment method below or add one for faster checkout',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Manual Payment Options
          _buildPaymentOption(
            'card',
            'Credit/Debit Card',
            'Visa, Mastercard, etc.',
            Icons.credit_card,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'momo',
            'Mobile Money',
            'MTN, Orange Money',
            Icons.phone_android,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'cash',
            'Cash on Delivery',
            'Pay when you receive',
            Icons.money,
          ),

          // Payment Details Forms
          if (_selectedPayment == 'momo') ...[
            const SizedBox(height: 24),
            _buildMomoPaymentForm(),
          ] else if (_selectedPayment == 'card') ...[
            const SizedBox(height: 24),
            _buildCardPaymentForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPaymentMethodOption() {
    return GestureDetector(
      onTap: () async {
        // Navigate to Payment Methods screen where user can add new payment methods
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PaymentMethodsScreen(),
          ),
        );

        // Reload payment methods if user added a new one
        if (result == true) {
          await _loadData();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.accentColor.withValues(alpha: 0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Payment Method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Save a payment method for faster checkout',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.accentColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPaymentMethodOption(PaymentMethodModel method) {
    final isSelected = _selectedPayment == method.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = method.id;
          // Clear manual payment form data when selecting saved method
          _phoneController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentColor.withValues(alpha: 0.1)
                    : AppTheme.textTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                method.icon,
                color:
                    isSelected ? AppTheme.accentColor : AppTheme.textTertiary,
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
                        method.formattedDisplay,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                      ),
                      if (method.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.accentColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      String value, String title, String subtitle, IconData icon) {
    final isSelected = _selectedPayment == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = value;
          // Clear MOMO phone number when switching methods
          _phoneController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentColor.withValues(alpha: 0.1)
                    : AppTheme.textTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color:
                    isSelected ? AppTheme.accentColor : AppTheme.textTertiary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.accentColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMomoPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Money Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '+237 6XX XXX XXX or +1 XXX XXX XXXX',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppTheme.surfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your mobile money phone number',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildCardPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Payment',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.security,
                size: 48,
                color: AppTheme.accentColor,
              ),
              const SizedBox(height: 12),
              Text(
                'Secure Payment',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your card details will be processed securely by our payment provider. We never store your card information.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.credit_card, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Visa, Mastercard, American Express',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Card details will be collected securely during payment processing',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildCustomizationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize Your Cakes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add special touches to each cake in your order',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),

          // List of cart items with customization options
          ..._cart.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildItemCustomizationCard(item, index);
          }).toList(),

          const SizedBox(height: 24),

          // Order-level customizations
          Container(
            padding: const EdgeInsets.all(16),
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
                  'Order Customizations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Additional instructions and specifications for your entire order',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),

                // Delivery Instructions
                Text(
                  'Delivery Instructions (Optional)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _instructionsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g., Leave at front door, Ring doorbell twice...',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),

                const SizedBox(height: 16),

                // Gender Specification
                Text(
                  'Gender Specification (Optional)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Specify the target gender for this order',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _targetGender,
                  decoration: InputDecoration(
                    hintText: 'Select target gender for this order',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    prefixIcon: const Icon(Icons.person, color: AppTheme.accentColor),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Not specified')),
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _targetGender = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCustomizationCard(CartItem item, int index) {
    final itemId = item.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          // Item header
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: AppTheme.primaryGradient,
                ),
                child: item.cakeImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.cakeImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.cake,
                              color: Colors.white,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.cake,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.cakeTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    Text(
                      '${item.selectedSize} • ${item.selectedFlavor} • Qty: ${item.quantity}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Delivery Date & Time
          _buildDeliveryDateTimeSection(itemId),
          
          const SizedBox(height: 16),
          
          // Color Selection
          _buildColorSelectionSection(itemId),
          
          const SizedBox(height: 16),
          
          // Special Instructions
          _buildSpecialInstructionsSection(itemId),
          
          const SizedBox(height: 16),
          
          // Reference Images
          _buildReferenceImagesSection(itemId),
        ],
      ),
    );
  }

  Widget _buildDeliveryDateTimeSection(String itemId) {
    final customizations = _itemCustomizations[itemId] ?? {};
    final deliveryDate = customizations['deliveryDate'] as DateTime?;
    final deliveryTime = customizations['deliveryTime'] as TimeOfDay?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Date & Time',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDeliveryDate(itemId),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.surfaceColor,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.accentColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          deliveryDate != null
                              ? '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}'
                              : 'Select Date',
                          style: TextStyle(
                            color: deliveryDate != null
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDeliveryTime(itemId),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.surfaceColor,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppTheme.accentColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          deliveryTime != null
                              ? '${deliveryTime.hour.toString().padLeft(2, '0')}:${deliveryTime.minute.toString().padLeft(2, '0')}'
                              : 'Select Time',
                          style: TextStyle(
                            color: deliveryTime != null
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSelectionSection(String itemId) {
    final customizations = _itemCustomizations[itemId] ?? {};
    final selectedColor = customizations['selectedColor'] as Color?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cake Color (Optional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose any color for your cake',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        
        // Color picker button
        GestureDetector(
          onTap: () => _showColorPicker(itemId),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: selectedColor ?? Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedColor != null 
                    ? AppTheme.accentColor 
                    : AppTheme.borderColor,
                width: selectedColor != null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selectedColor ?? Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedColor != null 
                        ? 'Selected Color' 
                        : 'Tap to choose color',
                    style: TextStyle(
                      color: selectedColor != null 
                          ? Colors.white 
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.color_lens,
                  color: selectedColor != null 
                      ? Colors.white 
                      : AppTheme.accentColor,
                ),
              ],
            ),
          ),
        ),
        
        // Clear color button (if color is selected)
        if (selectedColor != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _itemCustomizations[itemId] = {
                  ...customizations,
                  'selectedColor': null,
                };
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Clear Color',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecialInstructionsSection(String itemId) {
    final customizations = _itemCustomizations[itemId] ?? {};
    final instructions = customizations['specialInstructions'] as String? ?? '';
    
    // Get or create controller for this item
    if (!_instructionControllers.containsKey(itemId)) {
      _instructionControllers[itemId] = TextEditingController(text: instructions);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Instructions (Optional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _instructionControllers[itemId],
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g., "Happy Birthday John", pink roses, gold lettering...',
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (value) {
            setState(() {
              _itemCustomizations[itemId] = {
                ...customizations,
                'specialInstructions': value,
              };
            });
          },
        ),
      ],
    );
  }

  Widget _buildReferenceImagesSection(String itemId) {
    final customizations = _itemCustomizations[itemId] ?? {};
    final images = customizations['images'] as List<File>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reference Images (Optional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload images to show us your vision for this cake',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        
        // Upload button
        GestureDetector(
          onTap: () => _pickImages(itemId),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Reference Images',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Display selected images
        if (images.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: images.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          final customizations = _itemCustomizations[itemId] ?? {};
                          final images = List<File>.from(customizations['images'] ?? []);
                          images.removeAt(index);
                          _itemCustomizations[itemId] = {
                            ...customizations,
                            'images': images,
                          };
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDeliveryDate(String itemId) async {
    final customizations = _itemCustomizations[itemId] ?? {};
    final currentDate = customizations['deliveryDate'] as DateTime?;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Select delivery date',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.accentColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != currentDate) {
      setState(() {
        _itemCustomizations[itemId] = {
          ...customizations,
          'deliveryDate': picked,
        };
      });
    }
  }

  Future<void> _selectDeliveryTime(String itemId) async {
    final customizations = _itemCustomizations[itemId] ?? {};
    final currentTime = customizations['deliveryTime'] as TimeOfDay?;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime ?? const TimeOfDay(hour: 10, minute: 0),
      helpText: 'Select delivery time',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.accentColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != currentTime) {
      setState(() {
        _itemCustomizations[itemId] = {
          ...customizations,
          'deliveryTime': picked,
        };
      });
    }
  }

  Future<void> _showColorPicker(String itemId) async {
    final customizations = _itemCustomizations[itemId] ?? {};
    final currentColor = customizations['selectedColor'] as Color? ?? Colors.pink;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Cake Color'),
        content: SizedBox(
          width: 350,
          height: 500,
          child: Column(
            children: [
              // Current color display
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    'Current Color',
                    style: TextStyle(
                      color: _getContrastColor(currentColor),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // HSV Color Picker
              Expanded(
                child: _buildHSVColorPicker(itemId, currentColor),
              ),
              
              const SizedBox(height: 16),
              
              // Quick color buttons
              Text(
                'Quick Colors:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickColors.map((color) {
                  final isSelected = currentColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _itemCustomizations[itemId] = {
                          ...customizations,
                          'selectedColor': color,
                        };
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _itemCustomizations[itemId] = {
                  ...customizations,
                  'selectedColor': null,
                };
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildHSVColorPicker(String itemId, Color currentColor) {
    final customizations = _itemCustomizations[itemId] ?? {};
    
    // Convert to HSV
    final hsv = HSVColor.fromColor(currentColor);
    
    return Column(
      children: [
        // Hue slider
        Text('Hue: ${hsv.hue.round()}°'),
        Slider(
          value: hsv.hue,
          min: 0,
          max: 360,
          divisions: 360,
          onChanged: (value) {
            final newColor = HSVColor.fromAHSV(
              hsv.alpha,
              value,
              hsv.saturation,
              hsv.value,
            ).toColor();
            setState(() {
              _itemCustomizations[itemId] = {
                ...customizations,
                'selectedColor': newColor,
              };
            });
          },
        ),
        
        // Saturation slider
        Text('Saturation: ${(hsv.saturation * 100).round()}%'),
        Slider(
          value: hsv.saturation,
          min: 0,
          max: 1,
          divisions: 100,
          onChanged: (value) {
            final newColor = HSVColor.fromAHSV(
              hsv.alpha,
              hsv.hue,
              value,
              hsv.value,
            ).toColor();
            setState(() {
              _itemCustomizations[itemId] = {
                ...customizations,
                'selectedColor': newColor,
              };
            });
          },
        ),
        
        // Value (brightness) slider
        Text('Brightness: ${(hsv.value * 100).round()}%'),
        Slider(
          value: hsv.value,
          min: 0,
          max: 1,
          divisions: 100,
          onChanged: (value) {
            final newColor = HSVColor.fromAHSV(
              hsv.alpha,
              hsv.hue,
              hsv.saturation,
              value,
            ).toColor();
            setState(() {
              _itemCustomizations[itemId] = {
                ...customizations,
                'selectedColor': newColor,
              };
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        // Color preview grid
        Text(
          'Color Preview:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 24,
            itemBuilder: (context, index) {
              final hue = (index * 15) % 360;
              final color = HSVColor.fromAHSV(1.0, hue.toDouble(), hsv.saturation, hsv.value).toColor();
              final isSelected = currentColor == color;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _itemCustomizations[itemId] = {
                      ...customizations,
                      'selectedColor': color,
                    };
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we should use white or black text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Quick colors for easy selection
  static const List<Color> _quickColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  Future<void> _pickImages(String itemId) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          final customizations = _itemCustomizations[itemId] ?? {};
          final existingImages = List<File>.from(customizations['images'] ?? []);
          final newImages = images.map((xFile) => File(xFile.path)).toList();
          
          _itemCustomizations[itemId] = {
            ...customizations,
            'images': [...existingImages, ...newImages],
          };
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Widget _buildReviewStep() {
    final selectedAddress = _addresses.isNotEmpty
        ? _addresses.firstWhere(
            (addr) => (addr.id ?? addr.type) == _selectedAddress,
            orElse: () => _addresses.first,
          )
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),

          // Order Items
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (_cart.items.isNotEmpty) ...[
                  for (int i = 0; i < _cart.items.length; i++) ...[
                    _buildOrderSummaryItem(_cart.items[i]),
                    if (i < _cart.items.length - 1) const Divider(),
                  ],
                ] else ...[
                  const Text(
                    'No items in cart',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Delivery Address
          _buildSummarySection(
            'Delivery Address',
            selectedAddress?.fullAddress ?? 'No address selected',
            Icons.location_on_outlined,
          ),

          const SizedBox(height: 16),

          // Payment Method
          _buildSummarySection(
            'Payment Method',
            _getPaymentMethodDisplayNameForReview(_selectedPayment),
            _getPaymentMethodIconForReview(_selectedPayment),
          ),

          // Delivery Instructions (if provided)
          if (_instructionsController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSummarySection(
              'Delivery Instructions',
              _instructionsController.text,
              Icons.note_outlined,
            ),
          ],

          // Gender Specification (if provided)
          if (_targetGender != null) ...[
            const SizedBox(height: 16),
            _buildSummarySection(
              'Gender Specification',
              _getGenderDisplayName(_targetGender!),
              Icons.person,
            ),
          ],

          const SizedBox(height: 16),

          // Order Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildTotalRow('Subtotal', _cart.subtotal),
                const Divider(),
                _buildTotalRow('Total', _cart.total, isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryItem(CartItem item) {
    // Get customizations for this item from the checkout customizations
    final customizations = _itemCustomizations[item.id] ?? {};
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.cakeTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${item.selectedSize} • ${item.selectedFlavor} • Qty: ${item.quantity}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.totalPrice.toStringAsFixed(0)} ${item.currency}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          
          // Show customizations if they exist
          if (customizations.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customizations:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Show delivery date and time
                  if (customizations['deliveryDate'] != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppTheme.accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Delivery: ${_formatDeliveryDate(customizations['deliveryDate'])}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  if (customizations['deliveryTime'] != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: AppTheme.accentColor),
                        const SizedBox(width: 8),
                        Text(
                          'Time: ${_formatDeliveryTime(customizations['deliveryTime'])}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  // Show selected color
                  if (customizations['selectedColor'] != null) ...[
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: customizations['selectedColor'] as Color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Custom Color Selected',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  // Show special instructions
                  if (customizations['specialInstructions'] != null && 
                      customizations['specialInstructions'].toString().isNotEmpty) ...[
                    Text(
                      'Instructions: ${customizations['specialInstructions']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  // Show image count
                  if (customizations['images'] != null && 
                      (customizations['images'] as List).isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.image, size: 16, color: AppTheme.accentColor),
                        const SizedBox(width: 4),
                        Text(
                          '${(customizations['images'] as List).length} reference image(s)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDeliveryDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDeliveryTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getPaymentMethodDisplayNameForReview(String method) {
    // Check if it's a saved payment method ID
    if (_savedPaymentMethods.isNotEmpty) {
      try {
        final savedMethod = _savedPaymentMethods.firstWhere(
          (pm) => pm.id == method,
        );
        return savedMethod.formattedDisplay;
      } catch (e) {
        // Not a saved method, treat as manual selection
      }
    }
    
    // Handle manual payment method selections
    switch (method.toLowerCase()) {
      case 'card':
        return 'Credit/Debit Card';
      case 'momo':
        return 'Mobile Money (MOMO)';
      case 'cash':
        return 'Cash on Delivery';
      default:
        return method.substring(0, 1).toUpperCase() + method.substring(1);
    }
  }

  IconData _getPaymentMethodIconForReview(String method) {
    // Check if it's a saved payment method ID
    if (_savedPaymentMethods.isNotEmpty) {
      try {
        final savedMethod = _savedPaymentMethods.firstWhere(
          (pm) => pm.id == method,
        );
        return savedMethod.type.toString().contains('card') 
            ? Icons.credit_card 
            : Icons.phone_android;
      } catch (e) {
        // Not a saved method, treat as manual selection
      }
    }
    
    // Handle manual payment method selections
    switch (method.toLowerCase()) {
      case 'card':
        return Icons.credit_card;
      case 'momo':
        return Icons.phone_android;
      case 'cash':
        return Icons.payments_outlined;
      default:
        return Icons.payment;
    }
  }

  Widget _buildSummarySection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color:
                      isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} XAF',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isTotal ? AppTheme.accentColor : AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    bool canProceed = true;
    String? errorMessage;

    // Validation based on current step
    switch (_currentStep) {
      case 0: // Address step
        if (_addresses.isEmpty) {
          canProceed = false;
          errorMessage = 'Please add an address to continue';
        } else if (_selectedAddress.isEmpty || _selectedAddress == 'add_new') {
          canProceed = false;
          errorMessage = 'Please select a delivery address';
        }
        break;
      case 1: // Payment step
        if (_selectedPayment.isEmpty) {
          canProceed = false;
          errorMessage = 'Please select a payment method';
        } else if (_selectedPayment == 'momo' &&
            _phoneController.text.trim().isEmpty) {
          canProceed = false;
          errorMessage = 'Please enter your mobile money phone number';
        }
        // Card payment doesn't require validation here since details are collected securely later
        break;
      case 2: // Review step
        if (_cart.items.isEmpty) {
          canProceed = false;
          errorMessage = 'Your cart is empty';
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canProceed && errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.accentColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(color: AppTheme.accentColor),
                    ),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 16),
              Expanded(
                flex: _currentStep == 0 ? 1 : 2,
                child: ElevatedButton(
                  onPressed: canProceed && !_isPlacingOrder
                      ? () {
                          if (_currentStep < 3) {
                            setState(() {
                              _currentStep++;
                            });
                          } else {
                            _placeOrder();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canProceed
                        ? AppTheme.accentColor
                        : AppTheme.textTertiary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _currentStep < 3 ? 'Continue' : 'Place Order',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;

    setState(() => _isPlacingOrder = true);

    try {
      // Get selected address
      final selectedAddress = _addresses.firstWhere(
        (addr) =>
            (addr.id != null && addr.id == _selectedAddress) ||
            addr.type == _selectedAddress,
        orElse: () => _addresses.first,
      );

      // Determine the payment method from selection
      PaymentMethod paymentMethod;

      // Check if selected payment is a saved method (by ID)
      final savedMethod = _savedPaymentMethods
          .where((method) => method.id == _selectedPayment)
          .firstOrNull;

      if (savedMethod != null) {
        // Use saved payment method
        // Map saved method type to PaymentMethod enum
        switch (savedMethod.type.toLowerCase()) {
          case 'mobile_money':
          case 'momo':
            paymentMethod = PaymentMethod.momo;
            break;
          case 'card':
            paymentMethod = PaymentMethod.card;
            break;
          default:
            paymentMethod = PaymentMethod.cash;
        }
// print('DEBUG: Using saved payment method: ${savedMethod.type} -> ${paymentMethod.name}');
      } else {
        // Use manually entered payment method
        paymentMethod = PaymentMethod.values.firstWhere(
          (method) => method.name == _selectedPayment,
          orElse: () => PaymentMethod.cash,
        );
// print('DEBUG: Using manual payment method: $_selectedPayment -> ${paymentMethod.name}');
      }

      // Create payment request with customizations
      final itemsWithCustomizations = _cart.items.map((item) {
        final customizations = _itemCustomizations[item.id];
        if (customizations != null && customizations.isNotEmpty) {
          return item.copyWith(customizations: customizations);
        }
        return item;
      }).toList();
      
      final paymentRequest = PaymentRequest(
        items: itemsWithCustomizations,
        deliveryAddress: selectedAddress,
        paymentMethod: paymentMethod,
        deliveryInstructions: _instructionsController.text.trim(),
        expectedDeliveryDate: null, // Delivery date is handled in cart
        customerNotes: _targetGender != null
            ? 'Gender: ${_getGenderDisplayName(_targetGender!)}'
            : '',
      );

// print('DEBUG: Initiating payment with method: ${paymentMethod.name}');

      // For cash payments, create order directly without payment processing
      if (paymentMethod == PaymentMethod.cash) {
        final orderResponse = await ApiService.post(
          '/orders',
          data: paymentRequest.toJson(),
        );

        if (orderResponse.statusCode == 201 && orderResponse.data['success'] == true) {
          final orderData = orderResponse.data['data'];
          final orderId = orderData['_id']?.toString() ?? '';

          // Clear the cart
          await CartService.clearCart();

          setState(() => _isPlacingOrder = false);

          if (mounted) {
            _showOrderSuccessDialog(orderId);
          }
        } else {
          throw Exception('Failed to create order');
        }
      } else {
        // Initiate payment for non-cash methods
        final paymentResponse =
            await PaymentService.initiatePayment(paymentRequest);

// print('DEBUG: Payment initiated, orderId: ${paymentResponse.orderId}');

        // Clear the cart
        await CartService.clearCart();

        setState(() => _isPlacingOrder = false);

        // Navigate to payment waiting screen for other payment methods
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentWaitingScreen(
                orderId: paymentResponse.orderId,
                paymentMethod: paymentMethod,
                amount: _cart.total,
                paymentDetails: _getPaymentDetails(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isPlacingOrder = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _getGenderDisplayName(String gender) {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return 'Not specified';
    }
  }

  Map<String, dynamic>? _getPaymentDetails() {
    // Check if this is a saved payment method
    try {
      final savedMethod = _savedPaymentMethods.firstWhere(
        (method) => method.id == _selectedPayment,
      );

      // Using saved payment method
      if (savedMethod.type == 'mobile_money') {
        return {
          'phoneNumber': savedMethod.phoneNumber ?? '',
          'provider': savedMethod.displayName,
        };
      } else if (savedMethod.type == 'card') {
        return {
          'paymentMethod': 'card',
          'cardType': savedMethod.brand,
          'lastFour': savedMethod.lastFourDigits,
        };
      }
    } catch (e) {
      // Not a saved payment method, continue to manual selection
    }

    // Manual payment method selection
    switch (_selectedPayment) {
      case 'momo':
        return {
          'phoneNumber': _phoneController.text.trim(),
        };
      case 'card':
        // Card details are handled securely by the payment provider
        // We don't collect or store sensitive card information in the app
        return {
          'paymentMethod': 'card',
          'note': 'Card details collected securely by payment provider',
        };
      default:
        return null;
    }
  }

  void _showQuickLocationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          minHeight: 200,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                'Enter Delivery Location',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Quickly enter your delivery address details',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),

              const SizedBox(height: 24),

              // Form fields
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Street Address
                      TextField(
                        controller: _quickStreetController,
                        decoration: InputDecoration(
                          labelText: 'Street Address',
                          hintText: 'Enter street name and number',
                          prefixIcon: const Icon(Icons.home_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // City
                      TextField(
                        controller: _quickCityController,
                        decoration: InputDecoration(
                          labelText: 'City',
                          hintText: 'Enter city name',
                          prefixIcon: const Icon(Icons.location_city_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // State/Region
                      TextField(
                        controller: _quickStateController,
                        decoration: InputDecoration(
                          labelText: 'State/Region',
                          hintText: 'Enter state or region',
                          prefixIcon: const Icon(Icons.map_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Country Dropdown
                      DropdownButtonFormField<String>(
                        initialValue:
                            _countries.any((c) => c.code == _quickCountry)
                                ? _quickCountry
                                : null,
                        decoration: InputDecoration(
                          labelText: 'Country',
                          prefixIcon: const Icon(Icons.public_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _countries.isEmpty
                            ? [
                                const DropdownMenuItem(
                                    value: null, child: Text('Loading...'))
                              ]
                            : _countries
                                .map((country) => DropdownMenuItem(
                                      value: country.code,
                                      child: Text(
                                          '${country.flag} ${country.name}'),
                                    ))
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _quickCountry = value ?? 'CM';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

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
                      onPressed: () {
                        if (_quickStreetController.text.trim().isEmpty ||
                            _quickCityController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please enter at least street and city'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }

                        // Create a temporary address for this order
                        final quickAddress = Address(
                          type: 'temporary',
                          street: _quickStreetController.text.trim(),
                          city: _quickCityController.text.trim(),
                          state: _quickStateController.text.trim().isEmpty
                              ? 'N/A'
                              : _quickStateController.text.trim(),
                          zipCode:
                              '00000', // Default for areas without zip codes
                          country: _quickCountry,
                          isDefault: false,
                        );

                        // Add to addresses list temporarily and select it
                        setState(() {
                          _addresses.add(quickAddress);
                          _selectedAddress = 'temporary';
                        });

                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Location added successfully!'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Use This Location',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Placed Successfully!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your order #$orderId has been placed successfully. You will pay when your order is delivered.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pushNamed('/orders');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'View Orders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continue Shopping',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
