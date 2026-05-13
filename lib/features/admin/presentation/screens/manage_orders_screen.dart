import 'dart:convert';
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

              // Order items with customizations
              ...((order['items'] as List).map((item) {
                final customizations = item['customizations'] as Map<String, dynamic>? ?? {};
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                              '${item['quantity']}x ${item['title']} (${item['size']}, ${item['flavor']})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Customizations details
                      if (customizations.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Delivery Date
                              if (customizations['deliveryDate'] != null)
                                _buildCustomizationRow(
                                  'Delivery Date',
                                  _formatCustomizationDate(customizations['deliveryDate']),
                                ),
                              
                              // Delivery Time
                              if (customizations['deliveryTime'] != null)
                                _buildCustomizationRow(
                                  'Delivery Time',
                                  customizations['deliveryTime'].toString(),
                                ),
                              
                              // Selected Color
                              if (customizations['selectedColor'] != null)
                                _buildCustomizationRow(
                                  'Custom Color',
                                  'Selected custom color',
                                  color: _parseColor(customizations['selectedColor']),
                                ),
                              
                              // Special Instructions
                              if (customizations['specialInstructions'] != null && 
                                  customizations['specialInstructions'].toString().isNotEmpty)
                                _buildCustomizationRow(
                                  'Special Instructions',
                                  customizations['specialInstructions'].toString(),
                                ),
                              
                              // Reference Images (check both 'images' and 'referenceImages' for compatibility)
                              if (_getImageCount(customizations) > 0)
                                _buildCustomizationRow(
                                  'Reference Images',
                                  '${_getImageCount(customizations)} image(s) uploaded',
                                ),
                            ],
                          ),
                        ),
                      ],
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

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.accentColor,
        side: const BorderSide(color: AppTheme.accentColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(0, 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
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
                    _buildDetailRow('Name', _getCustomerName(order)),
                    _buildDetailRow('Email', _getCustomerEmail(order)),
                    _buildDetailRow('Phone', _getCustomerPhone(order)),
                  ]),

                  const SizedBox(height: 20),

                  // Order Items with Customizations
                  _buildDetailSection(
                      'Order Items',
                      (order['items'] as List)
                          .map((item) =>
                              _buildItemDetailWithCustomizations(item, order['currency']))
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

  Widget _buildCustomizationRow(String label, String value, {Color? color, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppTheme.accentColor),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: icon != null ? 110 : 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (color != null) ...[
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color? _parseColor(dynamic colorData) {
    if (colorData == null) return null;
    
    try {
      if (colorData is String) {
        // Handle hex color strings like "#FF5722", "FF5722", "0xFF5722", or "#FFFFFFFF"
        String hex = colorData.trim();
        
        // Remove common prefixes
        hex = hex.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
        
        // If it's 6 characters, add alpha channel
        if (hex.length == 6) {
          hex = 'FF$hex'; // Add alpha channel (fully opaque)
        } else if (hex.length == 8) {
          // Already has alpha channel
        } else {
          // Invalid format, return null
          print('DEBUG: Invalid hex color format: $colorData');
          return null;
        }
        
        // Parse as integer
        final colorValue = int.parse(hex, radix: 16);
        return Color(colorValue);
      } else if (colorData is Map) {
        // Handle Color objects with r, g, b, a properties
        final r = (colorData['r'] as num?)?.toInt() ?? 0;
        final g = (colorData['g'] as num?)?.toInt() ?? 0;
        final b = (colorData['b'] as num?)?.toInt() ?? 0;
        final a = (colorData['a'] as num?)?.toInt() ?? 255;
        return Color.fromARGB(a, r, g, b);
      } else if (colorData is int) {
        // Handle direct integer color value
        return Color(colorData);
      }
    } catch (e) {
      // If parsing fails, return null
      print('DEBUG: Error parsing color $colorData: $e');
    }
    return null;
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

  Widget _buildItemDetailWithCustomizations(Map<String, dynamic> item, String currency) {
    // Handle customizations - can be Map or null
    Map<String, dynamic> customizations = {};
    if (item['customizations'] != null) {
      if (item['customizations'] is Map) {
        customizations = Map<String, dynamic>.from(item['customizations'] as Map);
      } else if (item['customizations'] is String) {
        // Try to parse if it's a JSON string
        try {
          final decoded = Map<String, dynamic>.from(
            json.decode(item['customizations'] as String)
          );
          customizations = decoded;
        } catch (e) {
          // If parsing fails, use empty map
        }
      }
    }
    
    // Debug: Print customizations to see what we're working with
    print('DEBUG: Admin - Item: ${item['title']}');
    print('DEBUG: Admin - Customizations raw type: ${item['customizations'].runtimeType}');
    print('DEBUG: Admin - Customizations raw: ${item['customizations']}');
    print('DEBUG: Admin - Customizations parsed: $customizations');
    print('DEBUG: Admin - Customizations keys: ${customizations.keys.toList()}');
    print('DEBUG: Admin - Has deliveryDate: ${customizations.containsKey('deliveryDate')}, value: ${customizations['deliveryDate']}');
    print('DEBUG: Admin - Has deliveryTime: ${customizations.containsKey('deliveryTime')}, value: ${customizations['deliveryTime']}');
    print('DEBUG: Admin - Has selectedColor: ${customizations.containsKey('selectedColor')}, value: ${customizations['selectedColor']}');
    print('DEBUG: Admin - Has specialInstructions: ${customizations.containsKey('specialInstructions')}, value: ${customizations['specialInstructions']}');
    print('DEBUG: Admin - Has images: ${customizations.containsKey('images')}, value: ${customizations['images']}');
    
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
            item['title'] ?? (item['cakeStyleId'] is Map ? item['cakeStyleId']['title'] : 'Unknown'),
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
          
          // Customizations
          if (customizations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.palette_outlined,
                        size: 18,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Customizations',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Delivery Date
                  if (customizations['deliveryDate'] != null && 
                      customizations['deliveryDate'].toString().isNotEmpty)
                    _buildCustomizationRow(
                      'Delivery Date',
                      _formatCustomizationDate(customizations['deliveryDate']),
                      icon: Icons.calendar_today,
                    ),
                  
                  // Delivery Time
                  if (customizations['deliveryTime'] != null && 
                      customizations['deliveryTime'].toString().isNotEmpty)
                    _buildCustomizationRow(
                      'Delivery Time',
                      _formatCustomizationTime(customizations['deliveryTime']),
                      icon: Icons.access_time,
                    ),
                  
                  // Selected Color
                  if (customizations['selectedColor'] != null && 
                      customizations['selectedColor'].toString().isNotEmpty)
                    _buildCustomizationRow(
                      'Custom Color',
                      _getColorDisplayText(customizations['selectedColor']),
                      color: _parseColor(customizations['selectedColor']),
                      icon: Icons.color_lens,
                    ),
                  
                  // Special Instructions
                  if (customizations['specialInstructions'] != null && 
                      customizations['specialInstructions'].toString().isNotEmpty) ...[
                    _buildCustomizationRow(
                      'Special Instructions',
                      customizations['specialInstructions'].toString(),
                      icon: Icons.notes,
                    ),
                  ],
                  
                  // Reference Images
                  if (_getImageCount(customizations) > 0)
                    _buildCustomizationRow(
                      'Reference Images',
                      '${_getImageCount(customizations)} image(s) uploaded',
                      icon: Icons.image,
                    ),
                ],
              ),
            ),
          ] else ...[
            // Show debug info if no customizations found
            const SizedBox(height: 8),
            Text(
              'No customizations found',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCustomizationDate(dynamic dateValue) {
    if (dateValue is String) {
      try {
        final date = DateTime.parse(dateValue);
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      } catch (e) {
        return dateValue.toString();
      }
    } else if (dateValue is Map) {
      // Handle date object from MongoDB
      return '${dateValue['day'] ?? ''}/${dateValue['month'] ?? ''}/${dateValue['year'] ?? ''}';
    }
    return dateValue.toString();
  }

  String _formatCustomizationTime(dynamic timeValue) {
    if (timeValue is String) {
      // Handle "HH:MM" format or ISO string
      if (timeValue.contains(':')) {
        // Check if it's a simple "HH:MM" format
        final parts = timeValue.split(':');
        if (parts.length >= 2) {
          return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
        }
      }
      // Try parsing as DateTime
      try {
        final dateTime = DateTime.parse(timeValue);
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return timeValue.toString();
      }
    }
    return timeValue.toString();
  }

  String _getColorDisplayText(dynamic colorValue) {
    if (colorValue is String) {
      // Return hex code if it's a string
      return colorValue;
    }
    // Return generic message for other types
    return 'Custom color selected';
  }

  int _getImageCount(Map<String, dynamic> customizations) {
    // Check both 'images' and 'referenceImages' for compatibility
    final images = customizations['images'] as List?;
    final referenceImages = customizations['referenceImages'] as List?;
    
    if (images != null && images.isNotEmpty) {
      return images.length;
    }
    if (referenceImages != null && referenceImages.isNotEmpty) {
      return referenceImages.length;
    }
    return 0;
  }

  String _getCustomerName(Map<String, dynamic> order) {
    // Handle both guestDetails and userId structures
    if (order['guestDetails'] != null) {
      return order['guestDetails']['name'] ?? 'Unknown';
    }
    if (order['userId'] != null && order['userId'] is Map) {
      return order['userId']['name'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  String _getCustomerEmail(Map<String, dynamic> order) {
    // Handle both guestDetails and userId structures
    if (order['guestDetails'] != null) {
      return order['guestDetails']['email'] ?? 'Unknown';
    }
    if (order['userId'] != null && order['userId'] is Map) {
      return order['userId']['email'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  String _getCustomerPhone(Map<String, dynamic> order) {
    // Handle both guestDetails and userId structures
    if (order['guestDetails'] != null) {
      return order['guestDetails']['phone'] ?? 'Unknown';
    }
    if (order['userId'] != null && order['userId'] is Map) {
      return order['userId']['phone'] ?? 'Unknown';
    }
    return 'Unknown';
  }
}
