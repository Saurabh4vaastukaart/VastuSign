class DirectionSector {
  const DirectionSector({
    required this.label,
    required this.broadDirection,
    required this.startAngle,
    required this.endAngle,
    required this.normalizedAngle,
    required this.distanceToBoundary,
  });

  final String label;
  final String broadDirection;
  final double startAngle;
  final double endAngle;
  final double normalizedAngle;
  final double distanceToBoundary;

  bool isBoundaryUncertain(double accuracy) => distanceToBoundary <= accuracy;
}

