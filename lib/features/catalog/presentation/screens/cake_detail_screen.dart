import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// REMOVED - Image picker imports moved to checkout page
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../data/repositories/cake_repository.dart';
import '../../data/models/cake_model.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/models/cart_model.dart';

class CakeDetailScreen extends ConsumerStatefulWidget {
  final String cakeId;

  const CakeDetailScreen({
    super.key,
    required this.cakeId,
  });

  @override
  ConsumerState<CakeDetailScreen> createState() => _CakeDetailScreenState();
}

class _CakeDetailScreenState extends ConsumerState<CakeDetailScreen> {
  int _quantity = 1;
  CakeSize? _selectedSize;
  String? _selectedFlavor;
  
  // REMOVED - Customization options moved to checkout page
  // final _customizationController = TextEditingController();
  // DateTime? _selectedDeliveryDate;
  // TimeOfDay? _selectedDeliveryTime;
  // String? _selectedColor;
  // List<File> _customizationImages = [];
  // final ImagePicker _imagePicker = ImagePicker();

  // State management
  CakeStyle? _cake;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFavorite = false;
  bool _isInCart = false;
  int _currentCartQuantity = 0;

  @override
  void initState() {
    super.initState();
    _loadCake();
  }

  @override
  void dispose() {
    // _customizationController.dispose(); // REMOVED - moved to checkout
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh cart status when returning to this screen
    if (!_isLoading && _cake != null) {
      _checkCartStatus();
    }
  }

  Future<void> _loadCake() async {
    try {
// print('DEBUG: Loading cake with ID: ${widget.cakeId}');
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final cake = await CakeRepository.getCakeById(widget.cakeId);

      // Try to load favorite status, but don't fail if it errors
      bool isFavorite = false;
      try {
        isFavorite = await FavoritesService.isFavorite(widget.cakeId);
// print('DEBUG: Favorite status loaded: $isFavorite');
      } catch (e) {
// print('DEBUG: Error loading favorite status (continuing anyway): $e');
        // Continue without favorites functionality
      }

// print('DEBUG: Successfully loaded cake: ${cake.title}');
      setState(() {
        _cake = cake;
        _isFavorite = isFavorite;
        _isLoading = false;
        // Set default selections
        if (cake.sizes.isNotEmpty) {
          _selectedSize = cake.sizes.first;
        }
        if (cake.flavors.isNotEmpty) {
          _selectedFlavor = cake.flavors.first;
        }
      });

      // Check cart status after setting default selections
      _checkCartStatus();
    } catch (e) {
// print('DEBUG: Error loading cake with ID ${widget.cakeId}: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final success = await FavoritesService.toggleFavorite(widget.cakeId);
      if (success) {
        setState(() {
          _isFavorite = !_isFavorite;
        });

        // Show feedback to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isFavorite
                  ? 'Added to favorites'
                  : 'Removed from favorites'),
              duration: const Duration(seconds: 2),
              backgroundColor:
                  _isFavorite ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          );
        }
      }
    } catch (e) {
// print('DEBUG: Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorites'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _addToCart() async {
    if (_cake == null || _selectedSize == null || _selectedFlavor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select size and flavor'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      // Calculate price based on selected size
      final basePrice = _cake!.basePrice;
      final sizeMultiplier = _selectedSize!.multiplier;
      final finalPrice =
          _selectedSize!.basePriceOverride ?? (basePrice * sizeMultiplier);

      // REMOVED - Customizations will be handled in checkout page
      // final customizations = <String, dynamic>{};

      final cartItem = CartItem(
        id: '', // Will be generated by CartService
        cakeId: _cake!.id,
        cakeTitle: _cake!.title,
        cakeImageUrl: _cake!.images.isNotEmpty ? _cake!.images.first : '',
        selectedSize: _selectedSize!.name,
        selectedFlavor: _selectedFlavor!,
        unitPrice: finalPrice,
        quantity: _quantity,
        currency: 'XAF',
        customizations: null, // Customizations will be handled in checkout
      );

      final success = await CartService.addToCart(cartItem);

      if (success && mounted) {
        // Refresh cart status to update button text
        _checkCartStatus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isInCart
                ? '${_cake!.title} updated in cart!'
                : '${_cake!.title} added to cart!'),
            backgroundColor: AppTheme.successColor,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed('/cart');
              },
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add item to cart'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
// print('DEBUG: Error adding to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add item to cart'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _checkCartStatus() {
    if (_cake != null && _selectedSize != null && _selectedFlavor != null) {
      final cartItem = CartService.findItem(
          _cake!.id, _selectedSize!.name, _selectedFlavor!);
      setState(() {
        _isInCart = cartItem != null;
        _currentCartQuantity = cartItem?.quantity ?? 0;
      });
    } else {
      setState(() {
        _isInCart = false;
        _currentCartQuantity = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return LoadingOverlay(
        isLoading: true,
        message: 'Loading cake details...',
        child: Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: const Text('Loading...'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: const SizedBox(),
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              const Text('Failed to load cake'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCake,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // No cake found
    if (_cake == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Cake Not Found'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Cake not found'),
        ),
      );
    }

    final cake = _cake!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Carousel
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primaryColor,
                child: cake.images.isNotEmpty
                    ? Stack(
                        children: [
                          PageView.builder(
                            itemCount: cake.images.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                cake.images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 120,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          // Image counter indicator (bottom center)
                          if (cake.images.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${cake.images.length} photos',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : const Center(
                        child: Icon(
                          Icons.cake,
                          size: 120,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            actions: [
              IconButton(
                icon:
                    Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                color: _isFavorite ? AppTheme.errorColor : Colors.white,
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                color: Colors.white,
                onPressed: () {
                  // TODO: Share cake
                },
              ),
            ],
          ),

          // Cake Details
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cake.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'XAF ${cake.basePrice.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      cake.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                    ),

                    const SizedBox(height: 24),

                    // Size Selection
                    _buildSectionTitle('Size'),
                    const SizedBox(height: 12),
                    _buildSizeSelector(),

                    const SizedBox(height: 24),

                    // Flavor Selection
                    _buildSectionTitle('Flavor'),
                    const SizedBox(height: 12),
                    _buildFlavorSelector(),

                    const SizedBox(height: 24),

                    // Quantity Selection
                    _buildSectionTitle('Quantity'),
                    const SizedBox(height: 12),
                    _buildQuantitySelector(),

                    const SizedBox(height: 24),

                    // REMOVED - Delivery date/time moved to checkout page
                    // _buildSectionTitle('Delivery Date & Time'),
                    // const SizedBox(height: 12),
                    // _buildDeliveryDateTimeSelector(),

                    const SizedBox(height: 24),

                    // REMOVED - Customization moved to checkout page
                    // _buildSectionTitle('Customization Instructions'),
                    // const SizedBox(height: 12),
                    // _buildCustomizationInput(),

                    const SizedBox(height: 32),

                    // Ingredients
                    _buildSectionTitle('Ingredients'),
                    const SizedBox(height: 12),
                    Text(
                      'Premium flour, fresh eggs, organic butter, pure vanilla extract, Belgian chocolate, fresh cream, and natural flavoring.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                    ),

                    const SizedBox(height: 32),

                    // Nutritional Info
                    _buildSectionTitle('Nutritional Information'),
                    const SizedBox(height: 12),
                    _buildNutritionalInfo(),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, cake),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
    );
  }

  Widget _buildSizeSelector() {
    if (_cake == null || _cake!.sizes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: _cake!.sizes.map((size) {
        final isSelected = _selectedSize == size;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedSize = size);
              _checkCartStatus();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppTheme.accentColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? AppTheme.accentColor : AppTheme.borderColor,
                ),
              ),
              child: Text(
                size.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFlavorSelector() {
    if (_cake == null || _cake!.flavors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _cake!.flavors.map((flavor) {
        final isSelected = _selectedFlavor == flavor;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedFlavor = flavor);
            _checkCartStatus();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.accentColor : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
              ),
            ),
            child: Text(
              flavor,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed:
                    _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(Icons.remove),
                color: AppTheme.textPrimary,
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '$_quantity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add),
                color: AppTheme.textPrimary,
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          'Total: ${CartService.formatCurrency(_calculateTotalPrice())}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
        ),
      ],
    );
  }

  Widget _buildNutritionalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          _buildNutritionalRow('Calories', '350 per slice'),
          _buildNutritionalRow('Protein', '6g'),
          _buildNutritionalRow('Carbohydrates', '45g'),
          _buildNutritionalRow('Fat', '18g'),
          _buildNutritionalRow('Sugar', '28g'),
        ],
      ),
    );
  }

  Widget _buildNutritionalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, CakeStyle cake) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isInCart
                    ? 'Update Cart ($_currentCartQuantity)'
                    : 'Add to Cart',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surfaceColor,
              side: const BorderSide(color: AppTheme.accentColor),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  // REMOVED - Delivery date/time selection methods moved to checkout page
  /*
  Future<void> _selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeliveryDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
    if (picked != null && picked != _selectedDeliveryDate) {
      setState(() {
        _selectedDeliveryDate = picked;
      });
    }
  }

  Future<void> _selectDeliveryTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDeliveryTime ?? const TimeOfDay(hour: 14, minute: 0),
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
    if (picked != null && picked != _selectedDeliveryTime) {
      setState(() {
        _selectedDeliveryTime = picked;
      });
    }
  }
  */

  // REMOVED - Delivery date/time selector moved to checkout page
  /*
  Widget _buildDeliveryDateTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          // Date Selector
          InkWell(
            onTap: _selectDeliveryDate,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppTheme.accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDeliveryDate == null
                          ? 'Select delivery date'
                          : '${_selectedDeliveryDate!.day}/${_selectedDeliveryDate!.month}/${_selectedDeliveryDate!.year}',
                      style: TextStyle(
                        color: _selectedDeliveryDate == null
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Time Selector
          InkWell(
            onTap: _selectDeliveryTime,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: AppTheme.accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDeliveryTime == null
                          ? 'Select delivery time'
                          : '${_selectedDeliveryTime!.hour.toString().padLeft(2, '0')}:${_selectedDeliveryTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _selectedDeliveryTime == null
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  */

  // REMOVED - Customization methods moved to checkout page
  /*
  Widget _buildCustomizationInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cake Customization',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your cake with colors, messages, and reference images',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          
          // Color Selection
          _buildColorSelection(),
          const SizedBox(height: 16),
          
          // Special Instructions
          Text(
            'Special Instructions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customizationController,
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
          ),
          const SizedBox(height: 16),
          
          // Image Upload Section
          _buildImageUploadSection(),
        ],
      ),
    );
  }
  */

  // REMOVED - Color selection moved to checkout page
  /*
  Widget _buildColorSelection() {
    final colors = [
      {'name': 'Pink', 'color': Colors.pink},
      {'name': 'Blue', 'color': Colors.blue},
      {'name': 'Purple', 'color': Colors.purple},
      {'name': 'Red', 'color': Colors.red},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Yellow', 'color': Colors.yellow},
      {'name': 'Orange', 'color': Colors.orange},
      {'name': 'White', 'color': Colors.white},
      {'name': 'Black', 'color': Colors.black},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Color Theme',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((colorData) {
            final isSelected = _selectedColor == colorData['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = isSelected ? null : colorData['name'] as String;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorData['color'] as Color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.accentColor : AppTheme.borderColor,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  */

  // REMOVED - Image upload section moved to checkout page
  /*
  Widget _buildImageUploadSection() {
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
          'Upload images to show us your vision for the cake',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        
        // Upload button
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
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
        if (_customizationImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _customizationImages.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(image),
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
                          _customizationImages.removeAt(index);
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

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _customizationImages.addAll(images.map((xFile) => File(xFile.path)));
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
  */

  double _calculateTotalPrice() {
    if (_cake == null) return 0.0;

    double basePrice = _cake!.basePrice;

    // Apply size multiplier if a size is selected
    if (_selectedSize != null) {
      if (_selectedSize!.basePriceOverride != null) {
        basePrice = _selectedSize!.basePriceOverride!;
      } else {
        basePrice = _cake!.basePrice * _selectedSize!.multiplier;
      }
    }

    return basePrice * _quantity;
  }
}
