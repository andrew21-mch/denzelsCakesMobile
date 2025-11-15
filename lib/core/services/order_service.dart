import '../models/cart_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class OrderService {
  static const String _baseUrl = '/orders';

  /// Create a new order
  static Future<Map<String, dynamic>> createOrder({
    required Cart cart,
    required Address deliveryAddress,
    required String paymentMethod,
    String? deliveryInstructions,
    DateTime? scheduledDate,
    String? scheduledTime,
  }) async {
    // Convert cart items to order format
    final orderItems = cart.items
        .map((item) => {
              'cakeStyleId': item.cakeId,
              'size': item.selectedSize,
              'flavor': item.selectedFlavor,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
              'totalPrice': item.totalPrice,
              'customizations': item.customizations,
            })
        .toList();

    final orderData = {
      'items': orderItems,
      'deliveryDetails': {
        'type': 'delivery',
        'address': {
          'type': deliveryAddress.type,
          'street': deliveryAddress.street,
          'city': deliveryAddress.city,
          'state': deliveryAddress.state,
          'zipCode': deliveryAddress.zipCode,
          'country': deliveryAddress.country,
        },
        'scheduledDate':
            (scheduledDate ?? DateTime.now().add(const Duration(hours: 2)))
                .toIso8601String(),
        'scheduledTime': scheduledTime,
        'instructions': deliveryInstructions,
      },
      'paymentMethod': paymentMethod,
      'subtotal': cart.subtotal,
      'shippingFee': 0.0, // No shipping fee in current cart model
      'tax': cart.tax,
      'total': cart.total,
    };

    final response = await ApiService.post(_baseUrl, data: orderData);
    return response.data['data'];
  }

  /// Create a custom order (without cakeStyleId)
  static Future<Map<String, dynamic>> createCustomOrder({
    required String cakeType,
    required String size,
    required String flavor,
    required String title,
    required double unitPrice,
    required String paymentMethod,
    required Map<String, dynamic> guestDetails,
    required Map<String, dynamic> deliveryDetails,
    String? customerNotes,
    List<String>? imageUrls,
    String? targetAgeGroup,
    String? targetGender,
  }) async {
    final orderData = {
      'items': [
        {
          // No cakeStyleId for custom cakes
          'title': title,
          'size': size,
          'flavor': flavor,
          'quantity': 1,
          'unitPrice': unitPrice,
          'customMessage': customerNotes ?? '',
          'customizations': {
            'cakeType': cakeType,
            'specialInstructions': customerNotes ?? '',
          },
          'images': imageUrls ?? [],
        }
      ],
      'paymentMethod': paymentMethod,
      'guestDetails': guestDetails,
      'deliveryDetails': deliveryDetails,
      'customerNotes': customerNotes ?? '',
      if (targetAgeGroup != null) 'targetAgeGroup': targetAgeGroup,
      if (targetGender != null) 'targetGender': targetGender,
    };

    final response = await ApiService.post(_baseUrl, data: orderData);
    return response.data['data'];
  }

  /// Get user's orders
  static Future<List<Map<String, dynamic>>> getUserOrders({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await ApiService.get(
      '$_baseUrl/user/me',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List<dynamic> ordersJson = response.data['data'];
    return ordersJson.cast<Map<String, dynamic>>();
  }

  /// Get order by ID
  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await ApiService.get('$_baseUrl/$orderId');
    return response.data['data'];
  }  /// Cancel an order
  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final response = await ApiService.post('$_baseUrl/$orderId/cancel');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  /// Track order by order number
  static Future<Map<String, dynamic>?> trackOrder(String orderNumber) async {
    try {
      final response = await ApiService.get('$_baseUrl/track/$orderNumber');
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }

  /// Helper method to format order status
  static String formatOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Order Placed';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready for Pickup/Delivery';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  /// Helper method to get status color
  static String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FF9800'; // Orange
      case 'confirmed':
        return '#2196F3'; // Blue
      case 'preparing':
        return '#9C27B0'; // Purple
      case 'ready':
        return '#FF5722'; // Deep Orange
      case 'out_for_delivery':
        return '#3F51B5'; // Indigo
      case 'completed':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#757575'; // Grey
    }
  }

  /// Helper method to format currency
  static String formatCurrency(double amount) {
    return '${amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} FCFA';
  }

  /// Helper method to format date
  static String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Helper method to format time
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Helper method to get estimated delivery time
  static String getEstimatedDelivery(DateTime orderDate, int prepTimeMinutes) {
    final estimatedTime = orderDate.add(
        Duration(minutes: prepTimeMinutes + 30)); // Add 30 min for delivery
    return '${formatDate(estimatedTime)} at ${formatTime(estimatedTime)}';
  }

  /// Helper method to check if order can be cancelled
  static bool canCancelOrder(String status) {
    return ['pending', 'confirmed'].contains(status.toLowerCase());
  }

  /// Helper method to check if order can be reviewed
  static bool canReviewOrder(String status) {
    return status.toLowerCase() == 'completed';
  }

  /// Helper method to get order progress percentage
  static double getOrderProgress(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0.1;
      case 'confirmed':
        return 0.3;
      case 'preparing':
        return 0.5;
      case 'ready':
        return 0.7;
      case 'out_for_delivery':
        return 0.9;
      case 'completed':
        return 1.0;
      case 'cancelled':
        return 0.0;
      default:
        return 0.0;
    }
  }
}
