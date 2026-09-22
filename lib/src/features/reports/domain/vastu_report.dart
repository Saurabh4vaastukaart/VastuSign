import '../../analysis/domain/vastu_measurement.dart';

enum CorrectionDifficulty { easy, moderate, structural }

class ReportObservation {
  const ReportObservation({
    required this.measurement,
    required this.effects,
    required this.remedies,
    required this.priority,
    required this.difficulty,
    required this.expectedBenefit,
  });

  final VastuMeasurement measurement;
  final List<String> effects;
  final List<String> remedies;
  final int priority;
  final CorrectionDifficulty difficulty;
  final String expectedBenefit;
}

class VastuReport {
  const VastuReport({
    required this.id,
    required this.title,
    required this.propertyLabel,
    required this.generatedAt,
    required this.overallScore,
    required this.observations,
    required this.ruleSetVersion,
    required this.templateVersion,
  });

  final String id;
  final String title;
  final String propertyLabel;
  final DateTime generatedAt;
  final int overallScore;
  final List<ReportObservation> observations;
  final String ruleSetVersion;
  final String templateVersion;

  int get criticalCount => observations
      .where((item) => item.measurement.rating == VastuRating.critical)
      .length;

  int get attentionCount => observations
      .where(
        (item) =>
            item.measurement.rating == VastuRating.attention ||
            item.measurement.rating == VastuRating.balanced,
      )
      .length;

  int get positiveCount => observations
      .where((item) => item.measurement.rating == VastuRating.good)
      .length;
}

extension CorrectionDifficultyX on CorrectionDifficulty {
  String get label => switch (this) {
        CorrectionDifficulty.easy => 'Easy',
        CorrectionDifficulty.moderate => 'Moderate',
        CorrectionDifficulty.structural => 'Structural',
      };
}

