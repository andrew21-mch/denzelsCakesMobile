import '../models/review_model.dart';
import 'api_service.dart';

class ReviewService {
  static const String _baseUrl = '/reviews';

  /// Create a new review
  static Future<Review> createReview({
    String? orderId, // Made optional for general reviews
    required String cakeStyleId,
    required int rating,
    required String comment,
    List<String>? images,
    String reviewType = 'general', // Default to general review
  }) async {
    final response = await ApiService.post(_baseUrl, data: {
      if (orderId != null) 'orderId': orderId,
      'cakeStyleId': cakeStyleId,
      'rating': rating,
      'comment': comment,
      'images': images ?? [],
      'reviewType': reviewType,
    });

    return Review.fromJson(response.data['data']);
  }

  /// Get current user's reviews
  static Future<List<Review>> getUserReviews({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await ApiService.get(
      '$_baseUrl/my',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List<dynamic> reviewsJson = response.data['data'];
    return reviewsJson.map((json) => Review.fromJson(json)).toList();
  }

  /// Get pending reviews for current user
  static Future<List<PendingReview>> getPendingReviews() async {
    final response = await ApiService.get('$_baseUrl/pending');

    final List<dynamic> pendingJson = response.data['data'];
    return pendingJson.map((json) => PendingReview.fromJson(json)).toList();
  }

  /// Get reviews for a specific cake style
  static Future<Map<String, dynamic>> getCakeReviews(
    String cakeStyleId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await ApiService.get(
      '$_baseUrl/cake/$cakeStyleId',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data['data'];
    final List<dynamic> reviewsJson = data['reviews'];
    final reviews = reviewsJson.map((json) => Review.fromJson(json)).toList();

    return {
      'reviews': reviews,
      'averageRating': (data['averageRating'] ?? 0).toDouble(),
      'totalReviews': data['totalReviews'] ?? 0,
      'pagination': response.data['pagination'],
    };
  }

  /// Mark a review as helpful
  static Future<int> markReviewHelpful(String reviewId) async {
    final response = await ApiService.post('$_baseUrl/$reviewId/helpful');
    return response.data['data']['helpful'];
  }

  /// Update a review
  static Future<Review> updateReview(
    String reviewId, {
    int? rating,
    String? comment,
    List<String>? images,
  }) async {
    final Map<String, dynamic> data = {};
    if (rating != null) data['rating'] = rating;
    if (comment != null) data['comment'] = comment;
    if (images != null) data['images'] = images;

    final response = await ApiService.put('$_baseUrl/$reviewId', data: data);
    return Review.fromJson(response.data['data']);
  }

  /// Helper method to format rating display
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  /// Helper method to get star display
  static String getStarDisplay(int rating) {
    return '★' * rating + '☆' * (5 - rating);
  }

  /// Helper method to get rating color
  static String getRatingColor(double rating) {
    if (rating >= 4.5) return '#4CAF50'; // Green
    if (rating >= 3.5) return '#FF9800'; // Orange
    if (rating >= 2.5) return '#FFC107'; // Amber
    return '#F44336'; // Red
  }

  /// Helper method to format time ago
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Helper method to validate review data
  static String? validateReview({
    required int rating,
    required String comment,
  }) {
    if (rating < 1 || rating > 5) {
      return 'Rating must be between 1 and 5 stars';
    }

    if (comment.trim().length < 10) {
      return 'Comment must be at least 10 characters long';
    }

    if (comment.trim().length > 1000) {
      return 'Comment cannot exceed 1000 characters';
    }

    return null; // Valid
  }

  /// Helper method to get review summary text
  static String getReviewSummary(int totalReviews, double averageRating) {
    if (totalReviews == 0) {
      return 'No reviews yet';
    } else if (totalReviews == 1) {
      return '1 review • ${formatRating(averageRating)} ★';
    } else {
      return '$totalReviews reviews • ${formatRating(averageRating)} ★';
    }
  }
}
