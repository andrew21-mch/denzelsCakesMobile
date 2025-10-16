import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/services/admin_api_service.dart';

class OrdersManagementScreen extends StatefulWidget {
  final bool embedded;

  const OrdersManagementScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  List<Map<String, dynamic>> _orders = [];

  final List<String> _statusFilters = [
    'all',
    'pending',
    'accepted',
    'in_progress',
    'ready',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];

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
    setState(() => _isLoading = true);

    try {
      // Load orders from API
      final orders = await AdminApiService.getAllOrders();

      setState(() {
        _orders = orders
            .map((order) => {
                  'id': order['orderNumber'] ?? order['_id'] ?? '',
                  'actualId': order['_id'] ??
                      order['id'] ??
                      '', // Keep the actual MongoDB ID for API calls
                  'customer': order['userId']?['name'] ??
                      order['guestDetails']?['name'] ??
                      'Unknown Customer',
                  'customerPhone': order['userId']?['phone'] ??
                      order['guestDetails']?['phone'] ??
                      'No phone',
                  'customerEmail': order['userId']?['email'] ??
                      order['guestDetails']?['email'] ??
                      'No email',
                  'total': (order['total'] ?? 0)
                      .toDouble(), // Convert from cents if needed
                  'currency': order['currency'] ?? 'XAF',
                  'status': order['fulfillmentStatus'] ?? 'pending',
                  'paymentStatus': order['paymentStatus'] ?? 'pending',
                  'paymentMethod': order['paymentMethod'] ?? '',
                  'date':
                      order['createdAt'] ?? DateTime.now().toIso8601String(),
                  'items': (order['items'] as List?)
                          ?.map((item) => {
                                'name': item['cakeStyleId']?['title'] ??
                                    'Unknown Item',
                                'quantity': item['quantity'] ?? 1,
                                'price': (item['unitPrice'] ?? 0)
                                    .toDouble(), // Keep original value
                                'size': item['size'] ?? '',
                                'flavor': item['flavor'] ?? '',
                              })
                          .toList() ??
                      [],
                  'deliveryAddress': _formatAddress(order),
                  'notes': order['customerNotes'] ?? '',
                  'merchantNotes': order['merchantNotes'] ?? '',
                })
            .toList();
      });
    } catch (e) {
      // Handle error
// print('Error loading orders: $e');

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load orders: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredOrders {
    return _orders.where((order) {
      final matchesSearch = _searchQuery.isEmpty ||
          order['customer']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          order['id']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _selectedStatus == 'all' || order['status'] == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildOrdersList();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Orders Management'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(),
          _buildOrdersList(statusFilter: 'pending'),
          _buildOrdersList(statusFilter: 'in_progress'),
          _buildOrdersList(statusFilter: 'delivered'),
        ],
      ),
    );
  }

  Widget _buildOrdersList({String? statusFilter}) {
    final ordersToShow = statusFilter != null
        ? _orders.where((order) => order['status'] == statusFilter).toList()
        : _filteredOrders;

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.surfaceColor,
          child: Column(
            children: [
              // Search Field
              TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search orders...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppTheme.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                ),
              ),

              const SizedBox(height: 12),

              // Status Filter
              if (statusFilter == null)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _statusFilters.length,
                    itemBuilder: (context, index) {
                      final status = _statusFilters[index];
                      final isSelected = _selectedStatus == status;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            status == 'all' ? 'All' : _getStatusText(status),
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.onPrimaryColor
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedStatus = status);
                          },
                          backgroundColor: AppTheme.backgroundColor,
                          selectedColor: AppTheme.primaryColor,
                          checkmarkColor: AppTheme.onPrimaryColor,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),

        // Orders List
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                )
              : ordersToShow.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      color: AppTheme.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: ordersToShow.length,
                        itemBuilder: (context, index) {
                          final order = ordersToShow[index];
                          return _buildOrderCard(order);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders will appear here when customers place them',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String status = order['status'] ?? 'unknown';
    final Color statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: AppTheme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['orderNumber'] ?? order['id'] ?? 'Unknown',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Customer Info
              Row(
                children: [
                  const Icon(Icons.person,
                      size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    order['customer'] ?? 'Unknown',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _callCustomer(order['customerPhone']),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone,
                            size: 16, color: AppTheme.successColor),
                        const SizedBox(width: 8),
                        Text(
                          order['customerPhone'] ?? 'No phone',
                          style: TextStyle(
                            color: order['customerPhone'] != 'No phone'
                                ? AppTheme.successColor
                                : AppTheme.textSecondary,
                            fontSize: 14,
                            decoration: order['customerPhone'] != 'No phone'
                                ? TextDecoration.underline
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Order Total and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(order['total'] ?? 0).toStringAsFixed(0)} XAF',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    _formatDate(order['date']),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showOrderDetails(order),
                      icon: const Icon(Icons.visibility, size: 14),
                      label: const Text('View Details',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentColor,
                        side: const BorderSide(color: AppTheme.accentColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdateStatusDialog(order),
                      icon: const Icon(Icons.edit, size: 14),
                      label:
                          const Text('Update', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        minimumSize: const Size(0, 32),
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

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Details',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order['id'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status'])
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(order['status']),
                              style: TextStyle(
                                color: _getStatusColor(order['status']),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Customer Information
                      _buildDetailSection(
                        'Customer Information',
                        [
                          _buildDetailRow('Name', order['customer']),
                          _buildDetailRow('Phone', order['customerPhone']),
                          _buildDetailRow('Address', order['deliveryAddress'], 
                              hasCoordinates: _hasCoordinates(order)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Order Items
                      _buildDetailSection(
                        'Order Items',
                        (order['items'] as List).map<Widget>((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Qty: ${item['quantity']}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${item['price'].toStringAsFixed(0)} XAF',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Order Summary
                      _buildDetailSection(
                        'Order Summary',
                        [
                          _buildDetailRow('Total',
                              '${order['total'].toStringAsFixed(0)} XAF'),
                          _buildDetailRow(
                              'Payment Status', order['paymentStatus']),
                          _buildDetailRow(
                              'Order Date', _formatDate(order['date'])),
                        ],
                      ),

                      if (order['notes'] != null &&
                          order['notes'].isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildDetailSection(
                          'Special Notes',
                          [
                            Text(
                              order['notes'],
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool hasCoordinates = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: hasCoordinates
                ? GestureDetector(
                    onTap: () => _openInGoogleMaps(value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.accentColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'View on Maps',
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Update Order Status',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusFilters
              .where((status) => status != 'all')
              .map((status) => ListTile(
                    title: Text(
                      _getStatusText(status),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                    leading: Radio<String>(
                      value: status,
                      groupValue: order['status'],
                      onChanged: (value) {
                        Navigator.pop(context);
                        _updateOrderStatus(order, value!);
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(
      Map<String, dynamic> order, String newStatus) async {
    try {
// print('Updating order status: ${order['actualId']} (${order['id']}) to $newStatus');

      // Update status via API using the actual MongoDB _id
      await AdminApiService.updateOrderStatus(
        order['actualId'] as String,
        newStatus,
      );

      setState(() {
        order['status'] = newStatus;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Order ${order['id']} status updated to ${_getStatusText(newStatus)}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _callCustomer(String? phone) {
    if (phone != null && phone.isNotEmpty && phone != 'No phone') {
      // Clean phone number (remove any formatting)
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
      _makePhoneCall(cleanPhone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No phone number available for this customer'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  // Phone call functionality
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Clean the phone number (remove spaces, dashes, parentheses, but keep +)
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

// print('Original phone: $phoneNumber');
// print('Clean phone: $cleanNumber');

      // Skip canLaunchUrl check and try to launch directly
      // This often works better on real devices
      try {
        final Uri phoneUri = Uri.parse('tel:$cleanNumber');
// print('Attempting direct launch with URI: $phoneUri');

        await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
// print('Phone call launched successfully');
        return; // Exit if successful
      } catch (directError) {
// print('Direct launch failed: $directError');
      }

      // If direct launch failed, try with canLaunchUrl check
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
// print('Trying with canLaunchUrl check: $phoneUri');

      if (await canLaunchUrl(phoneUri)) {
// print('canLaunchUrl returned true, attempting to launch...');
        await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
// print('Phone call launched successfully via canLaunchUrl');
      } else {
        // Show user-friendly error with copy option
// print('canLaunchUrl returned false');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cannot open phone app'),
                  Text('Number: $cleanNumber'),
                  const Text('Tap "Copy" to copy the number'),
                ],
              ),
              backgroundColor: AppTheme.warningColor,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Copy',
                textColor: Colors.white,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: cleanNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number copied to clipboard'),
                      backgroundColor: AppTheme.successColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
// print('Phone call error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warningColor;
      case 'accepted':
      case 'in_progress':
        return AppTheme.accentColor;
      case 'ready':
        return AppTheme.primaryColor;
      case 'out_for_delivery':
        return AppTheme.secondaryColor;
      case 'delivered':
        return AppTheme.successColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'ready':
        return 'Ready';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String _formatAddress(Map<String, dynamic> order) {
    try {
      // Try to get address from deliveryDetails.address (new structure)
      final deliveryDetails = order['deliveryDetails'];
      if (deliveryDetails != null && deliveryDetails is Map<String, dynamic>) {
        final address = deliveryDetails['address'];
        if (address != null && address is Map<String, dynamic>) {
          final street = address['street'] ?? '';
          final city = address['city'] ?? '';
          final state = address['state'] ?? '';
          final country = address['country'] ?? '';
          
          // Build formatted address
          final parts = <String>[];
          if (street.isNotEmpty) parts.add(street);
          if (city.isNotEmpty) parts.add(city);
          if (state.isNotEmpty) parts.add(state);
          if (country.isNotEmpty) parts.add(country);
          
          return parts.join(', ');
        }
      }
      
      // Fallback: try direct deliveryAddress field (old structure)
      final directAddress = order['deliveryAddress'];
      if (directAddress != null && directAddress.toString().isNotEmpty) {
        return directAddress.toString();
      }
      
      // Final fallback: try guestDetails address
      final guestDetails = order['guestDetails'];
      if (guestDetails != null && guestDetails is Map<String, dynamic>) {
        final address = guestDetails['address'];
        if (address != null && address is Map<String, dynamic>) {
          final street = address['street'] ?? '';
          final city = address['city'] ?? '';
          return '$street, $city'.trim().replaceAll(RegExp(r'^,|,$'), '');
        }
      }
      
      return 'Address not available';
    } catch (e) {
      return 'Address error';
    }
  }

  bool _hasCoordinates(Map<String, dynamic> order) {
    try {
      // Check if deliveryDetails.address has coordinates
      final deliveryDetails = order['deliveryDetails'];
      if (deliveryDetails != null && deliveryDetails is Map<String, dynamic>) {
        final address = deliveryDetails['address'];
        if (address != null && address is Map<String, dynamic>) {
          final lat = address['latitude'];
          final lng = address['longitude'];
          return lat != null && lng != null && 
                 lat != 0 && lng != 0 && 
                 lat is num && lng is num;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void _openInGoogleMaps(String addressText) {
    try {
      // Try to get coordinates first
      final coordinates = _getCoordinatesFromOrder(addressText);
      
      if (coordinates != null) {
        // Use coordinates for more accurate location
        final lat = coordinates['lat'];
        final lng = coordinates['lng'];
        final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
        
        _launchUrl(url);
      } else {
        // Fallback to address search
        final encodedAddress = Uri.encodeComponent(addressText);
        final url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
        
        _launchUrl(url);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open maps: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Map<String, double>? _getCoordinatesFromOrder(String addressText) {
    try {
      // Find the order with this address and extract coordinates
      for (final order in _orders) {
        if (order['deliveryAddress'] == addressText) {
          final deliveryDetails = order['deliveryDetails'];
          if (deliveryDetails != null && deliveryDetails is Map<String, dynamic>) {
            final address = deliveryDetails['address'];
            if (address != null && address is Map<String, dynamic>) {
              final lat = address['latitude']?.toDouble();
              final lng = address['longitude']?.toDouble();
              
              if (lat != null && lng != null && lat != 0 && lng != 0) {
                return {'lat': lat, 'lng': lng};
              }
            }
          }
          break;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Copy to clipboard as fallback
        await Clipboard.setData(ClipboardData(text: url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maps URL copied to clipboard'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      // Copy to clipboard as fallback
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maps URL copied to clipboard'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }
}
