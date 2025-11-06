import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  // COMMENTED OUT - Unused state variables for disabled features
  // bool _biometricEnabled = true;
  // bool _twoFactorEnabled = false;
  // bool _dataEncryption = true;
  // bool _activityLogging = true;
  // bool _shareAnalytics = false;
  // bool _marketingEmails = true;
  // bool _locationTracking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.privacySecurity),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Security Section - Only keep Change Password and Active Sessions
            _buildSecuritySection(),

            const SizedBox(height: 24),

            // Account Actions Section - Keep Delete and Deactivate
            _buildAccountActionsSection(),

            // COMMENTED OUT SECTIONS - Too many options
            // const SizedBox(height: 24),
            // _buildPrivacySection(),
            // const SizedBox(height: 24),
            // _buildDataManagementSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(
                Icons.security,
                color: AppTheme.accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.security,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // COMMENTED OUT - Too many security options
          // Biometric Authentication
          // _buildSwitchTile(
          //   icon: Icons.fingerprint,
          //   title: 'Biometric Authentication',
          //   subtitle: 'Use fingerprint or face ID to unlock app',
          //   value: _biometricEnabled,
          //   onChanged: (value) {
          //     HapticFeedback.lightImpact();
          //     setState(() {
          //       _biometricEnabled = value;
          //     });
          //     _showSecurityChangeDialog('Biometric Authentication', value);
          //   },
          // ),

          // const SizedBox(height: 16),

          // Two-Factor Authentication
          // _buildSwitchTile(
          //   icon: Icons.verified_user,
          //   title: 'Two-Factor Authentication',
          //   subtitle: 'Add extra security to your account',
          //   value: _twoFactorEnabled,
          //   onChanged: (value) {
          //     HapticFeedback.lightImpact();
          //     if (value) {
          //       _showTwoFactorSetupDialog();
          //     } else {
          //       setState(() {
          //         _twoFactorEnabled = value;
          //       });
          //     }
          //   },
          // ),

          // const SizedBox(height: 16),

          // Change Password
          _buildActionTile(
            icon: Icons.lock_outline,
            title: AppLocalizations.of(context)!.changePassword,
            subtitle: AppLocalizations.of(context)!.updateAccountPassword,
            onTap: () {
              HapticFeedback.lightImpact();
              _showChangePasswordDialog();
            },
          ),

          const SizedBox(height: 16),

          // Active Sessions
          _buildActionTile(
            icon: Icons.devices,
            title: AppLocalizations.of(context)!.activeSessions,
            subtitle: AppLocalizations.of(context)!.manageDevicesLoggedIn,
            onTap: () {
              HapticFeedback.lightImpact();
              _showActiveSessionsDialog();
            },
          ),
        ],
      ),
    );
  }

  // COMMENTED OUT - Too many privacy options
  /*
  Widget _buildPrivacySection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(
                Icons.privacy_tip,
                color: AppTheme.accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Privacy',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Data Encryption
          _buildSwitchTile(
            icon: Icons.enhanced_encryption,
            title: 'Data Encryption',
            subtitle: 'Encrypt sensitive data on device',
            value: _dataEncryption,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() {
                _dataEncryption = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Activity Logging
          _buildSwitchTile(
            icon: Icons.history,
            title: 'Activity Logging',
            subtitle: 'Keep track of account activity',
            value: _activityLogging,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() {
                _activityLogging = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Share Analytics
          _buildSwitchTile(
            icon: Icons.analytics,
            title: 'Share Analytics',
            subtitle: 'Help improve app with usage data',
            value: _shareAnalytics,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() {
                _shareAnalytics = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Marketing Emails
          _buildSwitchTile(
            icon: Icons.email,
            title: 'Marketing Emails',
            subtitle: 'Receive promotional offers and updates',
            value: _marketingEmails,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() {
                _marketingEmails = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Location Tracking
          _buildSwitchTile(
            icon: Icons.location_on,
            title: 'Location Tracking',
            subtitle: 'Allow location access for delivery',
            value: _locationTracking,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() {
                _locationTracking = value;
              });
            },
          ),
        ],
      ),
    );
  }
  */

  // COMMENTED OUT - Too many data management options
  /*
  Widget _buildDataManagementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(
                Icons.storage,
                color: AppTheme.accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Data Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Download Data
          _buildActionTile(
            icon: Icons.download,
            title: 'Download My Data',
            subtitle: 'Get a copy of your account data',
            onTap: () {
              HapticFeedback.lightImpact();
              _showDownloadDataDialog();
            },
          ),

          const SizedBox(height: 16),

          // Clear Cache
          _buildActionTile(
            icon: Icons.clear_all,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () {
              HapticFeedback.lightImpact();
              _showClearCacheDialog();
            },
          ),

          const SizedBox(height: 16),

          // Data Usage
          _buildActionTile(
            icon: Icons.data_usage,
            title: 'Data Usage',
            subtitle: 'View app data consumption',
            onTap: () {
              HapticFeedback.lightImpact();
              _showDataUsageDialog();
            },
          ),
        ],
      ),
    );
  }
  */

  Widget _buildAccountActionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              const Icon(
                Icons.account_circle,
                color: AppTheme.errorColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.accountActions,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Deactivate Account
          _buildActionTile(
            icon: Icons.pause_circle_outline,
            title: AppLocalizations.of(context)!.deactivateAccount,
            subtitle: AppLocalizations.of(context)!.deactivateAccountMessage.split('.')[0] + '.',
            onTap: () {
              HapticFeedback.lightImpact();
              _showDeactivateAccountDialog();
            },
            isDestructive: true,
          ),

          const SizedBox(height: 16),

          // Delete Account
          _buildActionTile(
            icon: Icons.delete_forever,
            title: AppLocalizations.of(context)!.deleteAccount,
            subtitle: AppLocalizations.of(context)!.deleteAccountMessage.split('.')[0] + '.',
            onTap: () {
              HapticFeedback.mediumImpact();
              _showDeleteAccountDialog();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  // COMMENTED OUT - No longer needed since switch tiles are disabled
  /*
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.accentColor,
          size: 20,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.accentColor,
        ),
      ],
    );
  }
  */

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.errorColor.withValues(alpha: 0.1)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isDestructive
              ? Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppTheme.errorColor : AppTheme.accentColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppTheme.errorColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDestructive
                          ? AppTheme.errorColor.withValues(alpha: 0.7)
                          : AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color:
                  isDestructive ? AppTheme.errorColor : AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // COMMENTED OUT - No longer needed since biometric and 2FA are disabled
  /*
  void _showSecurityChangeDialog(String feature, bool enabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature ${enabled ? 'enabled' : 'disabled'}'),
        backgroundColor: enabled ? AppTheme.successColor : AppTheme.errorColor,
      ),
    );
  }

  void _showTwoFactorSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Two-Factor Authentication'),
        content: const Text(
          'Two-factor authentication adds an extra layer of security to your account. '
          'You\'ll need to verify your identity using a second method when signing in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _twoFactorEnabled = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Two-factor authentication setup completed!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Setup'),
          ),
        ],
      ),
    );
  }
  */

  void _showChangePasswordDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: l10n.currentPassword,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.newPassword,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: l10n.confirmNewPassword,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.passwordChangedSuccessfully),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.activeSessions),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: Text(l10n.thisDevice),
              subtitle: Text('Pixel 4a • ${l10n.activeNow}'),
              trailing: Chip(label: Text(l10n.current)),
            ),
            ListTile(
              leading: const Icon(Icons.computer),
              title: Text(l10n.webBrowser),
              subtitle: Text(l10n.daysAgo(2)),
              trailing: const Icon(Icons.more_vert),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  // COMMENTED OUT - No longer needed since data management section is disabled
  /*
  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download My Data'),
        content: const Text(
          'We\'ll prepare a copy of your data and send it to your email address. '
          'This may take up to 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download request submitted!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear temporary files and free up storage space. '
          'Your account data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDataUsageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Usage'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This month:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Images: 45.2 MB'),
            Text('App data: 12.8 MB'),
            Text('Cache: 8.3 MB'),
            SizedBox(height: 8),
            Text('Total: 66.3 MB',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
  */

  void _showDeactivateAccountDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deactivateAccount),
        content: Text(l10n.deactivateAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.accountDeactivated),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deactivate),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.accountDeletionRequiresVerification),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
