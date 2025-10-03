import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> _addresses = [];
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh addresses when returning to this screen
    if (!_isLoading) {
      _loadAddresses();
    }
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First try to fetch from backend
      await _fetchAddressesFromBackend();
    } catch (e) {
// print('DEBUG: Failed to fetch from backend, trying local storage: $e');
      // Fallback to local storage
      try {
        final userData = await StorageService.getUserData();
// print('DEBUG: Loaded user data: $userData');

        if (userData != null) {
          final user = User.fromJson(userData);
// print('DEBUG: User addresses: ${user.addresses}');
          setState(() {
            _currentUser = user;
            _addresses = user.addresses;
          });
        } else {
// print('DEBUG: No user data found in storage');
          setState(() {
            _addresses = [];
          });
        }
      } catch (localError) {
// print('DEBUG: Error loading from local storage: $localError');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Error loading addresses: ${localError.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAddressesFromBackend() async {
    try {
      final response = await ApiService.get('/auth/profile');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = User.fromJson(response.data['data']);

        // Update local storage with fresh data
        await StorageService.setUserData(user.toJson());

        setState(() {
          _currentUser = user;
          _addresses = user.addresses;
        });

// print('DEBUG: Successfully fetched ${user.addresses.length} addresses from backend');
      } else {
        throw Exception('Failed to fetch user profile');
      }
    } catch (e) {
// print('DEBUG: Error fetching addresses from backend: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Delivery Addresses'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadAddresses,
            icon: const Icon(Icons.refresh, color: AppTheme.accentColor),
          ),
          IconButton(
            onPressed: () => _showAddAddressDialog(),
            icon: const Icon(Icons.add, color: AppTheme.accentColor),
          ),
        ],
      ),
      body: _addresses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return _buildAddressCard(address, index);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressDialog(),
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off_outlined,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No addresses added yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your delivery addresses to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAddressDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(color: AppTheme.accentColor, width: 2)
            : null,
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: address.isDefault
                    ? AppTheme.accentColor
                    : AppTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                address.type == 'home'
                    ? Icons.home
                    : address.type == 'work'
                        ? Icons.work
                        : Icons.location_on,
                color: address.isDefault ? Colors.white : AppTheme.accentColor,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Text(
                  address.type.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  _currentUser?.name ?? 'User',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${address.street}\n${address.city}, ${address.state} ${address.zipCode}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentUser?.phone ?? '',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleAddressAction(value, index),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                if (!address.isDefault)
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 20),
                        SizedBox(width: 8),
                        Text('Set as Default'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: AppTheme.errorColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddressAction(String action, int index) {
    HapticFeedback.lightImpact();

    switch (action) {
      case 'edit':
        _showAddAddressDialog(address: _addresses[index], index: index);
        break;
      case 'default':
        _setDefaultAddress(index);
        break;
      case 'delete':
        _showDeleteDialog(index);
        break;
    }
  }

  Future<void> _setDefaultAddress(int index) async {
    try {
      final address = _addresses[index];
      final response =
          await ApiService.put('/auth/addresses/${address.id}', data: {
        'type': address.type,
        'street': address.street,
        'city': address.city,
        'state': address.state,
        'zipCode': address.zipCode,
        'country': address.country,
        'isDefault': true,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedUser = User.fromJson(response.data['data']);
        await StorageService.setUserData(updatedUser.toJson());

        setState(() {
          _currentUser = updatedUser;
          _addresses = updatedUser.addresses ?? [];
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Default address updated'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating default address: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteAddress(index),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog({Address? address, int? index}) {
    final isEditing = address != null;
    final streetController = TextEditingController(text: address?.street ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final stateController = TextEditingController(text: address?.state ?? '');
    final zipController = TextEditingController(text: address?.zipCode ?? '');
    final countryController =
        TextEditingController(text: address?.country ?? 'CM');

    String selectedType = address?.type ?? 'home';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                isEditing ? Icons.edit_location : Icons.add_location,
                color: AppTheme.accentColor,
              ),
              const SizedBox(width: 8),
              Text(isEditing ? 'Edit Address' : 'Add New Address'),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Type Section
                  const Text(
                    'Address Type',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTypeOption(
                              'home', 'Home', Icons.home, selectedType,
                              (newType) {
                            setDialogState(() {
                              selectedType = newType;
                            });
                          }),
                        ),
                        Expanded(
                          child: _buildTypeOption(
                              'work', 'Work', Icons.work, selectedType,
                              (newType) {
                            setDialogState(() {
                              selectedType = newType;
                            });
                          }),
                        ),
                        Expanded(
                          child: _buildTypeOption(
                              'other', 'Other', Icons.location_on, selectedType,
                              (newType) {
                            setDialogState(() {
                              selectedType = newType;
                            });
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Street Address
                  const Text(
                    'Street Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: streetController,
                    decoration: InputDecoration(
                      hintText: 'Enter your street address',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // City and State
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'City',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: cityController,
                              decoration: InputDecoration(
                                hintText: 'City',
                                prefixIcon: const Icon(Icons.location_city),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppTheme.surfaceColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'State/Region',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: stateController,
                              decoration: InputDecoration(
                                hintText: 'State',
                                prefixIcon: const Icon(Icons.map),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppTheme.surfaceColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ZIP Code and Country
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ZIP/Postal Code',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: zipController,
                              decoration: InputDecoration(
                                hintText: '00237',
                                prefixIcon:
                                    const Icon(Icons.markunread_mailbox),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppTheme.surfaceColor,
                              ),
                              keyboardType: TextInputType.text,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Country',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: countryController,
                              decoration: InputDecoration(
                                hintText: 'CM',
                                prefixIcon: const Icon(Icons.flag),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppTheme.surfaceColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (_addresses.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.accentColor.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppTheme.accentColor, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This will be set as your default address',
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _saveAddress(
                isEditing: isEditing,
                address: address,
                index: index,
                type: selectedType,
                street: streetController.text,
                city: cityController.text,
                state: stateController.text,
                zipCode: zipController.text,
                country: countryController.text,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(isEditing ? Icons.update : Icons.add_location),
              label: Text(isEditing ? 'Update Address' : 'Add Address'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAddress({
    required bool isEditing,
    required Address? address,
    required int? index,
    required String type,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String country,
  }) async {
    if (street.isEmpty || city.isEmpty || state.isEmpty || zipCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      final addressData = {
        'type': type,
        'street': street,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'country': country,
        'isDefault': _addresses.isEmpty, // First address is default
      };

      final dynamic response;
      if (isEditing && address?.id != null) {
        response = await ApiService.put('/auth/addresses/${address!.id}',
            data: addressData);
      } else {
        response = await ApiService.post('/auth/addresses', data: addressData);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          final updatedUser = User.fromJson(response.data['data']);
          await StorageService.setUserData(updatedUser.toJson());

          setState(() {
            _currentUser = updatedUser;
            _addresses = updatedUser.addresses;
          });

          if (mounted) {
            Navigator.of(context).pop();
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEditing
                    ? 'Address updated successfully!'
                    : 'Address added successfully!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving address: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteAddress(int index) async {
    try {
      final address = _addresses[index];
      if (address.id == null) return;

      final response = await ApiService.delete('/auth/addresses/${address.id}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedUser = User.fromJson(response.data['data']);
        await StorageService.setUserData(updatedUser.toJson());

        setState(() {
          _currentUser = updatedUser;
          _addresses = updatedUser.addresses;
        });

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address deleted successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting address: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildTypeOption(String value, String label, IconData icon,
      String selectedType, Function(String) onTypeChanged) {
    final isSelected = selectedType == value;
    return GestureDetector(
      onTap: () {
        onTypeChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
