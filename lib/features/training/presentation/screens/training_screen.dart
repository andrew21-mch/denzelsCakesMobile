import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/training_model.dart';
import '../../../../shared/theme/app_theme.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample training periods data - Same training in different quarters (3 per year)
  final List<TrainingPeriod> _trainingPeriods = [
    TrainingPeriod(
      id: 'q1',
      title: 'Cake Decoration Mastery',
      months: 'January - March (Q1 Intake)',
      description: 'Complete cake decoration training program covering all essential skills from basics to advanced techniques.',
      topics: [
        'Baking Fundamentals & Techniques',
        'Cake Mixing & Preparation Methods',
        'Frosting & Icing Mastery',
        'Advanced Piping Techniques',
        'Fondant Work & Sculpting',
        'Creative Design & Decoration',
        'Wedding & Special Event Cakes',
        'Business Skills & Entrepreneurship',
        'Food Safety & Professional Standards',
        'Portfolio Development & Certification'
      ],
      isCurrentPeriod: _isCurrentPeriod('Jan-Mar'),
      status: _getPeriodStatus('Jan-Mar'),
    ),
    TrainingPeriod(
      id: 'q2',
      title: 'Cake Decoration Mastery',
      months: 'April - June (Q2 Intake)',
      description: 'Complete cake decoration training program covering all essential skills from basics to advanced techniques.',
      topics: [
        'Baking Fundamentals & Techniques',
        'Cake Mixing & Preparation Methods',
        'Frosting & Icing Mastery',
        'Advanced Piping Techniques',
        'Fondant Work & Sculpting',
        'Creative Design & Decoration',
        'Wedding & Special Event Cakes',
        'Business Skills & Entrepreneurship',
        'Food Safety & Professional Standards',
        'Portfolio Development & Certification'
      ],
      isCurrentPeriod: _isCurrentPeriod('Apr-Jun'),
      status: _getPeriodStatus('Apr-Jun'),
    ),
    TrainingPeriod(
      id: 'q3',
      title: 'Cake Decoration Mastery',
      months: 'July - September (Q3 Intake)',
      description: 'Complete cake decoration training program covering all essential skills from basics to advanced techniques.',
      topics: [
        'Baking Fundamentals & Techniques',
        'Cake Mixing & Preparation Methods',
        'Frosting & Icing Mastery',
        'Advanced Piping Techniques',
        'Fondant Work & Sculpting',
        'Creative Design & Decoration',
        'Wedding & Special Event Cakes',
        'Business Skills & Entrepreneurship',
        'Food Safety & Professional Standards',
        'Portfolio Development & Certification'
      ],
      isCurrentPeriod: _isCurrentPeriod('Jul-Sep'),
      status: _getPeriodStatus('Jul-Sep'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static bool _isCurrentPeriod(String period) {
    final now = DateTime.now();
    final month = now.month;
    
    switch (period) {
      case 'Jan-Mar':
        return month >= 1 && month <= 3;
      case 'Apr-Jun':
        return month >= 4 && month <= 6;
      case 'Jul-Sep':
        return month >= 7 && month <= 9;
      default:
        return false;
    }
  }

  static String _getPeriodStatus(String period) {
    final now = DateTime.now();
    final month = now.month;
    
    switch (period) {
      case 'Jan-Mar':
        if (month >= 1 && month <= 3) return 'current';
        if (month > 3 && month < 10) return 'completed'; // Apr-Sep
        return 'upcoming'; // Oct-Dec (next year's Jan-Mar is upcoming)
      case 'Apr-Jun':
        if (month >= 4 && month <= 6) return 'current';
        if (month > 6) return 'completed'; // Jul-Dec
        return 'upcoming'; // Jan-Mar
      case 'Jul-Sep':
        if (month >= 7 && month <= 9) return 'current';
        if (month > 9) return 'completed'; // Oct-Dec
        return 'upcoming'; // Jan-Jun
      default:
        return 'upcoming';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'current':
        return AppTheme.successColor;
      case 'completed':
        return AppTheme.primaryColor;
      case 'upcoming':
        return AppTheme.accentColor;
      default:
        return AppTheme.accentColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'current':
        return 'Currently Running';
      case 'completed':
        return 'Completed';
      case 'upcoming':
        return 'Upcoming';
      default:
        return 'Upcoming';
    }
  }

  Widget _buildTrainingCard(TrainingPeriod period, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with neutral background and status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.textPrimary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            period.title,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            period.months,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(period.status),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusText(period.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  period.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Action Button
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showPeriodDetails(context, period);
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      period.isCurrentPeriod ? 'View Progress' : 'View Details',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPeriodDetails(BuildContext context, TrainingPeriod period) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          period.months,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(period.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(period.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Topics Covered',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...period.topics.asMap().entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentColor.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowColor.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.shadowColor,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Training Schedule',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Master the art of cake decoration',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.shadowColor,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              // Training Periods List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _trainingPeriods.length,
                  itemBuilder: (context, index) {
                    return _buildTrainingCard(_trainingPeriods[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
