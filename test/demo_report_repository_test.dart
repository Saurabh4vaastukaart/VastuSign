import 'package:flutter_test/flutter_test.dart';
import 'package:vastusign/src/features/analysis/data/demo_categories.dart';
import 'package:vastusign/src/features/analysis/domain/vastu_measurement.dart';
import 'package:vastusign/src/features/reports/data/demo_report_repository.dart';

void main() {
  test('builds an ordered, reproducible report snapshot', () {
    final toilet = demoCategories.firstWhere((item) => item.id == 'toilet');
    final bedroom = demoCategories.firstWhere((item) => item.id == 'bedroom');
    final capturedAt = DateTime.utc(2026, 9, 14);
    final measurements = [
      VastuMeasurement(
        id: 'bedroom-1',
        category: bedroom,
        angle: 78.75,
        direction: 'E',
        broadDirection: 'E',
        score: 80,
        rating: VastuRating.good,
        accuracy: 2.5,
        capturedAt: capturedAt,
        isBoundaryUncertain: false,
      ),
      VastuMeasurement(
        id: 'toilet-1',
        category: toilet,
        angle: 11.25,
        direction: 'NNE',
        broadDirection: 'NNE',
        score: 20,
        rating: VastuRating.critical,
        accuracy: 2.5,
        capturedAt: capturedAt,
        isBoundaryUncertain: true,
      ),
    ];

    final report = const DemoReportRepository().build(measurements);

    expect(report.overallScore, 50);
    expect(report.criticalCount, 1);
    expect(report.positiveCount, 1);
    expect(report.observations.first.measurement.id, 'toilet-1');
    expect(report.observations.first.priority, 1);
    expect(report.ruleSetVersion, isNotEmpty);
    expect(report.templateVersion, isNotEmpty);
  });
}

