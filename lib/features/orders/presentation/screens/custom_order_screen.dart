import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:denzels_cakes/l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/shop_whatsapp.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/services/admin_api_service.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../../../features/profile/presentation/screens/add_address_with_map_screen.dart';
import '../../../../core/models/user_model.dart';

class CustomOrderScreen extends StatefulWidget {
  const CustomOrderScreen({super.key});

  @override
  State<CustomOrderScreen> createState() => _CustomOrderScreenState();
}

class _CustomOrderScreenState extends State<CustomOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _cakeTypeController = TextEditingController();
  final _sizeController = TextEditingController();
  final _flavorController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  String _deliveryType = 'delivery';
  DateTime? _selectedEventDate;
  String? _targetAgeGroup; // Age group specification for the order
  String? _targetGender; // Gender specification for the order
  bool _isSubmitting = false;
  bool _isSearchingAddress = false;
  List<Placemark> _addressSuggestions = [];
  Timer? _addressSearchDebounce;
  final LayerLink _addressLayerLink = LayerLink();
  OverlayEntry? _addressOverlay;
  
  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isUploadingImages = false;

  List<String> _cakeTypes(AppLocalizations l10n) => [
        l10n.categoryBirthday,
        l10n.categoryWedding,
        l10n.categoryAnniversary,
        l10n.categoryBabyShower,
        l10n.optionCustom,
        l10n.optionOther,
      ];

  List<String> _sizes(AppLocalizations l10n) => [
        l10n.smallCake,
        l10n.mediumCake,
        l10n.largeCake,
        l10n.extraLargeCake,
      ];

  List<String> _flavors(AppLocalizations l10n) => [
        l10n.flavorVanilla,
        l10n.flavorChocolate,
        l10n.flavorStrawberry,
        l10n.flavorRedVelvet,
        l10n.flavorLemon,
        l10n.flavorCarrot,
        l10n.optionCustom,
      ];

  List<String> _deliveryTimes(AppLocalizations l10n) => [
        l10n.morning,
        l10n.afternoon,
        l10n.evening,
      ];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _addressController.addListener(_onAddressChanged);
  }

  void _onAddressChanged() {
    _addressSearchDebounce?.cancel();
    if (_addressController.text.length > 2) {
      _addressSearchDebounce = Timer(const Duration(milliseconds: 500), () {
        _searchAddresses(_addressController.text);
      });
    } else {
      _hideAddressSuggestions();
    }
  }

  Future<void> _searchAddresses(String query) async {
    if (query.length < 3) {
      _hideAddressSuggestions();
      return;
    }

    setState(() {
      _isSearchingAddress = true;
    });

    try {
      // Use geocoding to search for addresses
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          locations.first.latitude,
          locations.first.longitude,
        );
        setState(() {
          _addressSuggestions = placemarks;
          _isSearchingAddress = false;
        });
        _showAddressSuggestions();
      } else {
        setState(() {
          _addressSuggestions = [];
          _isSearchingAddress = false;
        });
        _hideAddressSuggestions();
      }
    } catch (e) {
      setState(() {
        _isSearchingAddress = false;
      });
      _hideAddressSuggestions();
    }
  }

  void _showAddressSuggestions() {
    _hideAddressSuggestions();
    if (!mounted) return;

    _addressOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop to close on tap outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _hideAddressSuggestions(),
              child: Container(color: Colors.transparent),
            ),
          ),
          // Suggestions dropdown
          CompositedTransformFollower(
            link: _addressLayerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 56),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                width: MediaQuery.of(context).size.width - 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isSearchingAddress
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _addressSuggestions.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No addresses found'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _addressSuggestions.length,
                            itemBuilder: (context, index) {
                              final place = _addressSuggestions[index];
                              final addressText = _formatPlacemark(place);
                              return ListTile(
                                leading: const Icon(Icons.location_on, color: AppTheme.accentColor),
                                title: Text(addressText),
                                onTap: () {
                                  _addressController.text = addressText;
                                  _hideAddressSuggestions();
                                },
                              );
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_addressOverlay!);
  }

  void _hideAddressSuggestions() {
    _addressOverlay?.remove();
    _addressOverlay = null;
  }

  String _formatPlacemark(Placemark place) {
    final parts = <String>[];
    if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
    if (place.subLocality != null && place.subLocality!.isNotEmpty) parts.add(place.subLocality!);
    if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) parts.add(place.administrativeArea!);
    if (place.country != null && place.country!.isNotEmpty) parts.add(place.country!);
    return parts.join(', ');
  }

  @override
  void dispose() {
    _addressSearchDebounce?.cancel();
    _hideAddressSuggestions();
    _cakeTypeController.dispose();
    _sizeController.dispose();
    _flavorController.dispose();
    _eventDateController.dispose();
    _descriptionController.dispose();
    _addressController.removeListener(_onAddressChanged);
    _addressController.dispose();
    _deliveryTimeController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await AddressService.getUserAddresses();
      if (addresses.isNotEmpty) {
        final defaultAddress = addresses.firstWhere(
          (addr) => addr.isDefault,
          orElse: () => addresses.first,
        );
        setState(() {
          _addressController.text =
              '${defaultAddress.street}, ${defaultAddress.city}';
        });
      }
    } catch (e) {
      // User might not be logged in, that's okay
    }
  }

  Future<void> _selectEventDate() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEventDate ?? now.add(const Duration(days: 7)),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: l10n.selectEventDate,
    );

    if (picked != null) {
      setState(() {
        _selectedEventDate = picked;
        _eventDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  String _extractTimeFromString(String timeString) {
    if (timeString.contains('Morning')) {
      return '10:00';
    } else if (timeString.contains('Afternoon')) {
      return '14:00';
    } else if (timeString.contains('Evening')) {
      return '17:00';
    }
    return '12:00';
  }

  Map<String, dynamic> _parseAddress(String addressString) {
    final parts = addressString.split(',').map((p) => p.trim()).toList();
    return {
      'street': parts.isNotEmpty ? parts[0] : addressString,
      'city': parts.length > 1 ? parts[1] : 'Douala',
      'state': parts.length > 2 ? parts[2] : 'Littoral',
    };
  }

  double _calculateEstimatedPrice() {
    if (_budgetController.text.isNotEmpty) {
      return double.tryParse(_budgetController.text) ?? 30000;
    }

    // Estimate based on size
    final sizeMultipliers = {
      'Small (1-5 people)': 1.0,
      'Medium (6-15 people)': 1.5,
      'Large (16-30 people)': 2.0,
      'Extra Large (30+ people)': 3.0,
    };
    final multiplier = sizeMultipliers[_sizeController.text] ?? 1.0;
    return 30000 * multiplier;
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images.map((xFile) => File(xFile.path)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) {
      return [];
    }

    setState(() => _isUploadingImages = true);
    List<String> uploadedUrls = [];

    try {
      for (final imageFile in _selectedImages) {
        try {
          final imageUrl = await AdminApiService.uploadImage(imageFile);
          uploadedUrls.add(imageUrl);
        } catch (e) {
          // Continue with other images if one fails
          debugPrint('Failed to upload image: $e');
        }
      }
    } finally {
      setState(() => _isUploadingImages = false);
    }

    return uploadedUrls;
  }

  String _customOrderWhatsAppMessage(AppLocalizations l10n, String? name) {
    String audience = l10n.notSpecified;
    final parts = <String>[];
    if (_targetAgeGroup == 'adults') parts.add(l10n.adults);
    if (_targetAgeGroup == 'kids') parts.add(l10n.kids);
    switch (_targetGender) {
      case 'male':
        parts.add(l10n.male);
      case 'female':
        parts.add(l10n.female);
      case 'boy':
        parts.add(l10n.boy);
      case 'girl':
        parts.add(l10n.girl);
    }
    if (parts.isNotEmpty) audience = parts.join(', ');

    final deliveryLabel =
        _deliveryType == 'pickup' ? l10n.pickup : l10n.delivery;
    final lines = <String>[
      ShopWhatsApp.introduce(l10n, name, l10n.whatsappOrderCustomCake),
      '',
      '${l10n.cakeType}: ${_cakeTypeController.text}',
      '${l10n.cakeSize}: ${_sizeController.text}',
      '${l10n.cakeFlavor}: ${_flavorController.text}',
      '${l10n.ageGroupAndGender}: $audience',
      '${l10n.eventDate}: ${_eventDateController.text}',
      '${l10n.deliveryType}: $deliveryLabel',
      '${l10n.deliveryAddress}: ${_addressController.text}',
    ];
    if (_deliveryTimeController.text.isNotEmpty) {
      lines.add('${l10n.preferredDeliveryTime}: ${_deliveryTimeController.text}');
    }
    if (_budgetController.text.isNotEmpty) {
      lines.add('${l10n.estimatedBudget}: ${_budgetController.text}');
    }
    if (_descriptionController.text.isNotEmpty) {
      lines.add('${l10n.cakeDescription}: ${_descriptionController.text}');
    }
    if (_notesController.text.isNotEmpty) {
      lines.add('${l10n.additionalNotes}: ${_notesController.text}');
    }
    return lines.join('\n');
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);

    try {
      // Upload images first
      final imageUrls = await _uploadImages();
      
      final addressParts = _parseAddress(_addressController.text);
      final estimatedPrice = _calculateEstimatedPrice();
      final eventDate = _selectedEventDate ?? DateTime.now().add(const Duration(days: 7));
      
      // Ensure date is in the future
      final scheduledDate = eventDate.isBefore(DateTime.now())
          ? eventDate.add(const Duration(days: 1))
          : eventDate;

      // Get user info if available
      final user = await AuthRepository.getCurrentUser();
      Map<String, dynamic> guestDetails;
      
      if (user != null) {
        guestDetails = {
          'name': user.name,
          'email': user.email,
          'phone': user.phone ?? '',
          'address': {
            'type': 'home',
            'street': addressParts['street'],
            'city': addressParts['city'],
            'state': addressParts['state'],
            'country': 'CM',
            'isDefault': false,
          },
        };
      } else {
        // Guest order - will be handled by backend
        guestDetails = {
          'name': 'Guest Customer',
          'email': '',
          'phone': '',
          'address': {
            'type': 'home',
            'street': addressParts['street'],
            'city': addressParts['city'],
            'state': addressParts['state'],
            'country': 'CM',
            'isDefault': false,
          },
        };
      }

      final deliveryDetails = {
        'type': _deliveryType,
        'address': _deliveryType == 'delivery' ? {
          'type': 'home',
          'street': addressParts['street'],
          'city': addressParts['city'],
          'state': addressParts['state'],
          'country': 'CM',
          'isDefault': false,
        } : null,
        'scheduledDate': scheduledDate.toIso8601String(),
        'scheduledTime': _deliveryTimeController.text.isNotEmpty
            ? _extractTimeFromString(_deliveryTimeController.text)
            : null,
        'instructions': _notesController.text.isNotEmpty
            ? (_notesController.text.length > 500 
                ? _notesController.text.substring(0, 500) 
                : _notesController.text)
            : '',
      };

      final result = await OrderService.createCustomOrder(
        cakeType: _cakeTypeController.text,
        size: _sizeController.text,
        flavor: _flavorController.text,
        title: '${_cakeTypeController.text} Cake',
        unitPrice: estimatedPrice,
        paymentMethod: 'cash', // Default, can be updated later
        guestDetails: guestDetails,
        deliveryDetails: deliveryDetails,
        customerNotes: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
        targetAgeGroup: _targetAgeGroup,
        targetGender: _targetGender,
      );

      if (mounted) {
        String message = l10n.customOrderSubmitted;
        message += '\n\n${l10n.weWillContactYou}';
        
        if (result['accountCreated'] == true) {
          message += '\n\n${l10n.accountCreatedMessage}';
        } else if (result['existingAccount'] == true) {
          message += '\n\n${l10n.orderLinkedToAccount}';
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.customOrderSubmitted),
            content: SingleChildScrollView(
              child: Text(message),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
        final opened = await ShopWhatsApp.open(
          _customOrderWhatsAppMessage(l10n, user?.name),
        );
        if (!opened && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.whatsappUnavailable(ShopWhatsApp.displayNumber),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiService.readableError(e)),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LoadingOverlay(
      isLoading: _isSubmitting,
      message: l10n.placingYourOrder,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(l10n.customOrder),
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Text(
                  l10n.orderCustomCake,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.weWillContactYou,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),

                // Cake Details Section
                _buildSectionHeader(l10n.cakeDetails),
                const SizedBox(height: 12),

                // Cake Type
                _buildDropdownField(
                  controller: _cakeTypeController,
                  label: l10n.cakeType,
                  hint: l10n.selectCakeType,
                  items: _cakeTypes(l10n),
                  validator: (value) =>
                      value == null || value.isEmpty ? l10n.pleaseSelectCategory : null,
                ),
                const SizedBox(height: 16),

                // Size
                _buildDropdownField(
                  controller: _sizeController,
                  label: l10n.cakeSize,
                  hint: l10n.selectCakeSize,
                  items: _sizes(l10n),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please select size' : null,
                ),
                const SizedBox(height: 16),

                // Flavor
                _buildDropdownField(
                  controller: _flavorController,
                  label: l10n.cakeFlavor,
                  hint: l10n.selectFlavor,
                  items: _flavors(l10n),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please select flavor' : null,
                ),
                const SizedBox(height: 16),

                // Event Date
                _buildDateField(
                  controller: _eventDateController,
                  label: l10n.eventDate,
                  hint: l10n.selectEventDate,
                  onTap: _selectEventDate,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please select event date' : null,
                ),
                const SizedBox(height: 16),

                // Age Group & Gender
                _buildAgeGroupGenderSection(),
                const SizedBox(height: 16),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: l10n.cakeDescription,
                  hint: l10n.describeYourCake,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),

                // Reference Images
                _buildImageSection(),
                const SizedBox(height: 24),

                // Delivery Information Section
                _buildSectionHeader(l10n.deliveryInformation),
                const SizedBox(height: 12),

                // Delivery Address with Map Search
                CompositedTransformTarget(
                  link: _addressLayerLink,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _addressController,
                          label: l10n.deliveryAddress,
                          hint: l10n.enterDeliveryAddress,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Please enter address' : null,
                          suffixIcon: _isSearchingAddress
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : _addressController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _addressController.clear();
                                        _hideAddressSuggestions();
                                      },
                                    )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.map, color: Colors.white),
                          onPressed: () async {
                            final address = await Navigator.of(context).push<Address>(
                              MaterialPageRoute(
                                builder: (context) => AddAddressWithMapScreen(
                                  onSave: (address) {
                                    Navigator.of(context).pop(address);
                                  },
                                ),
                              ),
                            );
                            if (address != null) {
                              setState(() {
                                _addressController.text = '${address.street}, ${address.city}${address.state != null ? ', ${address.state}' : ''}';
                              });
                              _hideAddressSuggestions();
                            }
                          },
                          tooltip: 'Pick location on map',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Delivery Type
                _buildDeliveryTypeSelector(),
                const SizedBox(height: 16),

                // Delivery Time
                _buildDropdownField(
                  controller: _deliveryTimeController,
                  label: l10n.preferredDeliveryTime,
                  hint: l10n.selectDeliveryTime,
                  items: _deliveryTimes(l10n),
                  required: false,
                ),
                const SizedBox(height: 24),

                // Additional Information Section
                _buildSectionHeader(l10n.additionalInformation),
                const SizedBox(height: 12),

                // Budget
                _buildTextField(
                  controller: _budgetController,
                  label: l10n.estimatedBudget,
                  hint: l10n.enterBudget,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  required: false,
                ),
                const SizedBox(height: 16),

                // Additional Notes
                _buildTextField(
                  controller: _notesController,
                  label: l10n.additionalNotes,
                  hint: l10n.anyOtherInformation,
                  maxLines: 3,
                  required: false,
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.submitOrder,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool required = true,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppTheme.backgroundColor,
        suffixIcon: suffixIcon,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: required
          ? (validator ??
              (value) => value == null || value.isEmpty ? 'This field is required' : null)
          : null,
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required List<String> items,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppTheme.backgroundColor,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          controller.text = value ?? '';
        });
      },
      validator: required
          ? (validator ??
              (value) => value == null || value.isEmpty ? 'Please select an option' : null)
          : null,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppTheme.backgroundColor,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: onTap,
      validator: validator ??
          (value) => value == null || value.isEmpty ? 'Please select date' : null,
    );
  }

  Widget _buildDeliveryTypeSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deliveryType,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text(l10n.delivery),
                value: 'delivery',
                groupValue: _deliveryType,
                onChanged: (value) {
                  setState(() {
                    _deliveryType = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text(l10n.pickup),
                value: 'pickup',
                groupValue: _deliveryType,
                onChanged: (value) {
                  setState(() {
                    _deliveryType = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeGroupGenderSection() {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    void selectAge(String? age) {
      setState(() {
        _targetAgeGroup = age;
        final adults = _targetGender == 'male' || _targetGender == 'female';
        final kids = _targetGender == 'boy' || _targetGender == 'girl';
        if (age == 'adults' && kids) _targetGender = null;
        if (age == 'kids' && adults) _targetGender = null;
        if (age == null) _targetGender = null;
      });
    }

    void selectGender(String? gender) {
      setState(() {
        _targetGender = gender;
        if (gender == 'male' || gender == 'female') {
          _targetAgeGroup = 'adults';
        } else if (gender == 'boy' || gender == 'girl') {
          _targetAgeGroup = 'kids';
        }
      });
    }

    Widget chip(String label, bool selected, VoidCallback onTap) {
      return FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ageGroupAndGenderOptional,
          style: textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.specifyAgeGroupAndGender,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Text(l10n.ageGroup, style: textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            chip(l10n.notSpecified, _targetAgeGroup == null, () => selectAge(null)),
            chip(l10n.adults, _targetAgeGroup == 'adults', () => selectAge('adults')),
            chip(l10n.kids, _targetAgeGroup == 'kids', () => selectAge('kids')),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.gender, style: textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            chip(l10n.notSpecified, _targetGender == null, () => selectGender(null)),
            if (_targetAgeGroup != 'kids') ...[
              chip(l10n.male, _targetGender == 'male', () => selectGender('male')),
              chip(l10n.female, _targetGender == 'female', () => selectGender('female')),
            ],
            if (_targetAgeGroup != 'adults') ...[
              chip(l10n.boy, _targetGender == 'boy', () => selectGender('boy')),
              chip(l10n.girl, _targetGender == 'girl', () => selectGender('girl')),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reference Images (Optional)',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload images of cakes you like or reference designs',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImages[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () => _removeImage(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_photo_alternate),
          label: Text(
            _selectedImages.isEmpty
                ? 'Add Reference Images'
                : 'Add More Images',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppTheme.accentColor),
          ),
        ),
        if (_isUploadingImages)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Uploading images...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

