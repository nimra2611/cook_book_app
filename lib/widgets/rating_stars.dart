import 'package:flutter/material.dart';
import '../utils/constants.dart';


class RatingStars extends StatelessWidget {
  final int rating;
  final double size;
  final bool showValue;
  final String? ratingValue;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 14,
    this.showValue = false,
    this.ratingValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: AppColors.star,
            size: size,
          );
        }),
        if (showValue && ratingValue != null) ...[
          const SizedBox(width: 4),
          Text(
            ratingValue!,
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }
}
