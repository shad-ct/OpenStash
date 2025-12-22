import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class TopicTile extends StatelessWidget {
  const TopicTile({
    super.key,
    required this.topic,
    required this.onTap,
    this.selected = false,
  });

  final dynamic topic;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppTokens.accent : Colors.transparent;
    final bgColor = selected ? AppTokens.accent.withOpacity(0.15) : AppTokens.card;
    final iconColor = selected ? AppTokens.accent : Colors.white.withOpacity(0.85);
    final textStyle = selected
        ? Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTokens.accent, fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.titleMedium;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.r16),
      child: Material(
        color: bgColor,
        child: InkWell(
          onTap: onTap,
          splashColor: AppTokens.accent.withOpacity(0.10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: selected ? 2 : 0),
              borderRadius: BorderRadius.circular(AppTokens.r16),
            ),
            padding: const EdgeInsets.all(AppTokens.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(topic.icon, color: iconColor),
                const Spacer(),
                Text(
                  topic.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
