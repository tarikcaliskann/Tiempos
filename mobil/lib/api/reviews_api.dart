import 'api_client.dart';

class ReviewDto {
  ReviewDto({
    required this.id,
    required this.exchangeRequestId,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewedUserId,
    required this.reviewedUserName,
    this.skillTitle,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  final String id;
  final String exchangeRequestId;
  final String reviewerId;
  final String reviewerName;
  final String reviewedUserId;
  final String reviewedUserName;
  final String? skillTitle;
  final int rating;
  final String? comment;
  final String createdAt;

  factory ReviewDto.fromJson(Map<String, dynamic> j) {
    return ReviewDto(
      id: '${j['id']}',
      exchangeRequestId: '${j['exchangeRequestId'] ?? ''}',
      reviewerId: '${j['reviewerId'] ?? ''}',
      reviewerName: j['reviewerName'] as String? ?? '',
      reviewedUserId: '${j['reviewedUserId'] ?? ''}',
      reviewedUserName: j['reviewedUserName'] as String? ?? '',
      skillTitle: j['skillTitle'] as String?,
      rating: (j['rating'] as num?)?.toInt() ?? 0,
      comment: j['comment'] as String?,
      createdAt: '${j['createdAt'] ?? ''}',
    );
  }
}

class UserRatingSummaryDto {
  UserRatingSummaryDto({required this.totalReviews, required this.averageRating});

  final int totalReviews;
  final double averageRating;

  factory UserRatingSummaryDto.fromJson(Map<String, dynamic> j) {
    return UserRatingSummaryDto(
      totalReviews: (j['totalReviews'] as num?)?.toInt() ?? 0,
      averageRating: (j['averageRating'] as num?)?.toDouble() ?? 0,
    );
  }
}

Future<List<ReviewDto>> fetchMyReceivedReviews(String token) async {
  final data = await apiFetch('/api/reviews/me/received', token: token);
  if (data is! List) return [];
  return data
      .whereType<Map>()
      .map((e) => ReviewDto.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Future<UserRatingSummaryDto> fetchMyRatingSummary(String token) async {
  final data = await apiFetch('/api/reviews/me/summary', token: token);
  if (data is! Map) throw StateError('Invalid summary');
  return UserRatingSummaryDto.fromJson(Map<String, dynamic>.from(data));
}

Future<List<ReviewDto>> fetchMyGivenReviews(String token) async {
  final data = await apiFetch('/api/reviews/me/given', token: token);
  if (data is! List) return [];
  return data
      .whereType<Map>()
      .map((e) => ReviewDto.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Future<UserRatingSummaryDto> fetchMyGivenRatingSummary(String token) async {
  final data = await apiFetch('/api/reviews/me/given/summary', token: token);
  if (data is! Map) throw StateError('Invalid given summary');
  return UserRatingSummaryDto.fromJson(Map<String, dynamic>.from(data));
}

Future<ReviewDto> createReview({
  required String token,
  required String exchangeRequestId,
  required int rating,
  String? comment,
}) async {
  final data = await apiFetch(
    '/api/reviews/exchange/${Uri.encodeComponent(exchangeRequestId)}',
    method: 'POST',
    body: {
      'rating': rating,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
    },
    token: token,
  );
  if (data is! Map) throw StateError('Invalid review response');
  return ReviewDto.fromJson(Map<String, dynamic>.from(data));
}
