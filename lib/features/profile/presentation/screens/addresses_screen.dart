import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/cache_service.dart';
import 'add_address_with_map_screen.dart';

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
      // Try to load from cache first
      final cachedAddresses = await CacheService.getUserAddresses();
      final cachedProfile = await CacheService.getUserProfile();

      if (cachedAddresses != null && cachedProfile != null) {
        // Use cached data
        setState(() {
          _currentUser = User.fromJson(cachedProfile);
          _addresses =
              cachedAddresses.map((json) => Address.fromJson(json)).toList();
        });
      } else {
        // Load from backend and cache
        await _fetchAddressesFromBackend();
      }
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

        // Cache the data
        await CacheService.setUserProfile(user.toJson());
        await CacheService.setUserAddresses(
            user.addresses.map((addr) => addr.toJson()).toList());

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
          _addresses = updatedUser.addresses;
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
            onPressed: () => _showDeleteDialog(index),
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
    // Navigate to a full-screen add address page instead of a dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddAddressWithMapScreen(
          initialAddress: address,
          onSave: (newAddress) async {
            Navigator.of(context).pop();
            if (address == null) {
              // Adding new address
              await _addAddress(newAddress);
            } else {
              // Editing existing address
              await _updateAddress(index!, newAddress);
            }
          },
        ),
      ),
    );
  }

  Future<void> _addAddress(Address newAddress) async {
    try {
      final addressData = newAddress.toJson();
      addressData['isDefault'] = _addresses.isEmpty; // First address is default

// print('DEBUG: Sending address data: $addressData');

      final response =
          await ApiService.post('/auth/addresses', data: addressData);

// print('DEBUG: Response status: ${response.statusCode}');
// print('DEBUG: Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          final updatedUser = User.fromJson(response.data['data']);
          await StorageService.setUserData(updatedUser.toJson());

          setState(() {
            _currentUser = updatedUser;
            _addresses = updatedUser.addresses;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Address added successfully!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        } else {
// print('DEBUG: Backend success=false: ${response.data}');
        }
      } else {
// print('DEBUG: HTTP error ${response.statusCode}');
      }
    } catch (e) {
// print('DEBUG: Exception caught: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding address: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _updateAddress(int index, Address updatedAddress) async {
    try {
      final address = _addresses[index];
      if (address.id == null) return;

      final response = await ApiService.put('/auth/addresses/${address.id}',
          data: updatedAddress.toJson());

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final updatedUser = User.fromJson(response.data['data']);
          await StorageService.setUserData(updatedUser.toJson());

          setState(() {
            _currentUser = updatedUser;
            _addresses = updatedUser.addresses;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Address updated successfully!'),
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
            content: Text('Error updating address: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
