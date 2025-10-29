import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/services/admin_api_service_new.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../widgets/stats_card.dart';
import '../widgets/recent_orders_card.dart';
import '../widgets/revenue_chart_card.dart';
import '../widgets/quick_actions_card.dart';
import 'cake_management_screen.dart';
import 'customer_management_screen.dart';
import 'orders_management_screen.dart';
import 'analytics_screen.dart';
import 'settings/business_information_screen.dart';
import 'settings/payment_methods_screen.dart';
import 'settings/delivery_settings_screen.dart';
import 'settings/user_roles_screen.dart';
import 'settings/notifications_screen.dart';
import 'settings/backup_sync_screen.dart';
import 'settings/export_data_screen.dart';
import 'settings/custom_reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Real data from API
  Map<String, dynamic> _dashboardData = {
    'totalOrders': 0,
    'totalRevenue': 0.0,
    'totalCustomers': 0,
    'pendingOrders': 0,
    'todayOrders': 0,
    'todayRevenue': 0.0,
    'popularCakes': <Map<String, dynamic>>[],
    'recentOrders': <Map<String, dynamic>>[],
  };

  List<Map<String, dynamic>> _revenueData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await AdminApiService.getDashboardStats();
      final recentOrders = await AdminApiService.getAllOrders(limit: 5);
      final allOrders =
          await AdminApiService.getAllOrders(); // Get all orders for chart data

      // Process revenue chart data
      _processRevenueChartData(allOrders);

      setState(() {
        _dashboardData = {
          'totalOrders': stats['totalOrders'] ?? 0,
          'totalRevenue': stats['totalRevenue'] ?? 0.0,
          'totalCustomers': stats['totalCustomers'] ?? 0,
          'pendingOrders': stats['pendingOrders'] ?? 0,
          'todayOrders': stats['todayOrders'] ?? 0,
          'todayRevenue': stats['todayRevenue'] ?? 0.0,
          'popularCakes': stats['popularCakes'] ?? [],
          'recentOrders': recentOrders
              .map((order) => {
                    'id': order['orderNumber'] ?? order['_id'],
                    'actualId':
                        order['_id'] ?? order['id'], // Keep actual MongoDB ID
                    'customer': order['userId']?['name'] ??
                        order['guestDetails']?['name'] ??
                        'Unknown Customer',
                    'total': (order['total'] ?? 0)
                        .toDouble(), // Convert from cents if needed
                    'status': order['fulfillmentStatus'] ?? 'pending',
                    'date':
                        order['createdAt'] ?? DateTime.now().toIso8601String(),
                  })
              .toList(),
        };
        _isLoading = false;
      });
    } catch (e) {
// print('Error loading dashboard data: $e');
      // Keep default empty values on error
      setState(() => _isLoading = false);
    }
  }

  void _processRevenueChartData(List<Map<String, dynamic>> orders) {
    Map<String, double> revenueByDay = {};

    // Get the last 7 days
    DateTime now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime date = now.subtract(Duration(days: i));
      String key = '${date.month}/${date.day}';
      revenueByDay[key] = 0.0;
    }

    // Process orders
    for (var order in orders) {
      try {
        DateTime orderDate = DateTime.parse(order['createdAt'].toString());
        String key = '${orderDate.month}/${orderDate.day}';

        // Only include orders from the last 7 days
        if (revenueByDay.containsKey(key)) {
          revenueByDay[key] =
              (revenueByDay[key] ?? 0) + (order['total'] ?? 0).toDouble();
        }
      } catch (e) {
        // Skip invalid dates
        continue;
      }
    }

    // Convert to chart data format
    _revenueData = revenueByDay.entries
        .map((entry) => {
              'date': entry.key,
              'revenue': entry.value,
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 80,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            title: const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.person, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'profile') {
                    // Navigate to profile screen
                    Navigator.of(context).pushNamed('/profile');
                  } else if (value == 'logout') {
                    await AuthRepository.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 12),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Orders'),
                Tab(text: 'Cakes'),
                Tab(text: 'Analytics'),
                Tab(text: 'Settings'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildOrdersTab(),
            _buildCakesTab(),
            _buildAnalyticsTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Admin!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.onPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here\'s what\'s happening with your business today.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onPrimaryColor.withValues(alpha: 0.9),
                        ),
                  ),
                ],
              ),
            ),

            // Stats Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio:
                  1.4, // Reduced to give more height to prevent overflow
              children: [
                StatsCard(
                  title: 'Total Orders',
                  value: _dashboardData['totalOrders'].toString(),
                  icon: Icons.shopping_bag_outlined,
                  color: AppTheme.primaryColor,
                  trend: '+12%',
                ),
                StatsCard(
                  title: 'Revenue',
                  value:
                      '${(_dashboardData['totalRevenue'] as double).toStringAsFixed(0)} XAF',
                  icon: Icons.attach_money,
                  color: AppTheme.successColor,
                  trend: '+8.5%',
                ),
                StatsCard(
                  title: 'Customers',
                  value: _dashboardData['totalCustomers'].toString(),
                  icon: Icons.people_outline,
                  color: AppTheme.accentColor,
                  trend: '+15%',
                ),
                StatsCard(
                  title: 'Pending',
                  value: _dashboardData['pendingOrders'].toString(),
                  icon: Icons.pending_actions,
                  color: AppTheme.warningColor,
                  trend: '-5%',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Revenue Chart
            RevenueChartCard(
              chartData: _revenueData,
            ),

            const SizedBox(height: 24),

            // Quick Actions
            QuickActionsCard(
              onOrdersPressed: () {
                // Switch to the Orders tab instead of navigating to a new screen
                _tabController.animateTo(1); // Index 1 is the Orders tab
              },
              onCakesPressed: () {
                // Switch to the Cakes tab
                _tabController.animateTo(2); // Index 2 is the Cakes tab
              },
              onCustomersPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CustomerManagementScreen()),
                );
              },
            ),

            const SizedBox(height: 24),

            // Recent Orders
            RecentOrdersCard(
              orders: List<Map<String, dynamic>>.from(
                  _dashboardData['recentOrders']),
              onViewAllPressed: () => _tabController.animateTo(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return const OrdersManagementScreen(embedded: true);
  }

  Widget _buildCakesTab() {
    return const CakeManagementScreen(embedded: true);
  }

  Widget _buildAnalyticsTab() {
    return const AnalyticsScreen();
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'Business Settings',
            [
              _buildSettingsItem(
                'Business Information',
                'Update store details and contact info',
                Icons.business,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BusinessInformationScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                'Payment Methods',
                'Configure payment options',
                Icons.payment,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethodsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                'Delivery Settings',
                'Manage delivery zones and fees',
                Icons.local_shipping,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeliverySettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'System Settings',
            [
              _buildSettingsItem(
                'User Roles',
                'Manage admin and staff permissions',
                Icons.admin_panel_settings,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserRolesScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                'Notifications',
                'Configure notification preferences',
                Icons.notifications,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                'Backup & Sync',
                'Data backup and synchronization',
                Icons.cloud_sync,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupSyncScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'Reports & Analytics',
            [
              _buildSettingsItem(
                'Export Data',
                'Export orders and customer data',
                Icons.download,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExportDataScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                'Custom Reports',
                'Create custom business reports',
                Icons.assessment,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomReportsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.shadowColor,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
