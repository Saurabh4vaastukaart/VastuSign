import '../../../core/config/app_config.dart';
import '../../analysis/data/starter_rule_repository.dart';
import '../../analysis/domain/vastu_measurement.dart';
import '../domain/vastu_report.dart';

class DemoReportRepository {
  const DemoReportRepository();

  static const _rules = StarterRuleRepository();

  VastuReport build(List<VastuMeasurement> measurements) {
    final sorted = [...measurements]
      ..sort((first, second) => first.score.compareTo(second.score));
    final observations = <ReportObservation>[];

    for (var index = 0; index < sorted.length; index++) {
      final measurement = sorted[index];
      observations.add(
        ReportObservation(
          measurement: measurement,
          effects: _effectsFor(measurement),
          remedies: _remediesFor(measurement),
          priority: index + 1,
          difficulty: _difficultyFor(measurement),
          expectedBenefit: _benefitFor(measurement),
        ),
      );
    }

    final overallScore = measurements.isEmpty
        ? 0
        : (measurements
                    .map((measurement) => measurement.score)
                    .reduce((first, second) => first + second) /
                measurements.length)
            .round();

    return VastuReport(
      id: 'VS-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Vastu Self-Analysis',
      propertyLabel: 'My Property',
      generatedAt: DateTime.now(),
      overallScore: overallScore,
      observations: observations,
      ruleSetVersion: AppConfig.ruleSetVersion,
      templateVersion: AppConfig.reportTemplateVersion,
    );
  }

  List<String> _effectsFor(VastuMeasurement measurement) {
    final result = _rules.evaluate(
      measurement.category.id,
      measurement.broadDirection,
    );
    return [result.explanation, ...result.effects];
  }

  List<String> _remediesFor(VastuMeasurement measurement) {
    return _rules
        .evaluate(measurement.category.id, measurement.broadDirection)
        .remedies;
  }

  CorrectionDifficulty _difficultyFor(VastuMeasurement measurement) {
    if (measurement.rating == VastuRating.critical) {
      return CorrectionDifficulty.structural;
    }
    if (measurement.rating == VastuRating.attention) {
      return CorrectionDifficulty.moderate;
    }
    return CorrectionDifficulty.easy;
  }

  String _benefitFor(VastuMeasurement measurement) {
    return switch (measurement.rating) {
      VastuRating.critical =>
        'Prioritising this observation may reduce a major source of imbalance.',
      VastuRating.attention =>
        'A focused correction may improve stability and everyday comfort.',
      VastuRating.balanced =>
        'Small refinements may make this otherwise balanced zone more supportive.',
      VastuRating.good =>
        'Maintain the current placement and preserve its supportive qualities.',
    };
  }
}
