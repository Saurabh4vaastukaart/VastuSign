enum CompassQuality { unavailable, calibrating, interference, unstable, ready }

class CompassReading {
  const CompassReading({
    required this.heading,
    required this.accuracy,
    required this.quality,
    required this.isTrueNorth,
    required this.timestamp,
  });

  final double heading;
  final double accuracy;
  final CompassQuality quality;
  final bool isTrueNorth;
  final DateTime timestamp;
}

