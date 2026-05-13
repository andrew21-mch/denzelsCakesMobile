import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../core/services/admin_api_service_new.dart';

class BackupSyncScreen extends StatefulWidget {
  const BackupSyncScreen({super.key});

  @override
  State<BackupSyncScreen> createState() => _BackupSyncScreenState();
}

class _BackupSyncScreenState extends State<BackupSyncScreen> {
  bool _isLoading = false;
  bool _isBackingUp = false;
  bool _isSyncing = false;

  // Mock data - TODO: Connect to backend when backup/sync API is available
  final Map<String, dynamic> _backupSettings = {
    'autoBackup': true,
    'backupFrequency': 'daily', // daily, weekly, monthly
    'backupTime': '02:00',
    'cloudSync': true,
    'localBackup': true,
    'retentionDays': 30,
  };

  final List<Map<String, dynamic>> _backupHistory = [
    {
      'id': '1',
      'type': 'auto',
      'date': '2024-09-24 02:00',
      'size': '15.2 MB',
      'status': 'completed',
      'location': 'Cloud Storage',
    },
    {
      'id': '2',
      'type': 'manual',
      'date': '2024-09-23 14:30',
      'size': '14.8 MB',
      'status': 'completed',
      'location': 'Local Storage',
    },
    {
      'id': '3',
      'type': 'auto',
      'date': '2024-09-23 02:00',
      'size': '14.6 MB',
      'status': 'completed',
      'location': 'Cloud Storage',
    },
    {
      'id': '4',
      'type': 'auto',
      'date': '2024-09-22 02:00',
      'size': '14.1 MB',
      'status': 'failed',
      'location': 'Cloud Storage',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Backup & Sync'),
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
            onPressed: _showBackupInfo,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Backup Information',
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
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildQuickActionsCard(),
                  const SizedBox(height: 16),
                  _buildBackupSettingsCard(),
                  const SizedBox(height: 16),
                  _buildSyncSettingsCard(),
                  const SizedBox(height: 16),
                  _buildBackupHistoryCard(),
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

  Widget _buildStatusCard() {
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
                const Icon(Icons.cloud_done, color: Colors.green, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Backup Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last backup: Today at 02:00 AM',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Next backup: Tomorrow at 02:00 AM',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isBackingUp ? null : _performManualBackup,
                    icon: _isBackingUp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.backup),
                    label: Text(_isBackingUp ? 'Backing up...' : 'Backup Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSyncing ? null : _performSync,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: AppTheme.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  'Backup Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Automatic Backup',
              subtitle: 'Enable scheduled backups',
              value: _backupSettings['autoBackup'],
              onChanged: (value) => _updateSetting('autoBackup', value),
            ),
            _buildDropdownTile(
              title: 'Backup Frequency',
              subtitle: 'How often to perform backups',
              value: _backupSettings['backupFrequency'],
              items: [
                {'value': 'daily', 'label': 'Daily'},
                {'value': 'weekly', 'label': 'Weekly'},
                {'value': 'monthly', 'label': 'Monthly'},
              ],
              onChanged: (value) => _updateSetting('backupFrequency', value),
            ),
            _buildTimeTile(
              title: 'Backup Time',
              subtitle: 'When to perform automatic backups',
              value: _backupSettings['backupTime'],
              onChanged: (value) => _updateSetting('backupTime', value),
            ),
            _buildNumberTile(
              title: 'Retention Period',
              subtitle: 'Days to keep old backups',
              value: _backupSettings['retentionDays'],
              suffix: 'days',
              onChanged: (value) => _updateSetting('retentionDays', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud_sync, color: AppTheme.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  'Sync Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Cloud Sync',
              subtitle: 'Sync data to cloud storage',
              value: _backupSettings['cloudSync'],
              onChanged: (value) => _updateSetting('cloudSync', value),
            ),
            _buildSwitchTile(
              title: 'Local Backup',
              subtitle: 'Keep local backups on device',
              value: _backupSettings['localBackup'],
              onChanged: (value) => _updateSetting('localBackup', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupHistoryCard() {
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
                    'Backup History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _viewAllBackups,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._backupHistory.take(3).map((backup) => _buildBackupItem(backup)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
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
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item['value'],
                      child: Text(item['label']!),
                    ))
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required String subtitle,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showTimePicker(value, onChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  const Icon(Icons.access_time, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberTile({
    required String title,
    required String subtitle,
    required int value,
    required String suffix,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showNumberPicker(title, value, suffix, onChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value $suffix',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupItem(Map<String, dynamic> backup) {
    Color statusColor =
        backup['status'] == 'completed' ? Colors.green : Colors.red;
    IconData statusIcon =
        backup['status'] == 'completed' ? Icons.check_circle : Icons.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            backup['type'] == 'auto' ? Icons.schedule : Icons.touch_app,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      backup['date'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: backup['type'] == 'auto'
                            ? Colors.blue[100]
                            : Colors.purple[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        backup['type'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: backup['type'] == 'auto'
                              ? Colors.blue[800]
                              : Colors.purple[800],
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${backup['size']} • ${backup['location']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _updateSetting(String key, dynamic value) {
    setState(() {
      _backupSettings[key] = value;
    });
  }

  void _performManualBackup() async {
    setState(() {
      _isBackingUp = true;
    });

    try {
      await AdminApiService.triggerBackup();

      setState(() {
        _isBackingUp = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manual backup completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
// print('Backup error: $e');
      setState(() {
        _isBackingUp = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _performSync() async {
    setState(() {
      _isSyncing = true;
    });

    // TODO: Connect to backend API when available
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSyncing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data sync completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showTimePicker(
      String currentValue, ValueChanged<String> onChanged) async {
    final parts = currentValue.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time != null) {
      final formattedTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      onChanged(formattedTime);
    }
  }

  void _showNumberPicker(String title, int currentValue, String suffix,
      ValueChanged<int> onChanged) {
    final controller = TextEditingController(text: currentValue.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffix: Text(suffix),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null) {
                onChanged(value);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBackupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What gets backed up:'),
            const SizedBox(height: 8),
            const Text('• Order data and history'),
            const Text('• Product catalog'),
            const Text('• Customer information'),
            const Text('• Settings and preferences'),
            const Text('• Analytics data'),
            const SizedBox(height: 16),
            Text(
              'TODO: Connect to actual backup system',
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

  void _viewAllBackups() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Backups'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('View complete backup history and restore options'),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement full backup history screen',
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

    try {
      await AdminApiService.updateBackupSettings(_backupSettings);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
// print('Save backup settings error: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save backup settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
