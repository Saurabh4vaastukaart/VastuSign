import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/vastu_measurement.dart';

class RatingPill extends StatelessWidget {
  const RatingPill({required this.rating, super.key, this.compact = false});

  final VastuRating rating;
  final bool compact;

  static Color colorFor(VastuRating rating) => switch (rating) {
        VastuRating.good => AppColors.emerald,
        VastuRating.balanced => AppColors.blue,
        VastuRating.attention => AppColors.amber,
        VastuRating.critical => AppColors.coral,
      };

  static IconData iconFor(VastuRating rating) => switch (rating) {
        VastuRating.good => Icons.check_circle_rounded,
        VastuRating.balanced => Icons.balance_rounded,
        VastuRating.attention => Icons.error_rounded,
        VastuRating.critical => Icons.warning_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(rating);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFor(rating), size: compact ? 13 : 15, color: color),
          SizedBox(width: compact ? 4 : 6),
          Text(
            rating.label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

