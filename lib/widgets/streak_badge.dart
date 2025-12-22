import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({
    super.key,
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Shadcn "Secondary" or "Outline" badge style
    // Transparent bg, border, accent text
    final borderColor = AppTokens.accent.withOpacity(0.3);
    
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTokens.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(999), // Fully rounded for badges
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 14, color: AppTokens.accent),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTokens.accent, // Text matches icon
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}