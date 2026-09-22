import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 44,
    this.showWordmark = true,
    this.onDark = false,
  });

  final double size;
  final bool showWordmark;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final primaryText = onDark ? Colors.white : AppColors.deepNavy;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: size,
          child: CustomPaint(painter: _BrandMarkPainter(onDark: onDark)),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Vastu',
                  style: TextStyle(color: primaryText),
                ),
                const TextSpan(
                  text: 'Sign',
                  style: TextStyle(color: AppColors.gold),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: size * 0.49,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
        ],
        Semantics(label: AppConfig.appName),
      ],
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter({required this.onDark});

  final bool onDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final surface = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.deepNavy, AppColors.blue],
      ).createShader(Offset.zero & size);
    final gold = Paint()
      ..color = AppColors.lightGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, size.width * 0.035)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius * 0.96, surface);
    canvas.drawCircle(center, radius * 0.84, gold);

    for (var index = 0; index < 8; index++) {
      final angle = (index * math.pi / 4) - math.pi / 2;
      final start = center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.62;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.75;
      canvas.drawLine(start, end, gold);
    }

    final sign = Path()
      ..moveTo(size.width * 0.25, size.height * 0.34)
      ..lineTo(size.width * 0.49, size.height * 0.67)
      ..lineTo(size.width * 0.76, size.height * 0.28);
    canvas.drawPath(sign, gold..strokeWidth = size.width * 0.09);

    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.28),
      size.width * 0.055,
      Paint()..color = onDark ? Colors.white : AppColors.warmWhite,
    );
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) {
    return oldDelegate.onDark != onDark;
  }
}

