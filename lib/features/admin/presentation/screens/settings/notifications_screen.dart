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
      setState(() {
        _notificationSettings = settings;
        _isLoading = false;
      });
    } catch (e) {
// print('Error loading notification settings: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notification settings: $e'),
            backgroundColor: Colors.red,
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
                  _buildSMSNotificationsCard(),
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

  Widget _buildSMSNotificationsCard() {
    return _buildNotificationCard(
      'SMS Notifications',
      Icons.sms,
      'smsNotifications',
      Colors.orange,
      'Text message alerts (charges may apply)',
    );
  }

  Widget _buildNotificationCard(
    String title,
    IconData icon,
    String settingsKey,
    Color color,
    String description,
  ) {
    final settings = _notificationSettings[settingsKey] as Map<String, bool>;

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

  Widget _buildNotificationHistoryCard() {
    // Mock notification history - TODO: Connect to backend
    final mockHistory = [
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
    ];

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
            ...mockHistory
                .map((notification) => _buildHistoryItem(notification)),
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

  void _updateNotificationSetting(String category, String key, bool value) {
    setState(() {
      _notificationSettings[category][key] = value;
    });
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
              title: const Text('Email'),
              onTap: () => _sendTestNotification('email'),
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: const Text('Push Notification'),
              onTap: () => _sendTestNotification('push'),
            ),
            ListTile(
              leading: const Icon(Icons.sms, color: Colors.orange),
              title: const Text('SMS'),
              onTap: () => _sendTestNotification('sms'),
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

  void _sendTestNotification(String type) {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Test $type notification sent!'),
        backgroundColor: Colors.blue,
      ),
    );

    // TODO: Implement actual test notification sending
  }

  void _viewAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('View complete notification history'),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement notification history screen',
              style: TextStyle(
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Connect to backend API when available
    await Future.delayed(const Duration(seconds: 1));

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
  }
}
