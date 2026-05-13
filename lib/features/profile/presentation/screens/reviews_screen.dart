import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../core/models/review_model.dart';
import '../../../../core/services/review_service.dart';
import '../../../catalog/data/repositories/cake_repository.dart';
import '../../../catalog/data/models/cake_model.dart';
import '../../../../l10n/app_localizations.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<Review> _myReviews = [];
  List<PendingReview> _pendingReviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final results = await Future.wait([
        ReviewService.getUserReviews(),
        ReviewService.getPendingReviews(),
      ]);

      setState(() {
        _myReviews = results[0] as List<Review>;
        _pendingReviews = results[1] as List<PendingReview>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myReviews),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.accentColor,
          onTap: (index) => HapticFeedback.lightImpact(),
          tabs: [
            Tab(
              text: AppLocalizations.of(context)!.myReviewsCount(_myReviews.length),
              icon: const Icon(Icons.rate_review),
            ),
            Tab(
              text: AppLocalizations.of(context)!.pendingCount(_pendingReviews.length),
              icon: const Icon(Icons.pending_actions),
            ),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: AppLocalizations.of(context)!.loadingReviews,
        child: _error != null
            ? _buildErrorState()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildMyReviewsTab(),
                  _buildPendingReviewsTab(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showWriteGeneralReviewDialog,
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.failedToLoadReviews,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadReviews,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildMyReviewsTab() {
    if (_myReviews.isEmpty) {
      return _buildEmptyState(
        icon: Icons.rate_review_outlined,
        title: AppLocalizations.of(context)!.noReviewsYet,
        subtitle: AppLocalizations.of(context)!.reviewsWillAppearHere,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myReviews.length,
      itemBuilder: (context, index) {
        final review = _myReviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildPendingReviewsTab() {
    if (_pendingReviews.isEmpty) {
      return _buildEmptyState(
        icon: Icons.pending_actions_outlined,
        title: AppLocalizations.of(context)!.noPendingReviews,
        subtitle: AppLocalizations.of(context)!.ordersWaitingForReview,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingReviews.length,
      itemBuilder: (context, index) {
        final order = _pendingReviews[index];
        return _buildPendingReviewCard(order, index);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showReviewDetails(review as Map<String, dynamic>);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.cardShadowColor,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      review.cakeName ?? 'Unknown Cake',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  _buildStarRating(review.rating),
                ],
              ),

              const SizedBox(height: 8),

              // Comment
              Text(
                review.comment,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reviewed ${ReviewService.formatTimeAgo(review.createdAt)}',
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.thumb_up_outlined,
                        size: 16,
                        color: AppTheme.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${review.helpful} helpful',
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 12,
                        ),
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

  Widget _buildPendingReviewCard(PendingReview order, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.cakeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${order.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showWriteReviewDialog(order, index);
                },
                icon: const Icon(Icons.rate_review),
                label: Text(AppLocalizations.of(context)!.writeReview),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Ordered ${ReviewService.formatTimeAgo(order.orderDate)}',
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  void _showReviewDetails(Map<String, dynamic> review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['cakeName'],
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    _buildStarRating(review['rating']),
                    const SizedBox(height: 16),
                    Text(
                      review['comment'],
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _editReview(review);
                            },
                            child: Text(AppLocalizations.of(context)!.editReview),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(AppLocalizations.of(context)!.close),
                          ),
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
    );
  }

  void _showWriteReviewDialog(PendingReview order, int index) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${AppLocalizations.of(context)!.review} ${order.cakeName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.rating),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          rating = index + 1;
                        });
                      },
                      child: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Your review',
                    hintText: 'Tell others about your experience...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                _submitReview(order, rating, commentController.text, index);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(
      PendingReview order, int rating, String comment, int index) async {
    HapticFeedback.mediumImpact();

    try {
      // Validate review
      final validationError = ReviewService.validateReview(
        rating: rating,
        comment: comment.isEmpty ? 'Great cake!' : comment,
      );

      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Submit review to API
      final newReview = await ReviewService.createReview(
        orderId: order.orderId,
        cakeStyleId: order.cakeStyleId,
        rating: rating,
        comment: comment.isEmpty ? 'Great cake!' : comment,
      );

      // Update local state
      setState(() {
        _myReviews.insert(0, newReview);
        _pendingReviews.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reviewSubmittedSuccessfully),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.failedToSubmitReview}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editReview(Map<String, dynamic> review) {
    // Implementation for editing review
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.editReviewFeatureComingSoon),
      ),
    );
  }

  void _showWriteGeneralReviewDialog() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WriteGeneralReviewDialog(
        onReviewSubmitted: (review) {
          setState(() {
            _myReviews.insert(0, review);
          });
        },
      ),
    );
  }
}

class _WriteGeneralReviewDialog extends StatefulWidget {
  final Function(Review) onReviewSubmitted;

  const _WriteGeneralReviewDialog({
    required this.onReviewSubmitted,
  });

  @override
  State<_WriteGeneralReviewDialog> createState() => _WriteGeneralReviewDialogState();
}

class _WriteGeneralReviewDialogState extends State<_WriteGeneralReviewDialog> {
  List<CakeStyle> _cakes = [];
  CakeStyle? _selectedCake;
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isLoading = false;
  bool _loadingCakes = true;

  @override
  void initState() {
    super.initState();
    _loadCakes();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadCakes() async {
    try {
      final response = await CakeRepository.getCakes();
      setState(() {
        _cakes = response.data;
        _loadingCakes = false;
      });
    } catch (e) {
      setState(() {
        _loadingCakes = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.failedToLoadCakes}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.writeReview,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cake Selection
                  const Text(
                    'Select Cake',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  if (_loadingCakes)
                    const Center(child: CircularProgressIndicator())
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CakeStyle>(
                          value: _selectedCake,
                          hint: Text(AppLocalizations.of(context)!.chooseCakeToReview),
                          isExpanded: true,
                          items: _cakes.map((cake) {
                            return DropdownMenuItem<CakeStyle>(
                              value: cake,
                              child: Text(cake.title),
                            );
                          }).toList(),
                          onChanged: (CakeStyle? value) {
                            setState(() {
                              _selectedCake = value;
                            });
                          },
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Rating
                  Text(
                    AppLocalizations.of(context)!.rating,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        child: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Comment
                  const Text(
                    'Your Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Tell others about your experience...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedCake != null && !_isLoading ? _submitReview : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.submitReview),
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

  Future<void> _submitReview() async {
    if (_selectedCake == null) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final newReview = await ReviewService.createReview(
        cakeStyleId: _selectedCake!.id,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty 
            ? 'Great cake!' 
            : _commentController.text.trim(),
        reviewType: 'general',
      );

      widget.onReviewSubmitted(newReview);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.reviewSubmittedSuccessfully),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.failedToSubmitReview}: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
