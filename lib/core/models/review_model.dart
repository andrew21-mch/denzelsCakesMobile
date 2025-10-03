class Review {
  final String id;
  final String userId;
  final String orderId;
  final String cakeStyleId;
  final int rating;
  final String comment;
  final List<String> images;
  final int helpful;
  final bool isVerifiedPurchase;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated fields
  final String? userName;
  final String? cakeName;
  final List<String>? cakeImages;
  final String? orderNumber;
  final DateTime? orderDate;

  const Review({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.cakeStyleId,
    required this.rating,
    required this.comment,
    required this.images,
    required this.helpful,
    required this.isVerifiedPurchase,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.cakeName,
    this.cakeImages,
    this.orderNumber,
    this.orderDate,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      userId: json['userId'] is Map ? json['userId']['_id'] : json['userId'],
      orderId:
          json['orderId'] is Map ? json['orderId']['_id'] : json['orderId'],
      cakeStyleId: json['cakeStyleId'] is Map
          ? json['cakeStyleId']['_id']
          : json['cakeStyleId'],
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      helpful: json['helpful'] ?? 0,
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userName: json['userId'] is Map ? json['userId']['name'] : null,
      cakeName:
          json['cakeStyleId'] is Map ? json['cakeStyleId']['title'] : null,
      cakeImages: json['cakeStyleId'] is Map
          ? List<String>.from(json['cakeStyleId']['images'] ?? [])
          : null,
      orderNumber:
          json['orderId'] is Map ? json['orderId']['orderNumber'] : null,
      orderDate: json['orderId'] is Map
          ? DateTime.parse(json['orderId']['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'orderId': orderId,
      'cakeStyleId': cakeStyleId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'helpful': helpful,
      'isVerifiedPurchase': isVerifiedPurchase,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? orderId,
    String? cakeStyleId,
    int? rating,
    String? comment,
    List<String>? images,
    int? helpful,
    bool? isVerifiedPurchase,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? cakeName,
    List<String>? cakeImages,
    String? orderNumber,
    DateTime? orderDate,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      cakeStyleId: cakeStyleId ?? this.cakeStyleId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      helpful: helpful ?? this.helpful,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      cakeName: cakeName ?? this.cakeName,
      cakeImages: cakeImages ?? this.cakeImages,
      orderNumber: orderNumber ?? this.orderNumber,
      orderDate: orderDate ?? this.orderDate,
    );
  }
}

class PendingReview {
  final String orderId;
  final String orderNumber;
  final DateTime orderDate;
  final String cakeStyleId;
  final String cakeName;
  final List<String> cakeImages;
  final double price;

  const PendingReview({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.cakeStyleId,
    required this.cakeName,
    required this.cakeImages,
    required this.price,
  });

  factory PendingReview.fromJson(Map<String, dynamic> json) {
    return PendingReview(
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      orderDate: DateTime.parse(json['orderDate']),
      cakeStyleId: json['cakeStyleId'] ?? '',
      cakeName: json['cakeName'] ?? '',
      cakeImages: List<String>.from(json['cakeImages'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderNumber': orderNumber,
      'orderDate': orderDate.toIso8601String(),
      'cakeStyleId': cakeStyleId,
      'cakeName': cakeName,
      'cakeImages': cakeImages,
      'price': price,
    };
  }
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }
}
