import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../core/services/admin_api_service_new.dart';

class DeliverySettingsScreen extends StatefulWidget {
  const DeliverySettingsScreen({super.key});

  @override
  State<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends State<DeliverySettingsScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _deliverySettings = {};
  List<Map<String, dynamic>> _deliveryZones = [];

  @override
  void initState() {
    super.initState();
    _loadDeliverySettings();
  }

  Future<void> _loadDeliverySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final deliveryData = await AdminApiService.getDeliverySettings();
      setState(() {
        _deliverySettings = Map<String, dynamic>.from(deliveryData);

        // Ensure workingDays is always List<String>
        if (_deliverySettings['workingDays'] != null) {
          _deliverySettings['workingDays'] =
              List<String>.from(_deliverySettings['workingDays']);
        } else {
          _deliverySettings['workingDays'] = <String>[];
        }

        _deliveryZones =
            List<Map<String, dynamic>>.from(deliveryData['zones'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
// print('Error loading delivery settings: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load delivery settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveDeliverySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dataToSave = Map<String, dynamic>.from(_deliverySettings);
      dataToSave['zones'] = _deliveryZones;

      await AdminApiService.updateDeliverySettings(dataToSave);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery settings updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
// print('Error saving delivery settings: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save delivery settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Delivery Settings'),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGeneralSettingsCard(),
                  const SizedBox(height: 16),
                  _buildDeliveryFeesCard(),
                  const SizedBox(height: 16),
                  _buildOperatingHoursCard(),
                  const SizedBox(height: 16),
                  _buildDeliveryZonesCard(),
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

  Widget _buildGeneralSettingsCard() {
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
                  'General Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Enable Delivery',
              subtitle: 'Allow customers to request delivery',
              value: _deliverySettings['deliveryEnabled'],
              onChanged: (value) => _updateSetting('deliveryEnabled', value),
            ),
            _buildSwitchTile(
              title: 'Enable Pickup',
              subtitle: 'Allow customers to pick up orders',
              value: _deliverySettings['pickupEnabled'],
              onChanged: (value) => _updateSetting('pickupEnabled', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryFeesCard() {
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
                Icon(Icons.local_shipping,
                    color: AppTheme.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  'Delivery Fees',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNumberTile(
              title: 'Free Delivery Threshold',
              subtitle: 'Orders above this amount get free delivery',
              value: _deliverySettings['freeDeliveryThreshold'],
              suffix: 'XAF',
              onChanged: (value) =>
                  _updateSetting('freeDeliveryThreshold', value),
            ),
            _buildNumberTile(
              title: 'Standard Delivery Fee',
              subtitle: 'Regular delivery charge',
              value: _deliverySettings['standardDeliveryFee'],
              suffix: 'XAF',
              onChanged: (value) =>
                  _updateSetting('standardDeliveryFee', value),
            ),
            _buildNumberTile(
              title: 'Express Delivery Fee',
              subtitle: 'Fast delivery charge',
              value: _deliverySettings['expressDeliveryFee'],
              suffix: 'XAF',
              onChanged: (value) => _updateSetting('expressDeliveryFee', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatingHoursCard() {
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
                Icon(Icons.access_time, color: AppTheme.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  'Operating Hours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeTile(
                    title: 'Opening Time',
                    value: _deliverySettings['operatingHours']['start'],
                    onChanged: (value) => _updateOperatingHour('start', value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeTile(
                    title: 'Closing Time',
                    value: _deliverySettings['operatingHours']['end'],
                    onChanged: (value) => _updateOperatingHour('end', value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Working Days',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                'monday',
                'tuesday',
                'wednesday',
                'thursday',
                'friday',
                'saturday',
                'sunday'
              ]
                  .map((day) => FilterChip(
                        label: Text(day[0].toUpperCase() + day.substring(1, 3)),
                        selected: List<String>.from(
                                _deliverySettings['workingDays'] ?? [])
                            .contains(day),
                        onSelected: (selected) =>
                            _toggleWorkingDay(day, selected),
                        selectedColor:
                            AppTheme.primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryZonesCard() {
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
                const Icon(Icons.map, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Delivery Zones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addDeliveryZone,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Zone'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._deliveryZones.map((zone) => _buildZoneTile(zone)),
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

  Widget _buildTimeTile({
    required String title,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
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
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildZoneTile(Map<String, dynamic> zone) {
    final zoneColor = _getColorFromString(zone['color'] ?? 'grey');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: zone['enabled']
            ? zoneColor.withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: zone['enabled'] ? zoneColor : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: zoneColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${zone['fee']} XAF • ${zone['radius']} km radius',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: zone['enabled'],
            onChanged: (value) => _toggleZone(zone['id'], value),
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  void _updateSetting(String key, dynamic value) async {
    setState(() {
      _deliverySettings[key] = value;
    });

    // Auto-save to backend
    await _saveDeliverySettings();
  }

  void _updateOperatingHour(String timeKey, String value) async {
    setState(() {
      _deliverySettings['operatingHours'][timeKey] = value;
    });

    // Auto-save to backend
    await _saveDeliverySettings();
  }

  void _toggleWorkingDay(String day, bool selected) async {
    setState(() {
      // Handle both List<String> and List<dynamic> cases
      final workingDaysRaw = _deliverySettings['workingDays'] ?? [];
      final workingDays = List<String>.from(workingDaysRaw);

      if (selected) {
        if (!workingDays.contains(day)) {
          workingDays.add(day);
        }
      } else {
        workingDays.remove(day);
      }

      _deliverySettings['workingDays'] = workingDays;
    });

    // Auto-save to backend
    await _saveDeliverySettings();
  }

  void _toggleZone(String zoneId, bool enabled) async {
    setState(() {
      final zone = _deliveryZones.firstWhere((z) => z['id'] == zoneId);
      zone['enabled'] = enabled;
    });

    // Auto-save to backend
    await _saveDeliverySettings();
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

  void _addDeliveryZone() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Delivery Zone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add new delivery zone configuration'),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement zone creation UI',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Zone creation coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Add'),
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
          content: Text('Delivery settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
