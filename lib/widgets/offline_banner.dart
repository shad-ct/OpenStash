import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Destructive/Warning Alert style
    // Amber or Red tint
    final color = Colors.amber[800]!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Showing saved content. Refresh happens once daily at 9:00 AM.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}