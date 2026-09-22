import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CompassDial extends StatelessWidget {
  const CompassDial({
    required this.heading,
    required this.direction,
    this.transparent = false,
    super.key,
  });

  final double heading;
  final String direction;
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: transparent
                    ? [Colors.transparent, Colors.black26, Colors.black45]
                    : const [Color(0xFF17465E), AppColors.deepNavy, AppColors.midnight],
                stops: [0, 0.68, 1],
              ),
              border: Border.all(color: AppColors.lightGold, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.midnight.withValues(alpha: 0.35),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
          ),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            tween: Tween(end: heading),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: -value * math.pi / 180,
                child: child,
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: CustomPaint(
                painter: _CompassFacePainter(),
                size: Size.infinite,
              ),
            ),
          ),
          Positioned(
            top: -4,
            child: ClipPath(
              clipper: _PointerClipper(),
              child: Container(
                width: 32,
                height: 34,
                color: AppColors.lightGold,
              ),
            ),
          ),
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.midnight.withValues(alpha: 0.94),
              border: Border.all(color: AppColors.gold),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${heading.toStringAsFixed(1)}°',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  direction,
                  style: const TextStyle(
                    color: AppColors.lightGold,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassFacePainter extends CustomPainter {
  const _CompassFacePainter();

  static const labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final tickPaint = Paint()
      ..color = Colors.white38
      ..strokeCap = StrokeCap.round;
    final majorPaint = Paint()
      ..color = AppColors.lightGold
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < 72; index++) {
      final angle = (index * 5 - 90) * math.pi / 180;
      final isMajor = index % 9 == 0;
      final outer = center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.96;
      final inner = center +
          Offset(math.cos(angle), math.sin(angle)) *
              radius *
              (isMajor ? 0.79 : 0.88);
      canvas.drawLine(inner, outer, isMajor ? majorPaint : tickPaint);
    }

    for (var index = 0; index < labels.length; index++) {
      final angle = (index * 45 - 90) * math.pi / 180;
      final position = center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.68;
      final painter = TextPainter(
        text: TextSpan(
          text: labels[index],
          style: TextStyle(
            color: index == 0 ? AppColors.lightGold : Colors.white70,
            fontWeight: FontWeight.w800,
            fontSize: index.isEven ? 15 : 11,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        position - Offset(painter.width / 2, painter.height / 2),
      );
    }

    final northNeedle = Path()
      ..moveTo(center.dx, center.dy - radius * 0.57)
      ..lineTo(center.dx - radius * 0.07, center.dy)
      ..lineTo(center.dx + radius * 0.07, center.dy)
      ..close();
    canvas.drawPath(northNeedle, Paint()..color = AppColors.coral);

    final southNeedle = Path()
      ..moveTo(center.dx, center.dy + radius * 0.57)
      ..lineTo(center.dx - radius * 0.07, center.dy)
      ..lineTo(center.dx + radius * 0.07, center.dy)
      ..close();
    canvas.drawPath(southNeedle, Paint()..color = Colors.white54);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PointerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
