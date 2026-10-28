class ReviewItem {
  final String id;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String date;
  final String title;
  final String comment;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final List<String> images;

  const ReviewItem({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.date,
    required this.title,
    required this.comment,
    this.isVerifiedPurchase = true,
    this.helpfulCount = 0,
    this.images = const [],
  });

  String get initials {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class ProductRatingSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> starDistribution;

  const ProductRatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.starDistribution,
  });

  double getPercentage(int star) {
    if (totalReviews == 0) return 0.0;
    final count = starDistribution[star] ?? 0;
    return count / totalReviews;
  }
}

/// Static mock data for CYNX KAGE product reviews UI
class ReviewMockData {
  static const ProductRatingSummary sampleSummary = ProductRatingSummary(
    averageRating: 4.8,
    totalReviews: 128,
    starDistribution: {
      5: 96,
      4: 21,
      3: 7,
      2: 3,
      1: 1,
    },
  );

  static const List<ReviewItem> sampleReviews = [
    ReviewItem(
      id: 'rev_1',
      userName: 'Arjun Varma',
      rating: 5.0,
      date: '2 days ago',
      title: 'Top-tier heavyweight denim',
      comment:
          'The acid wash treatment and distressing look even better in hand than the pictures. The fit is the ideal boxy, relaxed streetwear silhouette. Definitely my new staple piece.',
      isVerifiedPurchase: true,
      helpfulCount: 24,
    ),
    ReviewItem(
      id: 'rev_2',
      userName: 'Rhea Sengupta',
      rating: 5.0,
      date: '1 week ago',
      title: 'Unreal quality & attention to detail',
      comment:
          'Fabric thickness is premium, stitching is clean, and the hardware details feel rugged. Runs true to size for an oversized aesthetic. Arrived in 3 days!',
      isVerifiedPurchase: true,
      helpfulCount: 18,
    ),
    ReviewItem(
      id: 'rev_3',
      userName: 'Devansh K.',
      rating: 4.0,
      date: '2 weeks ago',
      title: 'Great fit, slightly stiff at first',
      comment:
          'Takes a wash or two to soften up because the cotton is seriously heavy, but after that it drapes perfectly. Color stays deep black with no bleeding.',
      isVerifiedPurchase: true,
      helpfulCount: 9,
    ),
    ReviewItem(
      id: 'rev_4',
      userName: 'Meera Kapoor',
      rating: 5.0,
      date: '3 weeks ago',
      title: 'Cynx never misses on aesthetics',
      comment:
          'Got multiple compliments the first day I wore this. The cut is modern and unique. Pairs easily with chunky sneakers and boots.',
      isVerifiedPurchase: true,
      helpfulCount: 14,
    ),
  ];
}
