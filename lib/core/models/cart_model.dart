class CartItem {
  final String id;
  final String cakeId;
  final String cakeTitle;
  final String cakeImageUrl;
  final String selectedSize;
  final String selectedFlavor;
  final double unitPrice;
  final int quantity;
  final String currency;
  final Map<String, dynamic>? customizations;

  const CartItem({
    required this.id,
    required this.cakeId,
    required this.cakeTitle,
    required this.cakeImageUrl,
    required this.selectedSize,
    required this.selectedFlavor,
    required this.unitPrice,
    required this.quantity,
    this.currency = 'XAF',
    this.customizations,
  });

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    String? cakeId,
    String? cakeTitle,
    String? cakeImageUrl,
    String? selectedSize,
    String? selectedFlavor,
    double? unitPrice,
    int? quantity,
    String? currency,
    Map<String, dynamic>? customizations,
  }) {
    return CartItem(
      id: id ?? this.id,
      cakeId: cakeId ?? this.cakeId,
      cakeTitle: cakeTitle ?? this.cakeTitle,
      cakeImageUrl: cakeImageUrl ?? this.cakeImageUrl,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedFlavor: selectedFlavor ?? this.selectedFlavor,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      currency: currency ?? this.currency,
      customizations: customizations ?? this.customizations,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      cakeId: json['cakeId']?.toString() ?? '',
      cakeTitle: json['cakeTitle']?.toString() ?? '',
      cakeImageUrl: json['cakeImageUrl']?.toString() ?? '',
      selectedSize: json['selectedSize']?.toString() ?? '',
      selectedFlavor: json['selectedFlavor']?.toString() ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      currency: json['currency']?.toString() ?? 'XAF',
      customizations: json['customizations'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cakeId': cakeId,
        'cakeTitle': cakeTitle,
        'cakeImageUrl': cakeImageUrl,
        'selectedSize': selectedSize,
        'selectedFlavor': selectedFlavor,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'currency': currency,
        'customizations': customizations,
      };
}

class Cart {
  final List<CartItem> items;
  final String currency;

  const Cart({
    this.items = const [],
    this.currency = 'XAF',
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * 0.10; // 10% tax rate for Cameroon

  double get total => subtotal + tax;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  Cart copyWith({
    List<CartItem>? items,
    String? currency,
  }) {
    return Cart(
      items: items ?? this.items,
      currency: currency ?? this.currency,
    );
  }

  Cart addItem(CartItem newItem) {
    final existingIndex = items.indexWhere((item) =>
        item.cakeId == newItem.cakeId &&
        item.selectedSize == newItem.selectedSize &&
        item.selectedFlavor == newItem.selectedFlavor);

    if (existingIndex >= 0) {
      // Update quantity of existing item
      final updatedItems = List<CartItem>.from(items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + newItem.quantity,
      );
      return copyWith(items: updatedItems);
    } else {
      // Add new item
      return copyWith(items: [...items, newItem]);
    }
  }

  Cart removeItem(String itemId) {
    return copyWith(items: items.where((item) => item.id != itemId).toList());
  }

  Cart updateItemQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      return removeItem(itemId);
    }

    final updatedItems = items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    return copyWith(items: updatedItems);
  }

  Cart clear() {
    return copyWith(items: []);
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return Cart(
      items: itemsList.map((item) => CartItem.fromJson(item)).toList(),
      currency: json['currency']?.toString() ?? 'XAF',
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((item) => item.toJson()).toList(),
        'currency': currency,
      };
}
