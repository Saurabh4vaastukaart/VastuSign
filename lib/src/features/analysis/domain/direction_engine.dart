import 'direction_sector.dart';
import 'vastu_category.dart';

abstract final class DirectionEngine {
  static const _directionLabels = <String>[
    'N',
    'NNE',
    'NE',
    'ENE',
    'E',
    'ESE',
    'SE',
    'SSE',
    'S',
    'SSW',
    'SW',
    'WSW',
    'W',
    'WNW',
    'NW',
    'NNW',
  ];

  static double normalize(double angle) {
    final normalized = angle % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  static DirectionSector classify(
    double angle,
    DirectionScheme scheme,
  ) {
    return switch (scheme) {
      DirectionScheme.directions16 => classify16(angle),
      DirectionScheme.entrance32 => classifyEntrance32(angle),
    };
  }

  static DirectionSector classify16(double angle) {
    const width = 22.5;
    final normalized = normalize(angle);
    final shifted = normalize(normalized + width / 2);
    final index = (shifted / width).floor() % 16;
    final start = normalize((index * width) - width / 2);
    final end = normalize(start + width);
    final remainder = shifted % width;

    return DirectionSector(
      label: _directionLabels[index],
      broadDirection: _directionLabels[index],
      startAngle: start,
      endAngle: end,
      normalizedAngle: normalized,
      distanceToBoundary: _distanceToBoundary(remainder, width),
    );
  }

  static DirectionSector classifyEntrance32(double angle) {
    const width = 11.25;
    const origin = 315.0;
    const groups = ['N', 'E', 'S', 'W'];
    final normalized = normalize(angle);
    final fromOrigin = normalize(normalized - origin);
    final index = (fromOrigin / width).floor() % 32;
    final groupIndex = index ~/ 8;
    final pada = (index % 8) + 1;
    final start = normalize(origin + index * width);
    final end = normalize(start + width);
    final remainder = fromOrigin % width;

    return DirectionSector(
      label: '${groups[groupIndex]}$pada',
      broadDirection: classify16(normalized).label,
      startAngle: start,
      endAngle: end,
      normalizedAngle: normalized,
      distanceToBoundary: _distanceToBoundary(remainder, width),
    );
  }

  static double _distanceToBoundary(double remainder, double width) {
    return remainder < width - remainder ? remainder : width - remainder;
  }
}

