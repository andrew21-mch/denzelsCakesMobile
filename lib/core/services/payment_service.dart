import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/cart_model.dart';
import '../models/user_model.dart';

enum PaymentMethod {
  card,
  momo,
  cash,
}

enum PaymentStatus {
  pending,
  processing,
  paid,
  completed,
  failed,
  cancelled,
}

class PaymentRequest {
  final List<CartItem> items;
  final Address deliveryAddress;
  final PaymentMethod paymentMethod;
  final String? customerNotes;
  final String? deliveryInstructions;
  final DateTime? expectedDeliveryDate;
  final Map<String, dynamic>? paymentDetails;

  const PaymentRequest({
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.customerNotes,
    this.deliveryInstructions,
    this.expectedDeliveryDate,
    this.paymentDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items
          .map((item) => {
                'cakeStyleId': item.cakeId,
                'size': item.selectedSize,
                'flavor': item.selectedFlavor,
                'quantity': item.quantity,
                'customMessage': '', // TODO: Add if needed
                'images': [], // TODO: Add if needed
              })
          .toList(),
      'paymentMethod': paymentMethod.name,
      'deliveryDetails': {
        'type': 'delivery',
        'address': deliveryAddress.toJson(),
        'instructions': deliveryInstructions,
        if (expectedDeliveryDate != null) 
          'scheduledDate': expectedDeliveryDate!.toIso8601String(),
      },
      'customerNotes': customerNotes,
      if (paymentDetails != null) 'paymentDetails': paymentDetails,
    };
  }
}

class PaymentResponse {
  final String orderId;
  final PaymentStatus status;
  final String? paymentId;
  final String? paymentUrl;
  final String? message;
  final Map<String, dynamic>? metadata;

  const PaymentResponse({
    required this.orderId,
    required this.status,
    this.paymentId,
    this.paymentUrl,
    this.message,
    this.metadata,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      orderId: json['orderId']?.toString() ?? '',
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == json['status']?.toString(),
        orElse: () => PaymentStatus.pending,
      ),
      paymentId: json['paymentId']?.toString(),
      paymentUrl: json['paymentUrl']?.toString(),
      message: json['message']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

class PaymentService {
  /// Initiate payment for an order
  static Future<PaymentResponse> initiatePayment(PaymentRequest request) async {
    try {
// print('DEBUG: Initiating payment with method: ${request.paymentMethod}');

      final response = await ApiService.post(
        '/orders',
        data: request.toJson(),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final orderData = response.data['data'];

        return PaymentResponse(
          orderId: orderData['_id']?.toString() ?? '',
          status: PaymentStatus.pending,
          message: 'Order created successfully',
          metadata: orderData,
        );
      }

      throw Exception('Failed to create order');
    } on DioException catch (e) {
// print('DEBUG: Error initiating payment: $e');
      throw Exception(
          e.response?.data['message'] ?? 'Payment initiation failed');
    } catch (e) {
// print('DEBUG: Error initiating payment: $e');
      throw Exception('Payment initiation failed');
    }
  }

  /// Process MOMO payment
  static Future<PaymentResponse> processMomoPayment({
    required String orderId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
// print('DEBUG: Processing MOMO payment for order: $orderId');

      // Create payment intent for MOMO - backend handles all sensitive operations
      final response = await ApiService.post(
        '/payments/create-intent',
        data: {
          'orderId': orderId,
          'paymentMethod': 'momo',
          'provider': 'transzak', // Use Tranzak for Cameroon mobile money
          // Send phone number for mobile wallet charge
          'phoneNumber': phoneNumber,
          'customerPhone': phoneNumber,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final paymentData = response.data['data'];

        return PaymentResponse(
          orderId: orderId,
          status: PaymentStatus.processing,
          message: 'MOMO payment initiated',
          metadata: paymentData,
        );
      }

      throw Exception(
          response.data['message'] ?? 'Failed to process MOMO payment');
    } on DioException catch (e) {
// print('DEBUG: Error processing MOMO payment: $e');
      throw Exception(e.response?.data['message'] ?? 'MOMO payment failed');
    } catch (e) {
// print('DEBUG: Error processing MOMO payment: $e');
      throw Exception('MOMO payment failed');
    }
  }

  /// Process card payment - SECURE VERSION
  /// NOTE: This creates a payment intent on the backend, which then handles
  /// all sensitive card processing through Stripe/payment provider APIs
  static Future<PaymentResponse> processCardPayment({
    required String orderId,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardHolderName,
    required double amount,
  }) async {
    try {
// print('DEBUG: Processing card payment for order: $orderId');

      // SECURITY: We do NOT send card details to our backend
      // Instead, we create a payment intent and let Stripe handle card processing
      final response = await ApiService.post(
        '/payments/create-intent',
        data: {
          'orderId': orderId,
          'paymentMethod': 'card',
          'provider': 'stripe', // Backend will handle Stripe integration
          // NO CARD DETAILS SENT - Stripe will handle this securely
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final paymentData = response.data['data'];

        // In a real app, you would:
        // 1. Get the payment intent client secret from the response
        // 2. Use Stripe's mobile SDK to securely collect and process card details
        // 3. Stripe handles all sensitive card data
        // 4. Return success/failure status

        // For demo purposes, we'll simulate this process
        return PaymentResponse(
          orderId: orderId,
          status: PaymentStatus.processing,
          message: 'Card payment initiated securely',
          metadata: paymentData,
        );
      }

      throw Exception(
          response.data['message'] ?? 'Failed to process card payment');
    } on DioException catch (e) {
// print('DEBUG: Error processing card payment: $e');
      throw Exception(e.response?.data['message'] ?? 'Card payment failed');
    } catch (e) {
// print('DEBUG: Error processing card payment: $e');
      throw Exception('Card payment failed');
    }
  }

  /// Check payment status
  static Future<PaymentStatus> checkPaymentStatus(String orderId) async {
    try {
// print('DEBUG: Checking payment status for order: $orderId');
      final response = await ApiService.get('/orders/$orderId');
// print('DEBUG: Payment status check response: ${response.statusCode}, ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final orderData = response.data['data'];
        final paymentStatus =
            orderData['paymentStatus']?.toString() ?? 'pending';
// print('DEBUG: Order payment status: $paymentStatus');

        return PaymentStatus.values.firstWhere(
          (s) => s.name == paymentStatus,
          orElse: () => PaymentStatus.pending,
        );
      } else {
// print('DEBUG: Invalid response for payment status check: ${response.data}');
        throw Exception(
            'Invalid response: ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
// print('DEBUG: DioException checking payment status: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(
          'Network error: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
// print('DEBUG: Error checking payment status: $e');
      throw Exception('Failed to check payment status: $e');
    }
  }

  /// Simulate payment processing (for demo purposes)
  static Future<PaymentResponse> simulatePaymentProcessing({
    required String orderId,
    required PaymentMethod method,
    required double amount,
  }) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random success/failure (90% success rate)
    final success = DateTime.now().millisecond % 10 != 0;

    if (success) {
      return PaymentResponse(
        orderId: orderId,
        status: PaymentStatus.completed,
        paymentId: 'PAY_${DateTime.now().millisecondsSinceEpoch}',
        message: 'Payment completed successfully',
      );
    } else {
      return PaymentResponse(
        orderId: orderId,
        status: PaymentStatus.failed,
        message: 'Payment failed. Please try again.',
      );
    }
  }
}
