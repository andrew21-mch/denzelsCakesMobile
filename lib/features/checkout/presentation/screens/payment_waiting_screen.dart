import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/services/payment_service.dart';

class PaymentWaitingScreen extends StatefulWidget {
  final String orderId;
  final PaymentMethod paymentMethod;
  final double amount;
  final Map<String, dynamic>? paymentDetails;

  const PaymentWaitingScreen({
    super.key,
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    this.paymentDetails,
  });

  @override
  State<PaymentWaitingScreen> createState() => _PaymentWaitingScreenState();
}

class _PaymentWaitingScreenState extends State<PaymentWaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  PaymentStatus _paymentStatus = PaymentStatus.processing;
  bool _isChecking = true;
  String _statusMessage = 'Processing your payment...';

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);

    _startPaymentProcessing();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startPaymentProcessing() async {
    try {
      setState(() {
        _statusMessage = _getProcessingMessage();
      });

      // Simulate payment processing with backend calls
      if (widget.paymentMethod == PaymentMethod.momo) {
        await _processMomoPayment();
      } else if (widget.paymentMethod == PaymentMethod.card) {
        await _processCardPayment();
      } else {
        // Cash payment - instant success
        setState(() {
          _paymentStatus = PaymentStatus.completed;
          _statusMessage = 'Order placed successfully!';
          _isChecking = false;
        });
        _navigateToSuccess();
      }
    } catch (e) {
      setState(() {
        _paymentStatus = PaymentStatus.failed;
        _statusMessage = 'Payment failed. Please try again.';
        _isChecking = false;
      });
    }
  }

  Future<void> _processMomoPayment() async {
    try {
      final phoneNumber = widget.paymentDetails?['phoneNumber'] ?? '';

      setState(() {
        _statusMessage = 'Sending MOMO payment request...';
      });

      // Send MOMO payment request
      final result = await PaymentService.processMomoPayment(
        orderId: widget.orderId,
        phoneNumber: phoneNumber,
        amount: widget.amount,
      );

      if (result.status == PaymentStatus.processing) {
        setState(() {
          _statusMessage = 'Please complete the payment on your phone...';
        });

        // Poll for payment status
        await _pollPaymentStatus();
      } else if (result.status == PaymentStatus.completed ||
          result.status == PaymentStatus.paid) {
        _handlePaymentSuccess();
      } else {
        _handlePaymentFailure(result.message ?? 'Payment failed');
      }
    } catch (e) {
      _handlePaymentFailure(e.toString());
    }
  }

  Future<void> _processCardPayment() async {
    try {
      setState(() {
        _statusMessage = 'Initializing secure card payment...';
      });

      // SECURITY: No card details are sent from the mobile app
      // The backend creates a secure payment intent and handles all card processing
      final result = await PaymentService.processCardPayment(
        orderId: widget.orderId,
        cardNumber: '', // Not used - security placeholder
        expiryDate: '', // Not used - security placeholder
        cvv: '', // Not used - security placeholder
        cardHolderName: '', // Not used - security placeholder
        amount: widget.amount,
      );

      setState(() {
        _statusMessage = 'Processing payment securely...';
      });

      if (result.status == PaymentStatus.processing) {
        // In a real app, this would:
        // 1. Open Stripe's secure card collection UI
        // 2. Handle the secure payment flow
        // 3. Return success/failure

        // For demo, we'll simulate the secure process
        await Future.delayed(const Duration(seconds: 3));
        _handlePaymentSuccess();
      } else if (result.status == PaymentStatus.completed ||
          result.status == PaymentStatus.paid) {
        _handlePaymentSuccess();
      } else {
        _handlePaymentFailure(result.message ?? 'Card payment failed');
      }
    } catch (e) {
      _handlePaymentFailure(e.toString());
    }
  }

  Future<void> _pollPaymentStatus() async {
    const maxAttempts = 30; // 5 minutes with 10-second intervals
    int attempts = 0;
    int consecutiveErrors = 0;

    while (attempts < maxAttempts && _isChecking) {
      await Future.delayed(const Duration(seconds: 10));

      if (!_isChecking || !mounted) break;

      try {
// print('DEBUG: Polling payment status for order: ${widget.orderId}, attempt: ${attempts + 1}');
        final status = await PaymentService.checkPaymentStatus(widget.orderId);
// print('DEBUG: Payment status response: $status');

        // Reset error counter on successful check
        consecutiveErrors = 0;

        if (status == PaymentStatus.completed || status == PaymentStatus.paid) {
// print('DEBUG: Payment completed successfully');
          _handlePaymentSuccess();
          break;
        } else if (status == PaymentStatus.failed ||
            status == PaymentStatus.cancelled) {
// print('DEBUG: Payment failed or cancelled');
          _handlePaymentFailure('Payment was cancelled or failed');
          break;
        }

        attempts++;

        // Update message based on attempts
        if (attempts > 10 && mounted) {
          setState(() {
            _statusMessage = 'Still waiting for payment confirmation...';
          });
        }
      } catch (e) {
        consecutiveErrors++;
// print('DEBUG: Error polling payment status (attempt $consecutiveErrors): $e');

        // If too many consecutive errors, show error
        if (consecutiveErrors >= 3) {
// print('DEBUG: Too many consecutive polling errors, stopping');
          _handlePaymentFailure('Unable to check payment status. Error: $e');
          break;
        }

        attempts++;

        // Update UI to show we're retrying
        if (mounted) {
          setState(() {
            _statusMessage =
                'Checking payment status... (retry $consecutiveErrors/3)';
          });
        }
      }
    }

    // Timeout
    if (attempts >= maxAttempts && _isChecking) {
// print('DEBUG: Payment status polling timed out');
      _handlePaymentFailure('Payment timeout. Please check your order status.');
    }
  }

  void _handlePaymentSuccess() {
    if (!mounted) return;

    setState(() {
      _paymentStatus = PaymentStatus.completed;
      _statusMessage = 'Payment successful!';
      _isChecking = false;
    });

    _pulseController.stop();
    _navigateToSuccess();
  }

  void _handlePaymentFailure(String message) {
    if (!mounted) return;

    setState(() {
      _paymentStatus = PaymentStatus.failed;
      _statusMessage = message;
      _isChecking = false;
    });

    _pulseController.stop();
  }

  void _navigateToSuccess() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/payment-success',
          arguments: {
            'orderId': widget.orderId,
            'amount': widget.amount,
            'paymentMethod': widget.paymentMethod.name,
          },
        );
      }
    });
  }

  String _getProcessingMessage() {
    switch (widget.paymentMethod) {
      case PaymentMethod.momo:
        return 'Processing MOMO payment...';
      case PaymentMethod.card:
        return 'Processing card payment...';
      case PaymentMethod.cash:
        return 'Confirming cash payment...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isChecking,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Payment'),
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          automaticallyImplyLeading: !_isChecking,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        // Payment icon with animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isChecking ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: _getStatusGradient(),
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor().withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getStatusIcon(),
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Status message
                Flexible(
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 16),

                // Additional info
                Flexible(
                  child: Text(
                    _getAdditionalInfo(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 32),

                // Action buttons
                if (!_isChecking) ...[
                  if (_paymentStatus == PaymentStatus.failed) ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ] else ...[
                  // Progress indicator
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  ),
                ],
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Gradient _getStatusGradient() {
    switch (_paymentStatus) {
      case PaymentStatus.completed:
      case PaymentStatus.paid:
        return LinearGradient(
          colors: [
            AppTheme.successColor,
            AppTheme.successColor.withValues(alpha: 0.8)
          ],
        );
      case PaymentStatus.failed:
        return LinearGradient(
          colors: [
            AppTheme.errorColor,
            AppTheme.errorColor.withValues(alpha: 0.8)
          ],
        );
      default:
        return AppTheme.accentGradient;
    }
  }

  Color _getStatusColor() {
    switch (_paymentStatus) {
      case PaymentStatus.completed:
      case PaymentStatus.paid:
        return AppTheme.successColor;
      case PaymentStatus.failed:
        return AppTheme.errorColor;
      default:
        return AppTheme.accentColor;
    }
  }

  IconData _getStatusIcon() {
    switch (_paymentStatus) {
      case PaymentStatus.completed:
      case PaymentStatus.paid:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      default:
        return widget.paymentMethod == PaymentMethod.momo
            ? Icons.phone_android
            : Icons.credit_card;
    }
  }

  String _getAdditionalInfo() {
    if (_isChecking) {
      switch (widget.paymentMethod) {
        case PaymentMethod.momo:
          return 'Check your phone for the payment prompt and confirm the transaction.';
        case PaymentMethod.card:
          return 'Please wait while we process your card payment.';
        case PaymentMethod.cash:
          return 'Confirming your order details.';
      }
    } else if (_paymentStatus == PaymentStatus.completed ||
        _paymentStatus == PaymentStatus.paid) {
      return 'Your order has been placed successfully!';
    } else {
      return 'Something went wrong with your payment.';
    }
  }
}
