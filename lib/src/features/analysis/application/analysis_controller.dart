import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_database.dart';
import '../domain/compass_reading.dart';
import '../domain/direction_engine.dart';
import '../domain/vastu_category.dart';
import '../domain/vastu_measurement.dart';
import '../data/starter_rule_repository.dart';

class AnalysisState {
  const AnalysisState({
    this.selectedCategory,
    this.heading = 146.4,
    this.accuracy = 180,
    this.quality = CompassQuality.calibrating,
    this.isTrueNorth = false,
    this.measurements = const [],
  });

  final VastuCategory? selectedCategory;
  final double heading;
  final double accuracy;
  final CompassQuality quality;
  final bool isTrueNorth;
  final List<VastuMeasurement> measurements;

  AnalysisState copyWith({
    VastuCategory? selectedCategory,
    double? heading,
    double? accuracy,
    CompassQuality? quality,
    bool? isTrueNorth,
    List<VastuMeasurement>? measurements,
  }) {
    return AnalysisState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      quality: quality ?? this.quality,
      isTrueNorth: isTrueNorth ?? this.isTrueNorth,
      measurements: measurements ?? this.measurements,
    );
  }
}

class AnalysisController extends Notifier<AnalysisState> {
  static const _rules = StarterRuleRepository();
  var _disposed = false;

  @override
  AnalysisState build() {
    ref.onDispose(() => _disposed = true);
    unawaited(_hydrate());
    return const AnalysisState();
  }

  Future<void> _hydrate() async {
    final measurements = await LocalDatabase.instance.loadMeasurements();
    if (_disposed || measurements.isEmpty) return;
    state = state.copyWith(measurements: measurements);
  }

  void selectCategory(VastuCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void updateHeading(double heading) {
    state = state.copyWith(heading: DirectionEngine.normalize(heading));
  }

  void setNorthMode({required bool trueNorth}) {
    state = state.copyWith(isTrueNorth: trueNorth);
  }

  void setQuality(CompassQuality quality, {double? accuracy}) {
    state = state.copyWith(quality: quality, accuracy: accuracy);
  }

  VastuMeasurement? capture({String? photoPath}) {
    final category = state.selectedCategory;
    if (category == null || state.quality != CompassQuality.ready) return null;

    final sector = DirectionEngine.classify(state.heading, category.scheme);
    final score = _rules.evaluate(category.id, sector.broadDirection).score;
    final measurement = VastuMeasurement(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      category: category,
      angle: state.heading,
      direction: sector.label,
      broadDirection: sector.broadDirection,
      score: score,
      rating: _ratingFor(score),
      accuracy: state.accuracy,
      capturedAt: DateTime.now(),
      isBoundaryUncertain: sector.isBoundaryUncertain(state.accuracy),
      photoPath: photoPath,
    );

    state = state.copyWith(measurements: [...state.measurements, measurement]);
    unawaited(LocalDatabase.instance.upsertMeasurement(measurement));
    return measurement;
  }

  void updateMeasurement(String id, double angle) {
    final measurements = state.measurements.map((measurement) {
      if (measurement.id != id) return measurement;
      final sector = DirectionEngine.classify(angle, measurement.category.scheme);
      final score = _rules.evaluate(
        measurement.category.id,
        sector.broadDirection,
      ).score;
      return measurement.copyWith(
        angle: DirectionEngine.normalize(angle),
        direction: sector.label,
        broadDirection: sector.broadDirection,
        score: score,
        rating: _ratingFor(score),
        isBoundaryUncertain: sector.isBoundaryUncertain(measurement.accuracy),
      );
    }).toList(growable: false);
    state = state.copyWith(measurements: measurements);
    for (final item in measurements) {
      if (item.id == id) {
        unawaited(LocalDatabase.instance.upsertMeasurement(item));
        break;
      }
    }
  }

  void removeMeasurement(String id) {
    state = state.copyWith(
      measurements: state.measurements
          .where((measurement) => measurement.id != id)
          .toList(growable: false),
    );
    unawaited(LocalDatabase.instance.deleteMeasurement(id));
  }

  void clearAnalysis() {
    state = const AnalysisState();
    unawaited(LocalDatabase.instance.clearMeasurements());
  }

  VastuRating _ratingFor(int score) {
    if (score >= 75) return VastuRating.good;
    if (score >= 60) return VastuRating.balanced;
    if (score >= 40) return VastuRating.attention;
    return VastuRating.critical;
  }
}

final analysisControllerProvider =
    NotifierProvider<AnalysisController, AnalysisState>(AnalysisController.new);
