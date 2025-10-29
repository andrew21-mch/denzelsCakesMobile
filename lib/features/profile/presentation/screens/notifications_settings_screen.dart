import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  // Simplified notification preferences - only 4 options
  bool _pushNotifications = true;
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _securityAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Simplified notification settings - only 4 options
          _buildSectionCard(
            title: 'Notification Preferences',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive notifications on your device',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.shopping_bag_outlined,
                title: 'Order Updates',
                subtitle: 'Order confirmations, preparation, and delivery updates',
                value: _orderUpdates,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _orderUpdates = value;
                        });
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.local_offer_outlined,
                title: 'Promotions & Offers',
                subtitle: 'Special deals and new product announcements',
                value: _promotions,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _promotions = value;
                        });
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.security_outlined,
                title: 'Security Alerts',
                subtitle: 'Important security notifications and account activity',
                value: _securityAlerts,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _securityAlerts = value;
                        });
                      }
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Reset to defaults button
          Center(
            child: OutlinedButton(
              onPressed: _resetToDefaults,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              child: const Text('Reset to Defaults'),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final isEnabled = onChanged != null;

    return ListTile(
      leading: Icon(
        icon,
        color: isEnabled ? AppTheme.accentColor : AppTheme.textTertiary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isEnabled ? AppTheme.textPrimary : AppTheme.textTertiary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isEnabled ? AppTheme.textSecondary : AppTheme.textTertiary,
          fontSize: 13,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.accentColor,
      ),
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onChanged(!value);
            }
          : null,
    );
  }

  void _saveSettings() {
    HapticFeedback.lightImpact();

    // In a real app, save settings to backend/local storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _resetToDefaults() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'This will reset all notification settings to their default values. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Reset to default values
                _pushNotifications = true;
                _orderUpdates = true;
                _promotions = false;
                _securityAlerts = true;
              });

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
