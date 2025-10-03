import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../core/services/admin_api_service_new.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final bool _isLoading = false;
  bool _isExporting = false;

  // Mock data - TODO: Connect to backend when export API is available
  final Map<String, bool> _selectedDataTypes = {
    'orders': true,
    'customers': true,
    'products': true,
    'payments': false,
    'analytics': false,
    'settings': false,
  };

  final Map<String, Map<String, dynamic>> _dataTypeInfo = {
    'orders': {
      'name': 'Orders',
      'description': 'All order data and history',
      'icon': Icons.shopping_bag,
      'color': Colors.blue,
      'estimatedSize': '2.5 MB',
      'recordCount': 1847,
    },
    'customers': {
      'name': 'Customers',
      'description': 'Customer profiles and contact info',
      'icon': Icons.people,
      'color': Colors.green,
      'estimatedSize': '450 KB',
      'recordCount': 324,
    },
    'products': {
      'name': 'Products',
      'description': 'Product catalog and details',
      'icon': Icons.cake,
      'color': Colors.orange,
      'estimatedSize': '1.2 MB',
      'recordCount': 89,
    },
    'payments': {
      'name': 'Payments',
      'description': 'Payment records and transactions',
      'icon': Icons.payment,
      'color': Colors.purple,
      'estimatedSize': '800 KB',
      'recordCount': 1542,
    },
    'analytics': {
      'name': 'Analytics',
      'description': 'Business metrics and reports',
      'icon': Icons.analytics,
      'color': Colors.red,
      'estimatedSize': '300 KB',
      'recordCount': 156,
    },
    'settings': {
      'name': 'Settings',
      'description': 'App configuration and preferences',
      'icon': Icons.settings,
      'color': Colors.grey,
      'estimatedSize': '50 KB',
      'recordCount': 1,
    },
  };

  String _selectedFormat = 'json';
  String _selectedDateRange = 'all';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  final List<Map<String, dynamic>> _exportHistory = [
    {
      'id': '1',
      'fileName': 'denzel_cakes_export_2024-09-24.json',
      'types': ['orders', 'customers', 'products'],
      'format': 'json',
      'size': '4.2 MB',
      'date': '2024-09-24 10:30',
      'status': 'completed',
    },
    {
      'id': '2',
      'fileName': 'denzel_cakes_orders_2024-09-20.csv',
      'types': ['orders'],
      'format': 'csv',
      'size': '2.1 MB',
      'date': '2024-09-20 15:45',
      'status': 'completed',
    },
    {
      'id': '3',
      'fileName': 'denzel_cakes_full_export_2024-09-15.xlsx',
      'types': ['orders', 'customers', 'products', 'payments'],
      'format': 'xlsx',
      'size': '5.8 MB',
      'date': '2024-09-15 09:15',
      'status': 'completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Export Data'),
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
            onPressed: _showExportInfo,
            icon: const Icon(Icons.help_outline),
            tooltip: 'Export Help',
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
                  _buildDataSelectionCard(),
                  const SizedBox(height: 16),
                  _buildExportOptionsCard(),
                  const SizedBox(height: 16),
                  _buildDateRangeCard(),
                  const SizedBox(height: 16),
                  _buildExportPreviewCard(),
                  const SizedBox(height: 16),
                  _buildExportHistoryCard(),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isExporting ? null : _startExport,
        backgroundColor: _isExporting ? Colors.grey : AppTheme.primaryColor,
        icon: _isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.download),
        label: Text(_isExporting ? 'Exporting...' : 'Export Data'),
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
                  'Export Your Data',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Download your business data in various formats for backup, analysis, or migration purposes.',
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

  Widget _buildDataSelectionCard() {
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
                Icon(Icons.data_usage, color: AppTheme.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  'Select Data to Export',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._dataTypeInfo.entries.map((entry) => _buildDataTypeToggle(
                  entry.key,
                  entry.value,
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: _selectAllDataTypes,
                  child: const Text('Select All'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _clearAllDataTypes,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptionsCard() {
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
                Icon(Icons.file_download,
                    color: AppTheme.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  'Export Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'File Format',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFormatChip('json', 'JSON', Icons.code),
                _buildFormatChip('csv', 'CSV', Icons.table_chart),
                _buildFormatChip('xlsx', 'Excel', Icons.grid_on),
                _buildFormatChip('pdf', 'PDF', Icons.picture_as_pdf),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
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
                Icon(Icons.date_range, color: AppTheme.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  'Date Range',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDateRange,
              decoration: const InputDecoration(
                labelText: 'Select Date Range',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Time')),
                DropdownMenuItem(
                    value: 'last_month', child: Text('Last Month')),
                DropdownMenuItem(
                    value: 'last_3_months', child: Text('Last 3 Months')),
                DropdownMenuItem(
                    value: 'last_6_months', child: Text('Last 6 Months')),
                DropdownMenuItem(value: 'last_year', child: Text('Last Year')),
                DropdownMenuItem(value: 'custom', child: Text('Custom Range')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDateRange = value!;
                });
              },
            ),
            if (_selectedDateRange == 'custom') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      'Start Date',
                      _customStartDate,
                      (date) => setState(() => _customStartDate = date),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      'End Date',
                      _customEndDate,
                      (date) => setState(() => _customEndDate = date),
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

  Widget _buildExportPreviewCard() {
    final selectedCount = _selectedDataTypes.values.where((v) => v).length;
    final totalSize = _calculateTotalSize();

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
                Icon(Icons.preview, color: AppTheme.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  'Export Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Data Types: $selectedCount selected'),
                  Text('Format: ${_selectedFormat.toUpperCase()}'),
                  Text('Date Range: ${_getDateRangeText()}'),
                  Text('Estimated Size: $totalSize'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportHistoryCard() {
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
                    'Recent Exports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _viewAllExports,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._exportHistory.take(3).map((export) => _buildExportItem(export)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypeToggle(String key, Map<String, dynamic> info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: info['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              info['icon'],
              color: info['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  info['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${info['recordCount']} records • ${info['estimatedSize']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: _selectedDataTypes[key],
            onChanged: (value) {
              setState(() {
                _selectedDataTypes[key] = value ?? false;
              });
            },
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(String format, String label, IconData icon) {
    final isSelected = _selectedFormat == format;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFormat = format;
          });
        }
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  Widget _buildDateField(
      String label, DateTime? value, ValueChanged<DateTime> onChanged) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value?.toString().split(' ')[0] ?? 'Select date',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportItem(Map<String, dynamic> export) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            _getFormatIcon(export['format']),
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  export['fileName'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${export['types'].length} data types • ${export['size']} • ${export['date']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _downloadExport(export),
            icon: const Icon(Icons.download, size: 20),
            tooltip: 'Download',
          ),
        ],
      ),
    );
  }

  IconData _getFormatIcon(String format) {
    switch (format.toLowerCase()) {
      case 'json':
        return Icons.code;
      case 'csv':
        return Icons.table_chart;
      case 'xlsx':
        return Icons.grid_on;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.file_download;
    }
  }

  void _selectAllDataTypes() {
    setState(() {
      _selectedDataTypes.updateAll((key, value) => true);
    });
  }

  void _clearAllDataTypes() {
    setState(() {
      _selectedDataTypes.updateAll((key, value) => false);
    });
  }

  String _calculateTotalSize() {
    double totalMB = 0;

    _selectedDataTypes.forEach((key, isSelected) {
      if (isSelected) {
        final sizeStr = _dataTypeInfo[key]!['estimatedSize'] as String;
        final sizeValue = double.tryParse(sizeStr.split(' ')[0]) ?? 0;
        final unit = sizeStr.split(' ')[1];

        if (unit == 'KB') {
          totalMB += sizeValue / 1024;
        } else if (unit == 'MB') {
          totalMB += sizeValue;
        }
      }
    });

    if (totalMB < 1) {
      return '${(totalMB * 1024).toStringAsFixed(0)} KB';
    } else {
      return '${totalMB.toStringAsFixed(1)} MB';
    }
  }

  String _getDateRangeText() {
    switch (_selectedDateRange) {
      case 'all':
        return 'All time';
      case 'last_month':
        return 'Last month';
      case 'last_3_months':
        return 'Last 3 months';
      case 'last_6_months':
        return 'Last 6 months';
      case 'last_year':
        return 'Last year';
      case 'custom':
        if (_customStartDate != null && _customEndDate != null) {
          return '${_customStartDate!.toString().split(' ')[0]} to ${_customEndDate!.toString().split(' ')[0]}';
        }
        return 'Custom range';
      default:
        return 'All time';
    }
  }

  void _startExport() async {
    final selectedCount = _selectedDataTypes.values.where((v) => v).length;

    if (selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one data type to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final selectedTypes = _selectedDataTypes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final result = await AdminApiService.exportData(selectedTypes.first);

      setState(() {
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Data export completed successfully: ${result['message'] ?? 'Export ready'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
// print('Export error: $e');
      setState(() {
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _downloadExport(Map<String, dynamic> export) {
    // TODO: Implement actual download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${export['fileName']}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showExportInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Export formats:'),
            const SizedBox(height: 8),
            const Text('• JSON: Machine-readable format'),
            const Text('• CSV: Spreadsheet compatible'),
            const Text('• Excel: Full-featured spreadsheets'),
            const Text('• PDF: Print-ready reports'),
            const SizedBox(height: 16),
            const Text(
                'All exports are securely processed and temporary files are automatically cleaned up.'),
            const SizedBox(height: 16),
            Text(
              'TODO: Connect to actual export system',
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

  void _viewAllExports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Exports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('View complete export history and manage files'),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement full export history screen',
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
}
