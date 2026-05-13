import 'dart:convert';
import '../models/cart_model.dart';
import './storage_service.dart';

class CartService {
  static const String _cartKey = 'shopping_cart';

  static Cart _currentCart = const Cart();

  // Get current cart
  static Cart get currentCart => _currentCart;

  // Load cart from storage
  static Future<Cart> loadCart() async {
    try {
// print('DEBUG: Loading cart from storage...');
      final cartJson = await StorageService.getString(_cartKey);
// print('DEBUG: Retrieved cart JSON: $cartJson');

      if (cartJson != null) {
        final cartData = jsonDecode(cartJson);
        _currentCart = Cart.fromJson(cartData);
// print('DEBUG: Loaded cart with ${_currentCart.items.length} items');
      } else {
        _currentCart = const Cart();
// print('DEBUG: No cart found in storage, creating empty cart');
      }
      return _currentCart;
    } catch (e) {
// print('DEBUG: Error loading cart: $e');
      _currentCart = const Cart();
      return _currentCart;
    }
  }

  // Save cart to storage
  static Future<bool> saveCart(Cart cart) async {
    try {
// print('DEBUG: Saving cart with ${cart.items.length} items');
      _currentCart = cart;
      final cartJson = jsonEncode(cart.toJson());
// print('DEBUG: Cart JSON to save: $cartJson');
      await StorageService.setString(_cartKey, cartJson);
// print('DEBUG: Cart saved successfully');
      return true;
    } catch (e) {
// print('DEBUG: Error saving cart: $e');
      return false;
    }
  }

  // Add item to cart
  static Future<bool> addToCart(CartItem item) async {
    try {
// print('DEBUG: Adding item to cart: ${item.cakeTitle}');

      // Generate unique ID for cart item
      final cartItem = item.copyWith(
        id: '${item.cakeId}_${item.selectedSize}_${item.selectedFlavor}_${DateTime.now().millisecondsSinceEpoch}',
      );

// print('DEBUG: Cart item with ID: ${cartItem.id}');
// print('DEBUG: Current cart before adding: ${_currentCart.items.length} items');

      final updatedCart = _currentCart.addItem(cartItem);
// print('DEBUG: Updated cart after adding: ${updatedCart.items.length} items');

      final success = await saveCart(updatedCart);
// print('DEBUG: Save cart result: $success');

      return success;
    } catch (e) {
// print('DEBUG: Error adding to cart: $e');
      return false;
    }
  }

  // Remove item from cart
  static Future<bool> removeFromCart(String itemId) async {
    try {
      final updatedCart = _currentCart.removeItem(itemId);
      return await saveCart(updatedCart);
    } catch (e) {
// print('DEBUG: Error removing from cart: $e');
      return false;
    }
  }

  // Update item quantity
  static Future<bool> updateQuantity(String itemId, int quantity) async {
    try {
      final updatedCart = _currentCart.updateItemQuantity(itemId, quantity);
      return await saveCart(updatedCart);
    } catch (e) {
// print('DEBUG: Error updating quantity: $e');
      return false;
    }
  }

  // Clear cart
  static Future<bool> clearCart() async {
    try {
      final emptyCart = _currentCart.clear();
      return await saveCart(emptyCart);
    } catch (e) {
// print('DEBUG: Error clearing cart: $e');
      return false;
    }
  }

  // Get cart item count
  static int getItemCount() {
    return _currentCart.itemCount;
  }

  // Get cart total
  static double getTotal() {
    return _currentCart.total;
  }

  // Get cart subtotal
  static double getSubtotal() {
    return _currentCart.subtotal;
  }

  // Get cart tax
  static double getTax() {
    return _currentCart.tax;
  }

  // Check if cart is empty
  static bool isEmpty() {
    return _currentCart.isEmpty;
  }

  // Find item in cart
  static CartItem? findItem(String cakeId, String size, String flavor) {
    try {
      return _currentCart.items.firstWhere((item) =>
          item.cakeId == cakeId &&
          item.selectedSize == size &&
          item.selectedFlavor == flavor);
    } catch (e) {
      return null;
    }
  }

  // Get item quantity in cart
  static int getItemQuantity(String cakeId, String size, String flavor) {
    final item = findItem(cakeId, size, flavor);
    return item?.quantity ?? 0;
  }

  // Format currency
  static String formatCurrency(double amount, {String currency = 'XAF'}) {
    switch (currency.toUpperCase()) {
      case 'XAF':
        return '${amount.toStringAsFixed(0)} XAF';
      case 'USD':
        return '${amount.toStringAsFixed(0)} XAF';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }

  // Convert currency (placeholder - in real app you'd use actual exchange rates)
  static double convertCurrency(double amount, String from, String to) {
    // Placeholder conversion rates (use real API in production)
    const exchangeRates = {
      'XAF_USD': 0.0016,
      'USD_XAF': 625.0,
      'XAF_EUR': 0.0015,
      'EUR_XAF': 666.67,
      'USD_EUR': 0.92,
      'EUR_USD': 1.09,
    };

    if (from == to) return amount;

    final rateKey = '${from}_$to';
    final rate = exchangeRates[rateKey] ?? 1.0;

    return amount * rate;
  }
}
