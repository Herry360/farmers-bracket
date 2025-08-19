import 'package:flutter/material.dart';
// ...existing code...

class FarmerGroupHeader extends StatelessWidget {
  final Map<String, dynamic> farmerGroup;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const FarmerGroupHeader({
    super.key,
    required this.farmerGroup,
    this.isExpanded = true,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Example widget tree, replace with actual UI as needed
    return ListTile(
      title: Text(farmerGroup['name'] ?? 'Farmer Group'),
      trailing: IconButton(
        icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
        onPressed: onToggle,
      ),
    );
  }
}
