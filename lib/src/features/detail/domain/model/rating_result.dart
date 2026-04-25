class RatingResult {
  const RatingResult({
    required this.avgRating,
    required this.ratingCount,
    required this.userScore,
    required this.isNew,
  });

  final double avgRating;
  final int ratingCount;
  final int userScore;
  final bool isNew;

  factory RatingResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return RatingResult(
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: data['ratingCount'] as int? ?? 0,
      userScore: data['userScore'] as int? ?? 0,
      isNew: data['isNew'] as bool? ?? false,
    );
  }
}
