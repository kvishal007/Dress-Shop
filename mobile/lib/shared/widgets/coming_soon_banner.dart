import 'package:flutter/material.dart';
import 'package:smart_dress_shop_pos/core/constants/app_colors.dart';

class ComingSoonBanner extends StatelessWidget {
  final String message;

  const ComingSoonBanner({
    super.key,
    this.message = 'This module is under construction and will be available in the next release.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.amber.shade100,
      child: Row(
        children: [
          const Icon(Icons.construction, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.amber.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
