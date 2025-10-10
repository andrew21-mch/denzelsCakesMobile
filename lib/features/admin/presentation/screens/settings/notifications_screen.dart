import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../core/services/admin_api_service_new.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _notificationSettings = {};
  List<Map<String, dynamic>> _notificationHistory = [];

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = await AdminApiService.getNotificationSettings();
      final history = await AdminApiService.getNotificationHistory(limit: 3);
      setState(() {
        _notificationSettings = settings;
        _notificationHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      // Set default notification settings if API fails
      setState(() {
        _notificationSettings = {
          'emailNotifications': {
            'newOrders': true,
            'orderStatus': true,
            'lowStock': true,
            'dailyReports': false,
            'weeklyReports': false,
            'urgentOrders': true,
            'paymentReceived': true,
            'paymentFailed': true,
            'systemAlerts': true,
          },
          'pushNotifications': {
            'newOrders': true,
            'orderStatus': true,
            'lowStock': true,
            'dailyReports': false,
            'weeklyReports': false,
            'urgentOrders': true,
            'paymentReceived': true,
            'paymentFailed': true,
            'systemAlerts': true,
          },
        };
        _notificationHistory = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Using default notification settings'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  final Map<String, String> _notificationDescriptions = {
    'newOrders': 'When new orders are placed',
    'orderStatus': 'When order status changes',
    'lowStock': 'When products are running low',
    'dailyReports': 'Daily business summary',
    'weeklyReports': 'Weekly business reports',
    'urgentOrders': 'High priority or express orders',
    'paymentReceived': 'When payments are confirmed',
    'paymentFailed': 'When payments fail',
    'systemAlerts': 'System errors and updates',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _testNotifications,
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Send Test Notification',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildEmailNotificationsCard(),
                  const SizedBox(height: 16),
                  _buildPushNotificationsCard(),
                  const SizedBox(height: 16),
                  _buildNotificationHistoryCard(),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSettings,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.save),
        label: const Text('Save Settings'),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Informed',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure how you want to receive notifications about your business',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailNotificationsCard() {
    return _buildNotificationCard(
      'Email Notifications',
      Icons.email,
      'emailNotifications',
      Colors.green,
      'Receive updates via email',
    );
  }

  Widget _buildPushNotificationsCard() {
    return _buildNotificationCard(
      'Push Notifications',
      Icons.notifications,
      'pushNotifications',
      Colors.blue,
      'Real-time alerts on your device',
    );
  }


  Widget _buildNotificationCard(
    String title,
    IconData icon,
    String settingsKey,
    Color color,
    String description,
  ) {
    final settingsData = _notificationSettings[settingsKey];
    final settings = settingsData is Map<String, dynamic> 
        ? Map<String, bool>.from(settingsData)
        : <String, bool>{};

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...settings.entries.map((entry) => _buildNotificationToggle(
                  settingsKey,
                  entry.key,
                  entry.key,
                  _notificationDescriptions[entry.key] ?? entry.key,
                  entry.value,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    String category,
    String key,
    String title,
    String description,
    bool value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title
                      .replaceAllMapped(
                        RegExp(r'([A-Z])'),
                        (match) => ' ${match.group(0)}',
                      )
                      .trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) =>
                _updateNotificationSetting(category, key, newValue),
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Mock notification history - TODO: Connect to backend
  final List<Map<String, dynamic>> _mockNotificationHistory = [
    {
      'type': 'new_order',
      'title': 'New Order Received',
      'message': 'Order #CS-2024-001 placed by John Doe',
      'time': '2 hours ago',
      'icon': Icons.shopping_bag,
      'color': Colors.green,
    },
    {
      'type': 'payment',
      'title': 'Payment Confirmed',
      'message': 'Payment of 25,000 XAF received for order #CS-2024-002',
      'time': '4 hours ago',
      'icon': Icons.payment,
      'color': Colors.blue,
    },
    {
      'type': 'low_stock',
      'title': 'Low Stock Alert',
      'message': 'Chocolate Cake ingredients running low',
      'time': '1 day ago',
      'icon': Icons.warning,
      'color': Colors.orange,
    },
    {
      'type': 'order_status',
      'title': 'Order Status Update',
      'message': 'Order #CS-2024-003 is ready for pickup',
      'time': '6 hours ago',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'type': 'payment_failed',
      'title': 'Payment Failed',
      'message': 'Payment failed for order #CS-2024-004',
      'time': '8 hours ago',
      'icon': Icons.error,
      'color': Colors.red,
    },
    {
      'type': 'urgent_order',
      'title': 'Urgent Order Alert',
      'message': 'Express order #CS-2024-005 requires immediate attention',
      'time': '12 hours ago',
      'icon': Icons.priority_high,
      'color': Colors.red,
    },
    {
      'type': 'system_alert',
      'title': 'System Update',
      'message': 'App updated to version 1.2.0 with new features',
      'time': '2 days ago',
      'icon': Icons.system_update,
      'color': Colors.blue,
    },
    {
      'type': 'daily_report',
      'title': 'Daily Sales Report',
      'message': 'Yesterday\'s sales: 15 orders, 45,000 XAF revenue',
      'time': '3 days ago',
      'icon': Icons.analytics,
      'color': Colors.purple,
    },
    {
      'type': 'weekly_report',
      'title': 'Weekly Summary',
      'message': 'This week: 89 orders, 234,000 XAF total revenue',
      'time': '1 week ago',
      'icon': Icons.trending_up,
      'color': Colors.green,
    },
    {
      'type': 'low_stock',
      'title': 'Stock Alert',
      'message': 'Vanilla extract running low - reorder needed',
      'time': '1 week ago',
      'icon': Icons.inventory,
      'color': Colors.orange,
    },
  ];

  Widget _buildNotificationHistoryCard() {

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history,
                    color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Recent Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _viewAllNotifications,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _notificationHistory.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: _notificationHistory
                        .map((notification) => _buildRealHistoryItem(notification))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> notification) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notification['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              notification['icon'],
              color: notification['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            notification['time'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealHistoryItem(Map<String, dynamic> notification) {
    final notificationId = notification['_id'] as String;
    final type = notification['type'] as String;
    final title = notification['title'] as String;
    final message = notification['message'] as String;
    final sentAt = DateTime.parse(notification['sentAt'] as String);
    final channels = notification['channels'] as Map<String, dynamic>;
    
    // Get icon and color based on type
    IconData icon;
    Color color;
    
    switch (type) {
      case 'newOrder':
        icon = Icons.shopping_bag;
        color = Colors.green;
        break;
      case 'paymentReceived':
        icon = Icons.payment;
        color = Colors.blue;
        break;
      case 'paymentFailed':
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'orderStatus':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'urgentOrder':
        icon = Icons.priority_high;
        color = Colors.red;
        break;
      case 'systemAlert':
        icon = Icons.system_update;
        color = Colors.blue;
        break;
      case 'lowStock':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case 'dailyReport':
        icon = Icons.analytics;
        color = Colors.purple;
        break;
      case 'weeklyReport':
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }
    
    // Format time
    final now = DateTime.now();
    final difference = now.difference(sentAt);
    String timeAgo;
    
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      timeAgo = 'Just now';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (channels['email'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (channels['email'] == true && channels['push'] == true)
                      const SizedBox(width: 4),
                    if (channels['push'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Push',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              IconButton(
                onPressed: () => _deleteNotification(notificationId),
                icon: const Icon(Icons.delete_outline, size: 16),
                color: Colors.red[400],
                tooltip: 'Delete notification',
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateNotificationSetting(String category, String key, bool value) {
    setState(() {
      if (_notificationSettings[category] == null) {
        _notificationSettings[category] = <String, bool>{};
      }
      _notificationSettings[category][key] = value;
    });
  }

  Widget _buildDialogHistoryItem(Map<String, dynamic> notification) {
    final notificationId = notification['_id'] as String;
    final type = notification['type'] as String;
    final title = notification['title'] as String;
    final message = notification['message'] as String;
    final sentAt = DateTime.parse(notification['sentAt'] as String);
    final channels = notification['channels'] as Map<String, dynamic>;
    
    // Get icon and color based on type
    IconData icon;
    Color color;
    
    switch (type) {
      case 'newOrder':
        icon = Icons.shopping_bag;
        color = Colors.green;
        break;
      case 'paymentReceived':
        icon = Icons.payment;
        color = Colors.blue;
        break;
      case 'paymentFailed':
        icon = Icons.error;
        color = Colors.red;
        break;
      case 'orderStatus':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'urgentOrder':
        icon = Icons.priority_high;
        color = Colors.red;
        break;
      case 'systemAlert':
        icon = Icons.system_update;
        color = Colors.blue;
        break;
      case 'lowStock':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case 'dailyReport':
        icon = Icons.analytics;
        color = Colors.purple;
        break;
      case 'weeklyReport':
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }
    
    // Format time
    final now = DateTime.now();
    final difference = now.difference(sentAt);
    String timeAgo;
    
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      timeAgo = 'Just now';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _deleteNotification(notificationId),
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.red[400],
                tooltip: 'Delete notification',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Channels
          Row(
            children: [
              if (channels['email'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email,
                        size: 14,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (channels['email'] == true && channels['push'] == true)
                const SizedBox(width: 8),
              if (channels['push'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications,
                        size: 14,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Push',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
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

  void _deleteNotification(String notificationId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Remove from UI immediately
        setState(() {
          _notificationHistory.removeWhere((notification) => notification['_id'] == notificationId);
        });
        
        await AdminApiService.deleteNotification(notificationId);
        
        if (mounted) {
          // Show success toast at the top
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notification deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).size.height - 100,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        // Re-add to UI if deletion failed
        setState(() {
          _loadNotificationSettings();
        });
        
        if (mounted) {
          // Show error toast at the top
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete notification: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).size.height - 100,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  void _testNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Test Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose which type of notification to test:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.green),
              title: const Text('Email Test'),
              onTap: () => _sendTestNotification('email'),
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: const Text('Push Notification Test'),
              onTap: () => _sendTestNotification('push'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification(String type) async {
    Navigator.of(context).pop();

    try {
      await AdminApiService.sendTestNotification(type: type);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test $type notification sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send test notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewAllNotifications() async {
    try {
      final notifications = await AdminApiService.getNotificationHistory(limit: 100);
      
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notification History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Notifications will appear here when sent',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: notifications.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _buildDialogHistoryItem(notification);
                          },
                        ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Total: ${notifications.length} notifications',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AdminApiService.updateNotificationSettings(_notificationSettings);
      
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
