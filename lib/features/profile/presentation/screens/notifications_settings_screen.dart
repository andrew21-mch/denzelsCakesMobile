import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.notificationSettings),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              AppLocalizations.of(context)!.save,
              style: const TextStyle(
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
            title: AppLocalizations.of(context)!.notificationPreferences,
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: AppLocalizations.of(context)!.pushNotifications,
                subtitle: AppLocalizations.of(context)!.receiveNotificationsOnDevice,
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.shopping_bag_outlined,
                title: AppLocalizations.of(context)!.orderUpdates,
                subtitle: AppLocalizations.of(context)!.orderUpdatesDesc,
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
                title: AppLocalizations.of(context)!.promotionsOffers,
                subtitle: AppLocalizations.of(context)!.promotionsOffersDesc,
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
                title: AppLocalizations.of(context)!.securityAlerts,
                subtitle: AppLocalizations.of(context)!.securityAlertsDesc,
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
              child: Text(AppLocalizations.of(context)!.resetToDefaults),
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
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();

    // In a real app, save settings to backend/local storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.notificationSettingsSaved),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _resetToDefaults() {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetToDefaultsTitle),
        content: Text(l10n.resetToDefaultsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
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
                SnackBar(
                  content: Text(l10n.settingsResetToDefaults),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Text(
              l10n.reset,
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
