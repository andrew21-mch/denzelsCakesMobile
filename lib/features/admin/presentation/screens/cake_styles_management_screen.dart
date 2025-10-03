import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';

class CakeStylesManagementScreen extends StatefulWidget {
  const CakeStylesManagementScreen({super.key});

  @override
  State<CakeStylesManagementScreen> createState() =>
      _CakeStylesManagementScreenState();
}

class _CakeStylesManagementScreenState
    extends State<CakeStylesManagementScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  List<Map<String, dynamic>> _cakeStyles = [];

  @override
  void initState() {
    super.initState();
    _loadCakeStyles();
  }

  Future<void> _loadCakeStyles() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _cakeStyles = [
        {
          'id': 'cake001',
          'title': 'Chocolate Deluxe',
          'description': 'Rich chocolate cake with premium cocoa',
          'basePrice': 89.99,
          'category': 'Chocolate',
          'isActive': true,
          'images': ['https://example.com/chocolate-cake.jpg'],
          'customizations': ['Size', 'Frosting', 'Message'],
          'prepTime': 120, // minutes
          'createdAt': '2025-09-20T10:00:00Z',
        },
        {
          'id': 'cake002',
          'title': 'Vanilla Classic',
          'description': 'Traditional vanilla sponge with buttercream',
          'basePrice': 69.99,
          'category': 'Vanilla',
          'isActive': true,
          'images': ['https://example.com/vanilla-cake.jpg'],
          'customizations': ['Size', 'Decoration'],
          'prepTime': 90,
          'createdAt': '2025-09-19T14:30:00Z',
        },
        {
          'id': 'cake003',
          'title': 'Red Velvet Supreme',
          'description': 'Luxurious red velvet with cream cheese frosting',
          'basePrice': 95.50,
          'category': 'Red Velvet',
          'isActive': false,
          'images': ['https://example.com/red-velvet.jpg'],
          'customizations': ['Size', 'Frosting', 'Decoration'],
          'prepTime': 150,
          'createdAt': '2025-09-18T09:15:00Z',
        },
      ];
    } catch (e) {
// print('Error loading cake styles: $e');
    }

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredCakeStyles {
    return _cakeStyles.where((cake) {
      return _searchQuery.isEmpty ||
          cake['title']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          cake['category']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Cake Styles'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCakeStyles,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search cake styles...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
            ),
          ),

          // Cake Styles List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  )
                : _filteredCakeStyles.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadCakeStyles,
                        color: AppTheme.primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredCakeStyles.length,
                          itemBuilder: (context, index) {
                            final cake = _filteredCakeStyles[index];
                            return _buildCakeCard(cake);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCakeDialog(),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.onPrimaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Cake'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cake_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No cake styles found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious cake styles to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCakeCard(Map<String, dynamic> cake) {
    final bool isActive = cake['isActive'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: AppTheme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showCakeDetails(cake),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cake['title'] ?? 'Unknown',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.successColor.withValues(alpha: 0.1)
                              : AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: isActive
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            color: AppTheme.textSecondary),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _showEditCakeDialog(cake);
                              break;
                            case 'toggle':
                              _toggleCakeStatus(cake);
                              break;
                            case 'delete':
                              _showDeleteConfirmation(cake);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: ListTile(
                              leading: Icon(isActive
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              title: Text(isActive ? 'Deactivate' : 'Activate'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete,
                                  color: AppTheme.errorColor),
                              title: Text('Delete',
                                  style: TextStyle(color: AppTheme.errorColor)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                cake['description'] ?? 'No description',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Details row
              Row(
                children: [
                  // Category
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cake['category'] ?? 'Other',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Prep time
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${cake['prepTime']} min',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Price and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(cake['basePrice'] ?? 0).toStringAsFixed(0)} XAF',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        'Edit',
                        Icons.edit,
                        AppTheme.primaryColor,
                        () => _showEditCakeDialog(cake),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        'Details',
                        Icons.visibility,
                        AppTheme.accentColor,
                        () => _showCakeDetails(cake),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppTheme.onPrimaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showCakeDetails(Map<String, dynamic> cake) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cake Details',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cake title and status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cake['title'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: (cake['isActive'] ?? false)
                                  ? AppTheme.successColor.withValues(alpha: 0.1)
                                  : AppTheme.errorColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (cake['isActive'] ?? false)
                                  ? 'Active'
                                  : 'Inactive',
                              style: TextStyle(
                                color: (cake['isActive'] ?? false)
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        cake['description'] ?? 'No description available',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Basic Information
                      _buildDetailSection(
                        'Basic Information',
                        [
                          _buildDetailRow('Category', cake['category']),
                          _buildDetailRow('Base Price',
                              '${cake['basePrice'].toStringAsFixed(0)} XAF'),
                          _buildDetailRow('Preparation Time',
                              '${cake['prepTime']} minutes'),
                          _buildDetailRow(
                              'Status',
                              (cake['isActive'] ?? false)
                                  ? 'Active'
                                  : 'Inactive'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Customizations
                      if (cake['customizations'] != null &&
                          (cake['customizations'] as List).isNotEmpty)
                        _buildDetailSection(
                          'Available Customizations',
                          [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (cake['customizations'] as List)
                                  .map<Widget>((customization) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    customization,
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCakeDialog() {
    _showCakeFormDialog(null);
  }

  void _showEditCakeDialog(Map<String, dynamic> cake) {
    _showCakeFormDialog(cake);
  }

  void _showCakeFormDialog(Map<String, dynamic>? cake) {
    final bool isEditing = cake != null;
    final titleController = TextEditingController(text: cake?['title']);
    final descriptionController =
        TextEditingController(text: cake?['description']);
    final priceController =
        TextEditingController(text: cake?['basePrice']?.toString());
    final categoryController = TextEditingController(text: cake?['category']);
    final prepTimeController =
        TextEditingController(text: cake?['prepTime']?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          isEditing ? 'Edit Cake Style' : 'Add New Cake Style',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Cake Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Base Price',
                  border: OutlineInputBorder(),
                  prefixText: 'XAF ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: prepTimeController,
                decoration: const InputDecoration(
                  labelText: 'Preparation Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveCakeStyle(
                cake,
                titleController.text,
                descriptionController.text,
                double.tryParse(priceController.text) ?? 0.0,
                categoryController.text,
                int.tryParse(prepTimeController.text) ?? 60,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
            ),
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _saveCakeStyle(
    Map<String, dynamic>? existingCake,
    String title,
    String description,
    double price,
    String category,
    int prepTime,
  ) {
    if (existingCake != null) {
      // Update existing cake
      setState(() {
        existingCake['title'] = title;
        existingCake['description'] = description;
        existingCake['basePrice'] = price;
        existingCake['category'] = category;
        existingCake['prepTime'] = prepTime;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cake style updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      // Add new cake
      final newCake = {
        'id': 'cake${_cakeStyles.length + 1}',
        'title': title,
        'description': description,
        'basePrice': price,
        'category': category,
        'isActive': true,
        'prepTime': prepTime,
        'customizations': ['Size'],
        'createdAt': DateTime.now().toIso8601String(),
      };

      setState(() {
        _cakeStyles.insert(0, newCake);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cake style added successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }

    // TODO: Make API call to save changes
  }

  void _toggleCakeStatus(Map<String, dynamic> cake) {
    setState(() {
      cake['isActive'] = !(cake['isActive'] ?? false);
    });

    final String status = cake['isActive'] ? 'activated' : 'deactivated';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cake['title']} has been $status'),
        backgroundColor: AppTheme.accentColor,
      ),
    );

    // TODO: Make API call to update status
  }

  void _showDeleteConfirmation(Map<String, dynamic> cake) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Delete Cake Style',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${cake['title']}"? This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteCakeStyle(cake);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: AppTheme.onPrimaryColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteCakeStyle(Map<String, dynamic> cake) {
    setState(() {
      _cakeStyles.remove(cake);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cake['title']} has been deleted'),
        backgroundColor: AppTheme.errorColor,
      ),
    );

    // TODO: Make API call to delete cake style
  }
}
