import 'package:flutter/material.dart';
import 'package:denzels_cakes/shared/theme/app_theme.dart';
import 'package:denzels_cakes/core/services/admin_api_service_new.dart';
import 'package:denzels_cakes/features/admin/presentation/screens/add_cake_screen.dart';
import 'package:denzels_cakes/features/admin/presentation/screens/edit_cake_screen.dart';

class CakeManagementScreen extends StatefulWidget {
  final bool embedded;

  const CakeManagementScreen({super.key, this.embedded = false});

  @override
  State<CakeManagementScreen> createState() => _CakeManagementScreenState();
}

class _CakeManagementScreenState extends State<CakeManagementScreen> {
  List<Map<String, dynamic>> _cakes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadCakes();
  }

  Future<void> _loadCakes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cakes = await AdminApiService.getAllCakes();
      setState(() {
        _cakes = cakes;
        _isLoading = false;
      });
    } catch (e) {
// print('Error loading cakes: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load cakes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCake(String cakeId, String cakeName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cake'),
        content: Text(
            'Are you sure you want to delete "$cakeName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminApiService.deleteCake(cakeId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$cakeName deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCakes(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete cake: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleAvailability(
      String cakeId, bool currentAvailability) async {
    try {
      await AdminApiService.updateCakeAvailability(
          cakeId, !currentAvailability);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentAvailability
              ? 'Cake marked as unavailable'
              : 'Cake marked as available'),
          backgroundColor: Colors.green,
        ),
      );
      _loadCakes(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update availability: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredCakes {
    var filtered = _cakes.where((cake) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final title = cake['title']?.toString().toLowerCase() ?? '';
        final description = cake['description']?.toString().toLowerCase() ?? '';
        if (!title.contains(_searchQuery.toLowerCase()) &&
            !description.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Availability filter
      if (_selectedFilter == 'available') {
        return cake['isAvailable'] == true;
      } else if (_selectedFilter == 'unavailable') {
        return cake['isAvailable'] == false;
      }

      return true;
    }).toList();

    // Sort by creation date (newest first)
    filtered.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildEmbeddedContent();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cake Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCakes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCakeScreen()),
          );
          if (result == true) {
            _loadCakes();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        tooltip: 'Add New Cake',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmbeddedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Cake Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadCakes,
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddCakeScreen()),
                  );
                  if (result == true) {
                    _loadCakes();
                  }
                },
                tooltip: 'Add New Cake',
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildSearchAndFilters(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredCakes.isEmpty
                  ? _buildEmptyState()
                  : _buildCakesList(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search cakes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Filter chips
          Row(
            children: [
              const Text('Filter:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedFilter == 'all',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'all';
                        });
                      },
                      selectedColor:
                          AppTheme.primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.primaryColor,
                    ),
                    FilterChip(
                      label: const Text('Available'),
                      selected: _selectedFilter == 'available',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'available';
                        });
                      },
                      selectedColor: Colors.green.withValues(alpha: 0.2),
                      checkmarkColor: Colors.green,
                    ),
                    FilterChip(
                      label: const Text('Unavailable'),
                      selected: _selectedFilter == 'unavailable',
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = 'unavailable';
                        });
                      },
                      selectedColor: Colors.red.withValues(alpha: 0.2),
                      checkmarkColor: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'No cakes match your filters'
                : 'No cakes added yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'all'
                ? 'Try adjusting your search or filters'
                : 'Add your first cake to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty && _selectedFilter == 'all')
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddCakeScreen()),
                );
                if (result == true) {
                  _loadCakes();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add First Cake'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCakesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCakes.length,
      itemBuilder: (context, index) {
        final cake = _filteredCakes[index];
        return _buildCakeCard(cake);
      },
    );
  }

  Widget _buildCakeCard(Map<String, dynamic> cake) {
    final isAvailable = cake['isAvailable'] ?? false;
    final images = List<String>.from(cake['images'] ?? []);
    final basePrice = (cake['basePrice'] ?? 0).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and basic info
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              color: Colors.grey[200],
            ),
            child: Stack(
              children: [
                // Image
                if (images.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      images.first,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.cake,
                              size: 60, color: Colors.grey),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.cake, size: 60, color: Colors.grey),
                  ),

                // Availability badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isAvailable ? 'Available' : 'Unavailable',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cake['title'] ?? 'Untitled Cake',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'From \$${(basePrice / 100).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle_availability',
                          child: Row(
                            children: [
                              Icon(
                                isAvailable
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(isAvailable
                                  ? 'Mark Unavailable'
                                  : 'Mark Available'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditCakeScreen(cakeId: cake['_id']),
                              ),
                            );
                            if (result == true) {
                              _loadCakes();
                            }
                            break;
                          case 'toggle_availability':
                            _toggleAvailability(cake['_id'], isAvailable);
                            break;
                          case 'delete':
                            _deleteCake(cake['_id'], cake['title'] ?? 'cake');
                            break;
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  cake['description'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Quick stats
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.schedule,
                      label: '${cake['prepTimeMinutes'] ?? 0} min',
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      icon: Icons.people,
                      label: '${cake['servingsEstimate'] ?? 0} servings',
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      icon: Icons.palette,
                      label:
                          '${(cake['flavors'] as List?)?.length ?? 0} flavors',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
