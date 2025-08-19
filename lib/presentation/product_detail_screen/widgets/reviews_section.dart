import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ReviewsSection extends StatefulWidget {
  final List<Map<String, dynamic>> reviews;
  final double averageRating;
  final int totalReviews;

  const ReviewsSection({
    super.key,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final displayReviews =
        _showAllReviews ? widget.reviews : widget.reviews.take(3).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviews Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Reviews',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: AppTheme.warningColor,
                    size: 18,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${widget.averageRating.toStringAsFixed(1)} (${widget.totalReviews})',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Reviews List
          ...displayReviews.map((review) => _buildReviewCard(context, review)),

          // Show More/Less Button
          if (widget.reviews.length > 3)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllReviews = !_showAllReviews;
                    });
                  },
                  child: Text(
                    _showAllReviews
                        ? 'Show Less Reviews'
                        : 'Show All ${widget.reviews.length} Reviews',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> review) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final reviewDate = DateTime.parse(review['date'] as String);
    final rating = review['rating'] as int;

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer Info
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                child: Center(
                  child: Text(
                    (review['customerName'] as String)[0].toUpperCase(),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['customerName'] as String,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${reviewDate.day}/${reviewDate.month}/${reviewDate.year}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating Stars
              Row(
                children: List.generate(5, (index) {
                  return CustomIconWidget(
                    iconName: index < rating ? 'star' : 'star_border',
                    color: AppTheme.warningColor,
                    size: 14,
                  );
                }),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Review Text
          Text(
            review['comment'] as String,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),

          // Helpful Button
          if (review['helpfulCount'] != null && review['helpfulCount'] > 0)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'thumb_up_outlined',
                    color: colorScheme.onSurfaceVariant,
                    size: 14,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${review['helpfulCount']} found this helpful',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
