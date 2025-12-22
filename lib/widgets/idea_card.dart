import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class IdeaCard extends StatelessWidget {
  const IdeaCard({
    super.key,
    required this.text,
    required this.saved,
    required this.liked,
    required this.onShare,
    required this.onToggleSaved,
    required this.onToggleLiked,
    this.onLongPress,
  });

  final String text;
  final bool saved;
  final bool liked;
  final VoidCallback onShare;
  final VoidCallback onToggleSaved;
  final VoidCallback onToggleLiked;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor.withOpacity(0.6);
    final bg = Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.r12),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(AppTokens.r12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote Icon (Optional styling element)
                Icon(Icons.format_quote_rounded, size: 20, color: AppTokens.textMuted.withOpacity(0.3)),
                const SizedBox(height: 8),
                
                // Text
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Actions Toolbar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _IconAction(
                      icon: Icons.ios_share,
                      isActive: false,
                      onTap: onShare,
                    ),
                    const SizedBox(width: 4),
                    _IconAction(
                      icon: saved ? Icons.bookmark : Icons.bookmark_border,
                      isActive: saved,
                      activeColor: AppTokens.accent,
                      onTap: onToggleSaved,
                    ),
                    const SizedBox(width: 4),
                    _IconAction(
                      icon: liked ? Icons.favorite : Icons.favorite_border,
                      isActive: liked,
                      activeColor: Colors.redAccent,
                      onTap: onToggleLiked,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final fg = isActive ? (activeColor ?? AppTokens.accent) : AppTokens.textMuted;
    
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      color: fg,
      style: IconButton.styleFrom(
        hoverColor: fg.withOpacity(0.05),
        highlightColor: fg.withOpacity(0.1),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(32, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}