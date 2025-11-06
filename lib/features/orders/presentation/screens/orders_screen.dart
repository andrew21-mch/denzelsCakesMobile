import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../data/repositories/order_repository.dart';
import '../../../../core/services/order_service.dart';
import 'package:denzels_cakes/l10n/app_localizations.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _activeOrders = [];
  List<Map<String, dynamic>> _completedOrders = [];
  List<Map<String, dynamic>> _cancelledOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
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
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> _loadOrders() async {
    try {
      setState(() => _isLoading = true);

      // Load orders from backend
      final ordersData = await OrderRepository.getUserOrders(limit: 100);
      final ordersList = ordersData['orders'] as List<dynamic>? ?? [];

      // Normalize the order data to match expected format
      final normalizedOrders = ordersList.map((orderData) {
        // Convert to proper map type
        final order = Map<String, dynamic>.from(orderData as Map);

        // Normalize items to flatten the cakeStyleId data
        final itemsList = order['items'] as List<dynamic>? ?? [];
        final normalizedItems = itemsList.map((itemData) {
          final item = Map<String, dynamic>.from(itemData as Map);
          final cakeStyleData = item['cakeStyleId'];

          Map<String, dynamic> cakeStyle = {};
          if (cakeStyleData is Map) {
            cakeStyle = Map<String, dynamic>.from(cakeStyleData);
          }

          return {
            ...item,
            'title': item['title'] ?? cakeStyle['title'] ?? 'Unknown Item',
            'cakeId': cakeStyle['_id'] ?? '',
          };
        }).toList();

        return {
          ...order,
          'items': normalizedItems,
          // Use proper order number instead of MongoDB ID
          'orderNumber': order['orderNumber'] ?? order['_id'] ?? 'Unknown',
          // Keep original amount value
          'total': (order['total'] ?? 0).toDouble(),
        };
      }).toList();

      // Filter orders by status
      final List<Map<String, dynamic>> active = [];
      final List<Map<String, dynamic>> completed = [];
      final List<Map<String, dynamic>> cancelled = [];

      for (final order in normalizedOrders) {
        final status =
            order['fulfillmentStatus']?.toString().toLowerCase() ?? '';
        if (status == 'completed' || status == 'delivered') {
          completed.add(order);
        } else if (status == 'cancelled') {
          cancelled.add(order);
        } else {
          active.add(order);
        }
      }

      setState(() {
        _activeOrders = active;
        _completedOrders = completed;
        _cancelledOrders = cancelled;
        _isLoading = false;
      });
    } catch (e) {
// print('DEBUG: Error loading orders: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToLoadOrders),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Check if order can be cancelled
  bool _canCancelOrder(String status) {
    return ['pending', 'confirmed', 'accepted'].contains(status.toLowerCase());
  }

  /// Show cancel order confirmation dialog
  void _showCancelDialog(Map<String, dynamic> order) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelOrder),
        content: Text(
          l10n.cancelOrderConfirmation(order['orderNumber']?.toString() ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.keepOrder),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelOrder(order);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              l10n.cancelOrder,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Cancel the order
  Future<void> _cancelOrder(Map<String, dynamic> order) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Call cancel order API
      await OrderService.cancelOrder(order['_id'] ?? order['id'] ?? '');

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.orderHasBeenCancelled(order['orderNumber']?.toString() ?? '')),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reload orders to reflect the change
      _loadOrders();
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToCancelOrder}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(l10n.myOrders),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.textTertiary,
          indicatorColor: AppTheme.accentColor,
          tabs: [
            Tab(text: l10n.activeOrders),
            Tab(text: l10n.completedOrders),
            Tab(text: l10n.cancelledOrders),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: l10n.loadingOrders,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOrdersList(_activeOrders),
            _buildOrdersList(_completedOrders),
            _buildOrdersList(_cancelledOrders),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noOrdersYet,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your orders will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['orderNumber'] ?? 'N/A'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                _buildStatusChip(order['fulfillmentStatus'] ?? 'pending'),
              ],
            ),

            const SizedBox(height: 12),

            // Order Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(order['createdAt']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Order Items
            ...(order['items'] as List<dynamic>? ?? [])
                .map<Widget>((item) => _buildOrderItem(item)),

            const SizedBox(height: 16),

            // Order Total and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    Text(
                      '${(order['total'] ?? 0).toStringAsFixed(0)} ${order['currency'] ?? 'XAF'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show cancel button only for orders that can be cancelled
                    if (_canCancelOrder(order['fulfillmentStatus'] ?? '')) ...[
                      OutlinedButton(
                        onPressed: () => _showCancelDialog(order),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(60, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        _showOrderDetails(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(60, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Details',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        displayText = 'Pending';
        break;
      case 'accepted':
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        displayText = 'Accepted';
        break;
      case 'in_progress':
        backgroundColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple;
        displayText = 'In Progress';
        break;
      case 'ready':
        backgroundColor = Colors.indigo.withValues(alpha: 0.1);
        textColor = Colors.indigo;
        displayText = 'Ready';
        break;
      case 'out_for_delivery':
        backgroundColor = Colors.teal.withValues(alpha: 0.1);
        textColor = Colors.teal;
        displayText = 'Out for Delivery';
        break;
      case 'delivered':
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        displayText = 'Delivered';
        break;
      case 'cancelled':
        backgroundColor = AppTheme.errorColor.withValues(alpha: 0.1);
        textColor = AppTheme.errorColor;
        displayText = 'Cancelled';
        break;
      case 'refunded':
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        displayText = 'Refunded';
        break;
      default:
        backgroundColor = AppTheme.textTertiary.withValues(alpha: 0.1);
        textColor = AppTheme.textTertiary;
        displayText = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final customizations = item['customizations'] as Map<String, dynamic>? ?? {};
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cake,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Unknown Item',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      Text(
                        '${item['size'] ?? 'N/A'} • ${item['flavor'] ?? 'N/A'} • Qty: ${item['quantity'] ?? 0}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(item['totalPrice'] ?? 0).toStringAsFixed(0)} XAF',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ],
            ),
            
            // Show customizations if they exist
            if (customizations.isNotEmpty) ...[
              const SizedBox(height: 12),
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
                    const SizedBox(height: 8),
                    
                    // Show delivery date and time
                    if (customizations['deliveryDate'] != null) ...[
                      _buildCustomizationRow(
                        Icons.calendar_today,
                        'Delivery Date',
                        _formatCustomizationDate(customizations['deliveryDate']),
                      ),
                      const SizedBox(height: 4),
                    ],
                    
                    if (customizations['deliveryTime'] != null) ...[
                      _buildCustomizationRow(
                        Icons.access_time,
                        'Delivery Time',
                        customizations['deliveryTime'],
                      ),
                      const SizedBox(height: 4),
                    ],
                    
                    // Show selected color
                    if (customizations['selectedColor'] != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.color_lens, size: 16, color: AppTheme.accentColor),
                          const SizedBox(width: 8),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _parseColor(customizations['selectedColor']),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Custom Color',
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
                      _buildCustomizationRow(
                        Icons.note_outlined,
                        'Special Instructions',
                        customizations['specialInstructions'],
                      ),
                      const SizedBox(height: 4),
                    ],
                    
                    // Show image count
                    if (customizations['images'] != null && 
                        (customizations['images'] as List).isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.image, size: 16, color: AppTheme.accentColor),
                          const SizedBox(width: 8),
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
      ),
    );
  }

  Widget _buildCustomizationRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accentColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      ],
    );
  }

  String _formatCustomizationDate(dynamic dateValue) {
    if (dateValue is String) {
      try {
        final date = DateTime.parse(dateValue);
        return '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        return dateValue.toString();
      }
    }
    return dateValue.toString();
  }

  Color _parseColor(dynamic colorValue) {
    if (colorValue is String) {
      // Handle hex color strings like "#ffffeb3b"
      if (colorValue.startsWith('#')) {
        try {
          return Color(int.parse(colorValue.substring(1), radix: 16));
        } catch (e) {
          return Colors.grey;
        }
      }
    }
    return Colors.grey;
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Order Details Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order['orderNumber'] ?? 'N/A'}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Placed on ${_formatDate(order['createdAt'])}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Status
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                        ),
                        _buildStatusChip(
                            order['fulfillmentStatus'] ?? 'pending'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Items
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...(order['items'] as List<dynamic>? ?? [])
                        .map<Widget>((item) => _buildOrderItem(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
