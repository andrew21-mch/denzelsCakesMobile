import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../core/services/admin_api_service_new.dart';

class UserRolesScreen extends StatefulWidget {
  const UserRolesScreen({super.key});

  @override
  State<UserRolesScreen> createState() => _UserRolesScreenState();
}

class _UserRolesScreenState extends State<UserRolesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];

  final Map<String, Map<String, dynamic>> _roleDefinitions = {
    'admin': {
      'name': 'Administrator',
      'description': 'Full system access',
      'color': Colors.red,
      'permissions': [
        'Manage all orders',
        'Manage products',
        'Manage users',
        'View analytics',
        'System settings',
      ],
    },
    'manager': {
      'name': 'Manager',
      'description': 'Manage operations',
      'color': Colors.blue,
      'permissions': [
        'Manage orders',
        'Manage products',
        'View analytics',
        'Customer support',
      ],
    },
    'baker': {
      'name': 'Baker',
      'description': 'Production focused',
      'color': Colors.green,
      'permissions': [
        'View orders',
        'Update order status',
        'Manage products',
      ],
    },
    'support': {
      'name': 'Support',
      'description': 'Customer assistance',
      'color': Colors.orange,
      'permissions': [
        'View orders',
        'Customer support',
        'Basic analytics',
      ],
    },
    'customer': {
      'name': 'Customer',
      'description': 'Regular customer',
      'color': Colors.grey,
      'permissions': [
        'Place orders',
        'View own orders',
        'Manage profile',
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await AdminApiService.getAllUsers();
      setState(() {
        _users = users.map((user) {
          return {
            'id': user['_id'] ?? user['id'],
            'name': user['name'] ?? 'Unknown User',
            'email': user['email'] ?? '',
            'phone': user['phone'] ?? '',
            'role': user['role'] ?? 'customer',
            'status': 'active', // Backend doesn't have status field yet
            'lastActive': user['lastLoginAt'] != null
                ? _formatLastActive(user['lastLoginAt'])
                : 'Never',
            'avatar': null,
            'createdAt': user['createdAt'],
          };
        }).toList()
          // Sort users: staff first (admin, manager, baker, support), then customers last
          ..sort((a, b) {
            final staffRoles = ['admin', 'manager', 'baker', 'support'];
            final aIsStaff = staffRoles.contains(a['role']);
            final bIsStaff = staffRoles.contains(b['role']);

            // Staff users first
            if (aIsStaff && !bIsStaff) return -1;
            if (!aIsStaff && bIsStaff) return 1;

            // If both are staff, sort by role priority
            if (aIsStaff && bIsStaff) {
              final rolePriority = {
                'admin': 1,
                'manager': 2,
                'baker': 3,
                'support': 4
              };
              final aPriority = rolePriority[a['role']] ?? 5;
              final bPriority = rolePriority[b['role']] ?? 5;
              return aPriority.compareTo(bPriority);
            }

            // If both are customers, sort by name
            return (a['name'] as String).compareTo(b['name'] as String);
          });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatLastActive(dynamic lastLoginAt) {
    if (lastLoginAt == null) return 'Never';

    try {
      final date = DateTime.parse(lastLoginAt.toString());
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('User Roles'),
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
            onPressed: _showRolePermissions,
            icon: const Icon(Icons.info_outline),
            tooltip: 'View Role Permissions',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.blue[50],
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Manage user roles and permissions for your team',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return _buildUserCard(user);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInviteUser,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.person_add),
        label: const Text('Invite User'),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final roleInfo = _roleDefinitions[user['role']]!;

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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: roleInfo['color'].withValues(alpha: 0.2),
                  child: user['avatar'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            user['avatar'],
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          user['name'][0].toUpperCase(),
                          style: TextStyle(
                            color: roleInfo['color'],
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user['email'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last active: ${user['lastActive']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: roleInfo['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: roleInfo['color'].withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        roleInfo['name'],
                        style: TextStyle(
                          color: roleInfo['color'],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: user['status'] == 'active'
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user['status'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: user['status'] == 'active'
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _changeUserRole(user),
                    icon: const Icon(Icons.edit, size: 12),
                    label: const Text('Change Role',
                        style: TextStyle(fontSize: 10)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      minimumSize: const Size(0, 28),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleUserStatus(user),
                    icon: Icon(
                      user['status'] == 'active'
                          ? Icons.block
                          : Icons.check_circle,
                      size: 12,
                    ),
                    label: Text(
                        user['status'] == 'active' ? 'Deactivate' : 'Activate',
                        style: const TextStyle(fontSize: 10)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: user['status'] == 'active'
                          ? Colors.red[700]
                          : Colors.green[700],
                      side: BorderSide(
                        color: user['status'] == 'active'
                            ? Colors.red[300]!
                            : Colors.green[300]!,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      minimumSize: const Size(0, 28),
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

  void _changeUserRole(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role for ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _roleDefinitions.entries.map((entry) {
            final roleKey = entry.key;
            final roleInfo = entry.value;

            return RadioListTile<String>(
              title: Text(roleInfo['name']),
              subtitle: Text(roleInfo['description']),
              value: roleKey,
              groupValue: user['role'],
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                Navigator.of(context).pop();
                if (value != null && value != user['role']) {
                  _updateUserRole(user['id'], value);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updateUserRole(String userId, String newRole) async {
    try {
      await AdminApiService.updateUserRole(userId, newRole);

      setState(() {
        final user = _users.firstWhere((u) => u['id'] == userId);
        user['role'] = newRole;
      });

      final roleInfo = _roleDefinitions[newRole]!;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User role updated to ${roleInfo['name']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    final newStatus = user['status'] == 'active' ? 'inactive' : 'active';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('${newStatus == 'active' ? 'Activate' : 'Deactivate'} User'),
        content: Text(
          newStatus == 'active'
              ? 'Are you sure you want to activate ${user['name']}? They will regain access to the system.'
              : 'Are you sure you want to deactivate ${user['name']}? They will lose access to the system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateUserStatus(user['id'], newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == 'active' ? Colors.green : Colors.red,
            ),
            child: Text(newStatus == 'active' ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
  }

  void _updateUserStatus(String userId, String newStatus) {
    // TODO: Connect to backend API when available
    setState(() {
      final user = _users.firstWhere((u) => u['id'] == userId);
      user['status'] = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'User ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully'),
        backgroundColor: newStatus == 'active' ? Colors.green : Colors.orange,
      ),
    );
  }

  void _showRolePermissions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Role Permissions'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _roleDefinitions.length,
            itemBuilder: (context, index) {
              final entry = _roleDefinitions.entries.elementAt(index);
              final roleInfo = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: roleInfo['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            roleInfo['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        roleInfo['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            List<String>.from(roleInfo['permissions'] ?? [])
                                .map((permission) => Chip(
                                      label: Text(
                                        permission,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: roleInfo['color']
                                          .withValues(alpha: 0.1),
                                      side: BorderSide(
                                          color: roleInfo['color']
                                              .withValues(alpha: 0.3)),
                                    ))
                                .toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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

  void _showInviteUser() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'support';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: _roleDefinitions.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value['name']),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedRole = value;
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'TODO: Implement user invitation system',
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
                  content: Text('User invitation system coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
}
