import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/services/admin_api_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = false;
  String _selectedPeriod = 'week'; // week, month, year

  // Analytics data
  Map<String, dynamic> _analyticsData = {
    'totalOrders': 0,
    'totalRevenue': 0.0,
    'totalCustomers': 0,
    'avgOrderValue': 0.0,
    'revenueChart': <Map<String, dynamic>>[],
    'topCakes': <Map<String, dynamic>>[],
    'ordersByStatus': <Map<String, dynamic>>[],
    'customerGrowth': <Map<String, dynamic>>[],
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get real orders data from backend
      final orders = await AdminApiService.getAllOrders();
      final dashboardData = await AdminApiService.getDashboardStats();

      // Process the orders to generate analytics
      final processedData = _processOrdersData(orders);

      setState(() {
        _analyticsData = {
          'totalOrders':
              dashboardData['totalOrders'] ?? processedData['totalOrders'],
          'totalRevenue':
              dashboardData['totalRevenue'] ?? processedData['totalRevenue'],
          'totalCustomers': dashboardData['totalCustomers'] ??
              processedData['totalCustomers'],
          'avgOrderValue': processedData['avgOrderValue'],
          'revenueChart': processedData['revenueChart'],
          'topCakes': processedData['topCakes'],
          'ordersByStatus': processedData['ordersByStatus'],
          'customerGrowth': _generateMockCustomerGrowth(), // Keep mock for now
        };
        _isLoading = false;
      });
    } catch (e) {
// print('Error loading analytics: $e');
      setState(() {
        _isLoading = false;
        // Use mock data as fallback
        _analyticsData = {
          'totalOrders': 156,
          'totalRevenue': 2450000.0,
          'totalCustomers': 89,
          'avgOrderValue': 15705.0,
          'revenueChart': _generateMockRevenueData(),
          'topCakes': _generateMockTopCakes(),
          'ordersByStatus': _generateMockOrdersByStatus(),
          'customerGrowth': _generateMockCustomerGrowth(),
        };
      });
    }
  }

  Map<String, dynamic> _processOrdersData(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'totalCustomers': 0,
        'avgOrderValue': 0.0,
        'revenueChart': [],
        'topCakes': [],
        'ordersByStatus': [],
      };
    }

    double totalRevenue = 0;
    Set<String> uniqueCustomers = {};
    Map<String, double> revenueByPeriod = {};
    Map<String, int> cakePopularity = {};
    Map<String, double> cakeRevenue = {};
    Map<String, int> statusCounts = {};

    for (var order in orders) {
      // Total revenue
      double orderTotal = (order['total'] ?? 0).toDouble();
      totalRevenue += orderTotal;

      // Unique customers
      String customerId = order['userId']?['_id'] ??
          order['guestDetails']?['email'] ??
          'guest_${order['_id']}';
      uniqueCustomers.add(customerId);

      // Revenue by period (based on selected period)
      String period = _formatOrderDateToPeriod(order['createdAt']);
      revenueByPeriod[period] = (revenueByPeriod[period] ?? 0) + orderTotal;

      // Top cakes
      List items = order['items'] ?? [];
      for (var item in items) {
        String cakeName = item['cakeStyleId']?['title'] ?? 'Unknown Cake';
        int quantity = item['quantity'] ?? 1;
        double itemRevenue =
            (item['totalPrice'] ?? item['unitPrice'] * quantity).toDouble();

        cakePopularity[cakeName] = (cakePopularity[cakeName] ?? 0) + quantity;
        cakeRevenue[cakeName] = (cakeRevenue[cakeName] ?? 0) + itemRevenue;
      }

      // Orders by status
      String status =
          _getStatusDisplayName(order['fulfillmentStatus'] ?? 'pending');
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    // Convert to chart data
    List<Map<String, dynamic>> revenueChart = revenueByPeriod.entries
        .map((e) => {'period': e.key, 'revenue': e.value.toInt()})
        .toList();
    revenueChart.sort(
        (a, b) => a['period'].toString().compareTo(b['period'].toString()));

// print('Analytics Debug - Revenue Chart Data: $revenueChart');
// print('Analytics Debug - Total Revenue: $totalRevenue');
// print('Analytics Debug - Number of orders: ${orders.length}');

    // Top 5 cakes
    List<Map<String, dynamic>> topCakes = cakePopularity.entries
        .map((e) => {
              'name': e.key,
              'orders': e.value,
              'revenue': cakeRevenue[e.key] ?? 0.0,
            })
        .toList();
    topCakes.sort((a, b) => b['orders'].compareTo(a['orders']));
    topCakes = topCakes.take(5).toList();

    // Orders by status
    List<Map<String, dynamic>> ordersByStatus = statusCounts.entries
        .map((e) => {
              'status': e.key,
              'count': e.value,
              'color': _getStatusColor(e.key),
            })
        .toList();

    return {
      'totalOrders': orders.length,
      'totalRevenue': totalRevenue,
      'totalCustomers': uniqueCustomers.length,
      'avgOrderValue': orders.isNotEmpty ? totalRevenue / orders.length : 0.0,
      'revenueChart': revenueChart,
      'topCakes': topCakes,
      'ordersByStatus': ordersByStatus,
    };
  }

  String _formatOrderDateToPeriod(dynamic dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr.toString());
      switch (_selectedPeriod) {
        case 'week':
          // Return day of week
          List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return days[date.weekday - 1];
        case 'month':
          // Return day of month
          return '${date.day}';
        case 'year':
          // Return month
          List<String> months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ];
          return months[date.month - 1];
        default:
          return date.day.toString();
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'ready':
        return 'Ready';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppTheme.successColor;
      case 'in progress':
      case 'accepted':
      case 'ready':
      case 'out for delivery':
        return AppTheme.accentColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  List<Map<String, dynamic>> _generateMockRevenueData() {
    return [
      {'period': 'Mon', 'revenue': 150000},
      {'period': 'Tue', 'revenue': 230000},
      {'period': 'Wed', 'revenue': 180000},
      {'period': 'Thu', 'revenue': 320000},
      {'period': 'Fri', 'revenue': 290000},
      {'period': 'Sat', 'revenue': 410000},
      {'period': 'Sun', 'revenue': 350000},
    ];
  }

  List<Map<String, dynamic>> _generateMockTopCakes() {
    return [
      {'name': 'Chocolate Birthday Cake', 'orders': 45, 'revenue': 675000},
      {'name': 'Vanilla Wedding Cake', 'orders': 32, 'revenue': 1440000},
      {'name': 'Strawberry Delight', 'orders': 28, 'revenue': 224000},
      {'name': 'Red Velvet Special', 'orders': 22, 'revenue': 330000},
      {'name': 'Lemon Cake', 'orders': 18, 'revenue': 144000},
    ];
  }

  List<Map<String, dynamic>> _generateMockOrdersByStatus() {
    return [
      {'status': 'Delivered', 'count': 89, 'color': AppTheme.successColor},
      {'status': 'In Progress', 'count': 23, 'color': AppTheme.accentColor},
      {'status': 'Pending', 'count': 15, 'color': AppTheme.warningColor},
      {'status': 'Cancelled', 'count': 8, 'color': AppTheme.errorColor},
    ];
  }

  List<Map<String, dynamic>> _generateMockCustomerGrowth() {
    return [
      {'month': 'Jan', 'customers': 25},
      {'month': 'Feb', 'customers': 32},
      {'month': 'Mar', 'customers': 28},
      {'month': 'Apr', 'customers': 45},
      {'month': 'May', 'customers': 52},
      {'month': 'Jun', 'customers': 67},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Selector
                    _buildPeriodSelector(),

                    const SizedBox(height: 20),

                    // Key Metrics
                    _buildKeyMetrics(),

                    const SizedBox(height: 24),

                    // Revenue Chart
                    _buildRevenueChart(),

                    const SizedBox(height: 24),

                    // Top Performing Cakes
                    _buildTopCakes(),

                    const SizedBox(height: 24),

                    // Orders by Status (Pie Chart)
                    _buildOrdersByStatus(),

                    const SizedBox(height: 24),

                    // Customer Growth
                    _buildCustomerGrowth(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: ['week', 'month', 'year'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
                _loadAnalytics();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          'Total Revenue',
          '${_analyticsData['totalRevenue'].toStringAsFixed(0)} XAF',
          Icons.attach_money,
          AppTheme.successColor,
        ),
        _buildMetricCard(
          'Total Orders',
          '${_analyticsData['totalOrders']}',
          Icons.shopping_cart,
          AppTheme.accentColor,
        ),
        _buildMetricCard(
          'Total Customers',
          '${_analyticsData['totalCustomers']}',
          Icons.people,
          AppTheme.primaryColor,
        ),
        _buildMetricCard(
          'Avg Order Value',
          '${_analyticsData['avgOrderValue'].toStringAsFixed(0)} XAF',
          Icons.trending_up,
          AppTheme.warningColor,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final data = _analyticsData['revenueChart'] as List;
                        if (value.toInt() < data.length) {
                          return Text(
                            data[value.toInt()]['period'],
                            style: const TextStyle(fontSize: 12),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: (_analyticsData['revenueChart'] as List)
                        .asMap()
                        .entries
                        .map((entry) => FlSpot(
                              entry.key.toDouble(),
                              (entry.value['revenue'])
                                  .toDouble(), // Don't divide by 1000
                            ))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.accentColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCakes() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Cakes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...(_analyticsData['topCakes'] as List).map((cake) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cake['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${cake['orders']} orders',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${cake['revenue'].toStringAsFixed(0)} XAF',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOrdersByStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Orders by Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: (_analyticsData['ordersByStatus'] as List)
                    .map((data) => PieChartSectionData(
                          value: data['count'].toDouble(),
                          title: '${data['count']}',
                          color: data['color'],
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ))
                    .toList(),
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            children: (_analyticsData['ordersByStatus'] as List)
                .map((data) => Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: data['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data['status'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerGrowth() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Growth',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 80,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final data = _analyticsData['customerGrowth'] as List;
                        if (value.toInt() < data.length) {
                          return Text(
                            data[value.toInt()]['month'],
                            style: const TextStyle(fontSize: 12),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: (_analyticsData['customerGrowth'] as List)
                    .asMap()
                    .entries
                    .map((entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value['customers'].toDouble(),
                              color: AppTheme.primaryColor,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
