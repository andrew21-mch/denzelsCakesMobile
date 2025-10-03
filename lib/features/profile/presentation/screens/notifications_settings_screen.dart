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
  // Notification preferences
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  // Order notifications
  bool _orderConfirmation = true;
  bool _orderPreparation = true;
  bool _orderReady = true;
  bool _orderDelivered = true;
  bool _orderCancelled = true;

  // Marketing notifications
  bool _promotions = true;
  bool _newProducts = false;
  bool _specialOffers = true;
  bool _newsletter = false;

  // App notifications
  bool _appUpdates = true;
  bool _securityAlerts = true;
  bool _accountActivity = false;

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
          // General Settings
          _buildSectionCard(
            title: 'General Settings',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive notifications on your device',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                    if (!value) {
                      // Disable all push-based notifications
                      _orderConfirmation = false;
                      _orderPreparation = false;
                      _orderReady = false;
                      _orderDelivered = false;
                      _orderCancelled = false;
                      _promotions = false;
                      _newProducts = false;
                      _specialOffers = false;
                      _appUpdates = false;
                      _securityAlerts = false;
                      _accountActivity = false;
                    }
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.sms_outlined,
                title: 'SMS Notifications',
                subtitle: 'Receive notifications via SMS',
                value: _smsNotifications,
                onChanged: (value) {
                  setState(() {
                    _smsNotifications = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Order Notifications
          _buildSectionCard(
            title: 'Order Notifications',
            children: [
              _buildSwitchTile(
                icon: Icons.check_circle_outline,
                title: 'Order Confirmation',
                subtitle: 'When your order is confirmed',
                value: _orderConfirmation,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _orderConfirmation = value;
                        });
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.kitchen_outlined,
                title: 'Order Preparation',
                subtitle: 'When your order is being prepared',
                value: _orderPreparation,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _orderPreparation = value;
                        });
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.cake_outlined,
                title: 'Order Ready',
                subtitle: 'When your order is ready for pickup/delivery',
                value: _orderReady,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _orderReady = value;
                        });
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.delivery_dining_outlined,
                title: 'Order Delivered',
                subtitle: 'When your order has been delivered',
                value: _orderDelivered,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _orderDelivered = value;
                        });
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.cancel_outlined,
                title: 'Order Cancelled',
                subtitle: 'When your order is cancelled',
                value: _orderCancelled,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _orderCancelled = value;
                        });
                      }
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Marketing Notifications
          _buildSectionCard(
            title: 'Marketing & Promotions',
            children: [
              _buildSwitchTile(
                icon: Icons.local_offer_outlined,
                title: 'Promotions',
                subtitle: 'Special deals and discounts',
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
                icon: Icons.new_releases_outlined,
                title: 'New Products',
                subtitle: 'When new cakes are available',
                value: _newProducts,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _newProducts = value;
                        });
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.star_outline,
                title: 'Special Offers',
                subtitle: 'Limited time offers and events',
                value: _specialOffers,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _specialOffers = value;
                        });
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.newspaper_outlined,
                title: 'Newsletter',
                subtitle: 'Weekly newsletter with updates',
                value: _newsletter,
                onChanged: _emailNotifications
                    ? (value) {
                        setState(() {
                          _newsletter = value;
                        });
                      }
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // App Notifications
          _buildSectionCard(
            title: 'App & Security',
            children: [
              _buildSwitchTile(
                icon: Icons.system_update_outlined,
                title: 'App Updates',
                subtitle: 'When new app versions are available',
                value: _appUpdates,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _appUpdates = value;
                        });
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.security_outlined,
                title: 'Security Alerts',
                subtitle: 'Important security notifications',
                value: _securityAlerts,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _securityAlerts = value;
                        });
                      }
                    : null,
              ),
              _buildSwitchTile(
                icon: Icons.account_circle_outlined,
                title: 'Account Activity',
                subtitle: 'Login attempts and profile changes',
                value: _accountActivity,
                onChanged: _pushNotifications
                    ? (value) {
                        setState(() {
                          _accountActivity = value;
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
                _emailNotifications = true;
                _smsNotifications = false;

                _orderConfirmation = true;
                _orderPreparation = true;
                _orderReady = true;
                _orderDelivered = true;
                _orderCancelled = true;

                _promotions = true;
                _newProducts = false;
                _specialOffers = true;
                _newsletter = false;

                _appUpdates = true;
                _securityAlerts = true;
                _accountActivity = false;
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
