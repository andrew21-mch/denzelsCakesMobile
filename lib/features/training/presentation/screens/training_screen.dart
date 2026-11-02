import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/training_model.dart';
import '../../../../core/utils/shop_whatsapp.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<TrainingPeriod> _periods(AppLocalizations l10n) {
    final topics = [
      l10n.topicBakingFundamentals,
      l10n.topicCakeMixing,
      l10n.topicFrosting,
      l10n.topicPiping,
      l10n.topicFondant,
      l10n.topicCreativeDesign,
      l10n.topicWeddingCakes,
      l10n.topicBusinessSkills,
      l10n.topicFoodSafety,
      l10n.topicPortfolio,
    ];

    TrainingPeriod period(String id, String months, String range) {
      return TrainingPeriod(
        id: id,
        title: l10n.cakeDecorationMastery,
        months: months,
        description: l10n.cakeDecorationDescription,
        topics: topics,
        isCurrentPeriod: _isCurrentPeriod(range),
        status: _getPeriodStatus(range),
      );
    }

    return [
      period('q1', l10n.intakeJanuaryMarch, 'Jan-Mar'),
      period('q2', l10n.intakeAprilJune, 'Apr-Jun'),
      period('q3', l10n.intakeJulySeptember, 'Jul-Sep'),
    ];
  }

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
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'current':
        return l10n.currentlyRunning;
      case 'completed':
        return l10n.completed;
      case 'upcoming':
        return l10n.upcoming;
      default:
        return l10n.upcoming;
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
              color: AppTheme.textPrimary.withValues(alpha: 0.05),
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

                FilledButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _askAboutClass(period);
                  },
                  child: Text(AppLocalizations.of(context)!.whatsapp),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showPeriodDetails(context, period);
                  },
                  child: Text(
                    period.isCurrentPeriod
                        ? AppLocalizations.of(context)!.viewProgress
                        : AppLocalizations.of(context)!.viewDetails,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _askAboutClass(TrainingPeriod period) async {
    final l10n = AppLocalizations.of(context)!;
    final user = await AuthRepository.getCurrentUser();
    final opened = await ShopWhatsApp.open(
      ShopWhatsApp.introduce(
        l10n,
        user?.name,
        l10n.whatsappJoinTraining(period.title, period.months),
      ),
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.whatsappUnavailable(ShopWhatsApp.displayNumber)),
        ),
      );
    }
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

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _askAboutClass(period),
                  child: Text(AppLocalizations.of(context)!.whatsapp),
                ),
              ),
            ),

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
                    Text(
                      AppLocalizations.of(context)!.topicsCovered,
                      style: const TextStyle(
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
                            color: AppTheme.accentColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.shadowColor.withValues(alpha: 0.1),
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
    final periods = _periods(AppLocalizations.of(context)!);
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
                          Text(
                            AppLocalizations.of(context)!.trainingSchedule,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.masterArtOfCakeDecoration,
                            style: const TextStyle(
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
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.school_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                  itemCount: periods.length,
                  itemBuilder: (context, index) {
                    return _buildTrainingCard(periods[index], index);
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
