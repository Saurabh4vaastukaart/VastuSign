import 'vastu_category.dart';

enum VastuRating { good, balanced, attention, critical }

class VastuMeasurement {
  const VastuMeasurement({
    required this.id,
    required this.category,
    required this.angle,
    required this.direction,
    required this.broadDirection,
    required this.score,
    required this.rating,
    required this.accuracy,
    required this.capturedAt,
    required this.isBoundaryUncertain,
    this.photoPath,
  });

  final String id;
  final VastuCategory category;
  final double angle;
  final String direction;
  final String broadDirection;
  final int score;
  final VastuRating rating;
  final double accuracy;
  final DateTime capturedAt;
  final bool isBoundaryUncertain;
  final String? photoPath;

  VastuMeasurement copyWith({
    double? angle,
    String? direction,
    String? broadDirection,
    int? score,
    VastuRating? rating,
    bool? isBoundaryUncertain,
    String? photoPath,
  }) {
    return VastuMeasurement(
      id: id,
      category: category,
      angle: angle ?? this.angle,
      direction: direction ?? this.direction,
      broadDirection: broadDirection ?? this.broadDirection,
      score: score ?? this.score,
      rating: rating ?? this.rating,
      accuracy: accuracy,
      capturedAt: capturedAt,
      isBoundaryUncertain: isBoundaryUncertain ?? this.isBoundaryUncertain,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

extension VastuRatingX on VastuRating {
  String get label => switch (this) {
        VastuRating.good => 'Good',
        VastuRating.balanced => 'Balanced',
        VastuRating.attention => 'Needs attention',
        VastuRating.critical => 'Critical',
      };
}
