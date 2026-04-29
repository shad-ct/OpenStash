import 'dart:ui';
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
    final bgColor = selected ? AppTokens.accent.withOpacity(0.15) : AppTokens.card.withOpacity(0.6);
    
    final iconColor = selected ? AppTokens.accent : Colors.white.withOpacity(0.9);
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: selected ? Colors.white : Colors.white.withOpacity(0.9),
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
    );
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTokens.r16),
        border: Border.all(
          color: selected ? AppTokens.accent : Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppTokens.accent.withOpacity(0.10),
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.p16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? AppTokens.accent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(topic.icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    topic.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle?.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
