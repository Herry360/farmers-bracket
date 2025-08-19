import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FarmerInfoCard extends StatelessWidget {
  final String farmerName;
  final String farmerLocation;
  final String farmerImageUrl;

  const FarmerInfoCard({
    super.key,
    required this.farmerName,
    required this.farmerLocation,
    required this.farmerImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(farmerImageUrl),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    farmerLocation,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}