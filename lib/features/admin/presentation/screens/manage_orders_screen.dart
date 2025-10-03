import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/services/admin_api_service.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  final Map<String, String> _statusColors = {
    'pending': 'FF9800', // Orange
    'accepted': '4CAF50', // Green
    'in_progress': '2196F3', // Blue
    'ready': '9C27B0', // Purple
    'out_for_delivery': 'FF5722', // Deep Orange
    'delivered': '4CAF50', // Green
    'cancelled': 'F44336', // Red
    'refunded': '607D8B', // Blue Grey
  };

  final Map<String, String> _paymentStatusColors = {
    'pending': 'FF9800', // Orange
    'paid': '4CAF50', // Green
    'failed': 'F44336', // Red
    'refunded': '607D8B', // Blue Grey
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await AdminApiService.getAllOrders();

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredOrders(String filter) {
    switch (filter) {
      case 'all':
        return _orders;
      case 'pending':
        return _orders
            .where((order) => order['fulfillmentStatus'] == 'pending')
            .toList();
      case 'active':
        return _orders
            .where((order) => [
                  'accepted',
                  'in_progress',
                  'ready',
                  'out_for_delivery'
                ].contains(order['fulfillmentStatus']))
            .toList();
      case 'completed':
        return _orders
            .where((order) => order['fulfillmentStatus'] == 'delivered')
            .toList();
      default:
        return _orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.accentColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList('all'),
                _buildOrdersList('pending'),
                _buildOrdersList('active'),
                _buildOrdersList('completed'),
              ],
            ),
    );
  }

  Widget _buildOrdersList(String filter) {
    final filteredOrders = _getFilteredOrders(filter);

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${filter == 'all' ? '' : filter} orders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final fulfillmentStatus = order['fulfillmentStatus'] as String;
    final paymentStatus = order['paymentStatus'] as String;
    final total = order['total'] as int;
    final currency = order['currency'] as String;
    final orderDate = DateTime.parse(order['createdAt'] as String);

    return Card(
      color: AppTheme.surfaceColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['orderNumber'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['guestDetails']['name'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} $currency',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(orderDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Order items
              ...((order['items'] as List).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item['quantity']}x ${item['cakeStyleId']['title']} (${item['size']}, ${item['flavor']})',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()),

              if (order['customerNotes'] != null &&
                  (order['customerNotes'] as String).isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order['customerNotes'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Status badges and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildStatusBadge(
                        fulfillmentStatus,
                        _statusColors[fulfillmentStatus] ?? 'FF9800',
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(
                        paymentStatus,
                        _paymentStatusColors[paymentStatus] ?? 'FF9800',
                        prefix: 'Payment: ',
                      ),
                    ],
                  ),
                  _buildActionButton(order),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String colorHex,
      {String prefix = ''}) {
    final color = Color(int.parse('FF$colorHex', radix: 16));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$prefix${status.replaceAll('_', ' ').toUpperCase()}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> order) {
    final fulfillmentStatus = order['fulfillmentStatus'] as String;

    String buttonText;
    VoidCallback? onPressed;

    switch (fulfillmentStatus) {
      case 'pending':
        buttonText = 'Accept';
        onPressed = () => _updateOrderStatus(order['_id'], 'accepted');
        break;
      case 'accepted':
        buttonText = 'Start';
        onPressed = () => _updateOrderStatus(order['_id'], 'in_progress');
        break;
      case 'in_progress':
        buttonText = 'Ready';
        onPressed = () => _updateOrderStatus(order['_id'], 'ready');
        break;
      case 'ready':
        buttonText = 'Out for Delivery';
        onPressed = () => _updateOrderStatus(order['_id'], 'out_for_delivery');
        break;
      case 'out_for_delivery':
        buttonText = 'Delivered';
        onPressed = () => _updateOrderStatus(order['_id'], 'delivered');
        break;
      default:
        buttonText = 'View';
        onPressed = () => _showOrderDetails(order);
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await AdminApiService.updateOrderStatus(orderId, newStatus);

      setState(() {
        final orderIndex =
            _orders.indexWhere((order) => order['_id'] == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex]['fulfillmentStatus'] = newStatus;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Order status updated to ${newStatus.replaceAll('_', ' ')}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order: $e')),
      );
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailsSheet(order),
    );
  }

  Widget _buildOrderDetailsSheet(Map<String, dynamic> order) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Info
                  _buildDetailSection('Order Information', [
                    _buildDetailRow('Order Number', order['orderNumber']),
                    _buildDetailRow('Date',
                        _formatDate(DateTime.parse(order['createdAt']))),
                    _buildDetailRow('Status', order['fulfillmentStatus']),
                    _buildDetailRow('Payment Status', order['paymentStatus']),
                    _buildDetailRow(
                        'Payment Method', order['paymentMethod'].toUpperCase()),
                  ]),

                  const SizedBox(height: 20),

                  // Customer Info
                  _buildDetailSection('Customer Information', [
                    _buildDetailRow('Name', order['guestDetails']['name']),
                    _buildDetailRow('Email', order['guestDetails']['email']),
                    _buildDetailRow('Phone', order['guestDetails']['phone']),
                  ]),

                  const SizedBox(height: 20),

                  // Order Items
                  _buildDetailSection(
                      'Order Items',
                      (order['items'] as List)
                          .map((item) =>
                              _buildItemDetail(item, order['currency']))
                          .toList()),

                  const SizedBox(height: 20),

                  // Customer Notes
                  if (order['customerNotes'] != null &&
                      (order['customerNotes'] as String).isNotEmpty)
                    _buildDetailSection('Customer Notes', [
                      Text(order['customerNotes'] as String),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(Map<String, dynamic> item, String currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['cakeStyleId']['title'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text('Size: ${item['size']}'),
          Text('Flavor: ${item['flavor']}'),
          Text('Quantity: ${item['quantity']}'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Unit Price: ${item['unitPrice']} $currency'),
              Text(
                'Total: ${item['totalPrice']} $currency',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
