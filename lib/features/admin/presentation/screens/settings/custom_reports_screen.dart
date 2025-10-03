import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../core/services/admin_api_service_new.dart';

class CustomReportsScreen extends StatefulWidget {
  const CustomReportsScreen({super.key});

  @override
  State<CustomReportsScreen> createState() => _CustomReportsScreenState();
}

class _CustomReportsScreenState extends State<CustomReportsScreen> {
  final bool _isLoading = false;

  // Mock data - TODO: Connect to backend when reports API is available
  final List<Map<String, dynamic>> _savedReports = [
    {
      'id': '1',
      'name': 'Monthly Sales Summary',
      'description': 'Sales performance by month',
      'type': 'sales',
      'schedule': 'monthly',
      'lastGenerated': '2024-09-01',
      'icon': Icons.trending_up,
      'color': Colors.green,
    },
    {
      'id': '2',
      'name': 'Top Products Report',
      'description': 'Best-selling products analysis',
      'type': 'products',
      'schedule': 'weekly',
      'lastGenerated': '2024-09-20',
      'icon': Icons.star,
      'color': Colors.orange,
    },
    {
      'id': '3',
      'name': 'Customer Analytics',
      'description': 'Customer behavior insights',
      'type': 'customers',
      'schedule': 'none',
      'lastGenerated': '2024-09-15',
      'icon': Icons.people,
      'color': Colors.blue,
    },
    {
      'id': '4',
      'name': 'Inventory Status',
      'description': 'Stock levels and alerts',
      'type': 'inventory',
      'schedule': 'daily',
      'lastGenerated': '2024-09-24',
      'icon': Icons.inventory,
      'color': Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> _reportTemplates = [
    {
      'id': 'sales_summary',
      'name': 'Sales Summary',
      'description': 'Revenue, orders, and trends',
      'icon': Icons.attach_money,
      'color': Colors.green,
    },
    {
      'id': 'product_performance',
      'name': 'Product Performance',
      'description': 'Best sellers and inventory',
      'icon': Icons.cake,
      'color': Colors.orange,
    },
    {
      'id': 'customer_report',
      'name': 'Customer Report',
      'description': 'Customer demographics and behavior',
      'icon': Icons.people,
      'color': Colors.blue,
    },
    {
      'id': 'financial_report',
      'name': 'Financial Report',
      'description': 'Profit, expenses, and cash flow',
      'icon': Icons.account_balance,
      'color': Colors.purple,
    },
    {
      'id': 'marketing_report',
      'name': 'Marketing Report',
      'description': 'Campaign performance and ROI',
      'icon': Icons.campaign,
      'color': Colors.red,
    },
    {
      'id': 'operational_report',
      'name': 'Operational Report',
      'description': 'Delivery, fulfillment, and efficiency',
      'icon': Icons.local_shipping,
      'color': Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Custom Reports'),
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
            onPressed: _showReportHelp,
            icon: const Icon(Icons.help_outline),
            tooltip: 'Report Help',
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
                  _buildSavedReportsCard(),
                  const SizedBox(height: 16),
                  _buildReportTemplatesCard(),
                  const SizedBox(height: 16),
                  _buildQuickInsightsCard(),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCustomReport,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Create Report'),
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
          Icon(Icons.analytics, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business Intelligence',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create custom reports tailored to your business needs and schedule automated delivery',
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

  Widget _buildSavedReportsCard() {
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
                const Icon(Icons.bookmark,
                    color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Saved Reports',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _viewAllReports,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._savedReports
                .take(3)
                .map((report) => _buildSavedReportItem(report)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTemplatesCard() {
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
                Icon(Icons.library_books,
                    color: AppTheme.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  'Report Templates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _reportTemplates.length,
              itemBuilder: (context, index) {
                final template = _reportTemplates[index];
                return _buildTemplateCard(template);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInsightsCard() {
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
                Icon(Icons.flash_on, color: AppTheme.primaryColor, size: 24),
                SizedBox(width: 12),
                Text(
                  'Quick Insights',
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
                  child: _buildQuickInsightTile(
                    'Today\'s Sales',
                    '87,500 XAF',
                    Icons.trending_up,
                    Colors.green,
                    '+12%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickInsightTile(
                    'New Orders',
                    '23',
                    Icons.shopping_cart,
                    Colors.blue,
                    '+5',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickInsightTile(
                    'Top Product',
                    'Chocolate Cake',
                    Icons.cake,
                    Colors.orange,
                    '8 sold',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickInsightTile(
                    'Avg Order',
                    '3,804 XAF',
                    Icons.receipt,
                    Colors.purple,
                    '+2%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedReportItem(Map<String, dynamic> report) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: report['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              report['icon'],
              color: report['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  report['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      report['schedule'] == 'none'
                          ? Icons.schedule_outlined
                          : Icons.schedule,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report['schedule'] == 'none'
                          ? 'Manual'
                          : 'Auto (${report['schedule']})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Last: ${report['lastGenerated']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, size: 18),
                    SizedBox(width: 8),
                    Text('Generate Now'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Report'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'schedule',
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 18),
                    SizedBox(width: 8),
                    Text('Schedule'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleReportAction(report, value),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _useTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: template['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  template['icon'],
                  color: template['color'],
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                template['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                template['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInsightTile(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _handleReportAction(Map<String, dynamic> report, String action) {
    switch (action) {
      case 'generate':
        _generateReport(report);
        break;
      case 'edit':
        _editReport(report);
        break;
      case 'schedule':
        _scheduleReport(report);
        break;
      case 'delete':
        _deleteReport(report);
        break;
    }
  }

  void _generateReport(Map<String, dynamic> report) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating report...'),
        backgroundColor: Colors.blue,
      ),
    );

    try {
      await AdminApiService.generateReport({
        'name': report['name'],
        'type': report['type'],
        'parameters': report['parameters'] ?? {},
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report "${report['name']}" generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
// print('Report generation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editReport(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${report['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit report configuration and parameters'),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement report editor UI',
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
                  content: Text('Report editor coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _scheduleReport(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule ${report['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Configure automatic report generation'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Schedule',
                border: OutlineInputBorder(),
              ),
              initialValue: report['schedule'],
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Manual Only')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (value) {},
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
                  content: Text('Report scheduled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteReport(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text('Are you sure you want to delete "${report['name']}"?'),
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
                  content: Text('Report deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _useTemplate(Map<String, dynamic> template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create ${template['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create a new report using the ${template['name']} template'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Report Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement report creation wizard',
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
                  content: Text('Report creation wizard coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createCustomReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Build a custom report from scratch'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Report Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement custom report builder',
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
                  content: Text('Custom report builder coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _viewAllReports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('View and manage all saved reports'),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement full reports management screen',
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

  void _showReportHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Help'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report Features:'),
            const SizedBox(height: 8),
            const Text('• Template-based creation'),
            const Text('• Custom report builder'),
            const Text('• Automated scheduling'),
            const Text('• Multiple export formats'),
            const Text('• Interactive visualizations'),
            const SizedBox(height: 16),
            const Text(
                'Reports can be generated manually or scheduled to run automatically at specified intervals.'),
            const SizedBox(height: 16),
            Text(
              'TODO: Connect to actual reporting system',
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
