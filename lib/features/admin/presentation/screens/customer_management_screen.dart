import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:denzels_cakes/shared/theme/app_theme.dart';
import 'package:denzels_cakes/core/services/admin_api_service_new.dart';
import 'orders_management_screen.dart';

class CustomerManagementScreen extends StatefulWidget {
  final bool embedded;

  const CustomerManagementScreen({super.key, this.embedded = false});

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customerData = await AdminApiService.getAllCustomers(
        page: 1,
        limit: 100,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _selectedFilter != 'all' ? _selectedFilter : null,
      );

      setState(() {
        // Map backend user data to customer format
        _customers = (customerData['customers'] as List).map((user) {
          return {
            '_id': user['_id'],
            'name': user['name'] ?? 'Unknown Customer',
            'email': user['email'] ?? '',
            'phone': user['phone'] ?? '',
            'status': user['status'] ?? 'active',
            'createdAt': user['createdAt'] ?? DateTime.now().toIso8601String(),
            'totalOrders': user['totalOrders'] ?? 0,
            'totalSpent': (user['totalSpent'] ?? 0).toDouble(),
            'loyaltyPoints': user['loyaltyPoints'] ?? 0,
            'lastOrderDate': user['lastOrderDate'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
// print('Error loading customers: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load customers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredCustomers {
    // Since backend handles filtering, just sort by creation date (newest first)
    var filtered = List<Map<String, dynamic>>.from(_customers);

    filtered.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
      final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildEmbeddedContent();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildEmbeddedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Customer Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadCustomers,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredCustomers.isEmpty
                  ? _buildEmptyState()
                  : _buildCustomersList(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search customers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              // Debounce search - reload customers after user stops typing
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchQuery == value) {
                  _loadCustomers();
                }
              });
            },
          ),
          const SizedBox(height: 16),
          // Filter chips
          Row(
            children: [
              const Text('Filter:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedFilter == 'all',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'all';
                        });
                        _loadCustomers();
                      },
                      selectedColor:
                          AppTheme.primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.primaryColor,
                    ),
                    FilterChip(
                      label: const Text('VIP'),
                      selected: _selectedFilter == 'vip',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'vip';
                        });
                        _loadCustomers();
                      },
                      selectedColor: Colors.purple.withValues(alpha: 0.2),
                      checkmarkColor: Colors.purple,
                    ),
                    FilterChip(
                      label: const Text('Active'),
                      selected: _selectedFilter == 'active',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'active';
                        });
                        _loadCustomers();
                      },
                      selectedColor: Colors.green.withValues(alpha: 0.2),
                      checkmarkColor: Colors.green,
                    ),
                    FilterChip(
                      label: const Text('New'),
                      selected: _selectedFilter == 'new',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'new';
                        });
                        _loadCustomers();
                      },
                      selectedColor: Colors.blue.withValues(alpha: 0.2),
                      checkmarkColor: Colors.blue,
                    ),
                    FilterChip(
                      label: const Text('Inactive'),
                      selected: _selectedFilter == 'inactive',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'inactive';
                        });
                        _loadCustomers();
                      },
                      selectedColor: Colors.grey.withValues(alpha: 0.2),
                      checkmarkColor: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'No customers match your filters'
                : 'No customers found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Try adjusting your search or filters'
                : 'Customers will appear here once they place orders',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];
        return _buildCustomerCard(customer);
      },
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final status = customer['status'] ?? 'active';
    final totalSpent = (customer['totalSpent'] ?? 0).toDouble();
    final totalOrders = customer['totalOrders'] ?? 0;
    final loyaltyPoints = customer['loyaltyPoints'] ?? 0;
    final lastOrderDate = customer['lastOrderDate'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Customer avatar
                CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      _getStatusColor(status).withValues(alpha: 0.2),
                  child: Text(
                    customer['name']
                            ?.toString()
                            .split(' ')
                            .map((n) => n[0])
                            .take(2)
                            .join('') ??
                        'CU',
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customer['name'] ?? 'Unknown Customer',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer['email'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (customer['phone'] != null)
                        Text(
                          customer['phone'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view_orders',
                      child: Row(
                        children: [
                          Icon(Icons.receipt_long, size: 18),
                          SizedBox(width: 8),
                          Text('View Orders'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'contact',
                      child: Row(
                        children: [
                          Icon(Icons.message, size: 18),
                          SizedBox(width: 8),
                          Text('Contact'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view_orders':
                        _viewCustomerOrders(customer);
                        break;
                      case 'contact':
                        _showContactOptions(context, customer);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Customer stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Orders',
                    totalOrders.toString(),
                    Icons.shopping_bag,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatItem(
                    'Spent',
                    '${(totalSpent / 100).toStringAsFixed(0)} XAF',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatItem(
                    'Points',
                    loyaltyPoints.toString(),
                    Icons.stars,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            if (lastOrderDate != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last order: ${_formatDate(lastOrderDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final text = status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'vip':
        return Colors.purple;
      case 'active':
        return Colors.green;
      case 'new':
        return Colors.blue;
      case 'inactive':
        return Colors.grey;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  void _viewCustomerOrders(Map<String, dynamic> customer) {
    final customerName = customer['name'] ?? 'Unknown Customer';
    
    // Navigate to orders management screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OrdersManagementScreen(
          embedded: false,
        ),
      ),
    ).then((_) {
      // After returning, could optionally reload customers if needed
      _loadCustomers();
    });
    
    // Show a snackbar to inform the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing orders for: $customerName'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Search',
          onPressed: () {
            // The orders screen will be opened, user can search for customer name
          },
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context, Map<String, dynamic> customer) {
    final customerName = customer['name'] ?? 'Unknown Customer';
    final email = customer['email'];
    final phone = customer['phone'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.contact_mail, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Contact $customerName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (phone != null && phone.isNotEmpty) ...[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.phone, color: Colors.green),
                ),
                title: const Text('Call'),
                subtitle: Text(phone),
                onTap: () {
                  Navigator.pop(context);
                  _makePhoneCall(phone);
                },
              ),
              const Divider(),
            ],
            if (email != null && email.isNotEmpty) ...[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.email, color: Colors.blue),
                ),
                title: const Text('Send Email'),
                subtitle: Text(email),
                onTap: () {
                  Navigator.pop(context);
                  _sendEmail(email, customerName);
                },
              ),
            ],
            if ((phone == null || phone.isEmpty) && (email == null || email.isEmpty))
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No contact information available for this customer.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Clean phone number - remove any spaces, dashes, etc.
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Try different phone formats
    final phoneFormats = [
      'tel:$cleanNumber',
      'tel:+$cleanNumber',
      'tel://$cleanNumber',
    ];

    for (final phoneFormat in phoneFormats) {
      try {
        final Uri phoneUri = Uri.parse(phoneFormat);
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (e) {
        // Try next format
      }
    }

    // Last resort - try direct launch
    try {
      final Uri phoneUri = Uri.parse('tel:$cleanNumber');
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make phone call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail(String email, String customerName) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': 'Message for $customerName',
          'body': 'Dear $customerName,\n\n',
        },
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: try simpler mailto
        final simpleUri = Uri.parse('mailto:$email');
        if (await canLaunchUrl(simpleUri)) {
          await launchUrl(simpleUri, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Cannot launch email');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
