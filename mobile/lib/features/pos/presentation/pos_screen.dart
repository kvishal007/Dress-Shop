import 'package:flutter/material.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Billing Terminal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.point_of_sale, size: 64, color: AppColors.accent),
            SizedBox(height: 16),
            Text(
              'POS Billing Engine Ready',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Phase 2 Products & Variants Foundation will connect here.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
