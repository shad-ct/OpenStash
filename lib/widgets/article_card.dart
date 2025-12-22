import 'package:flutter/material.dart';

import '../api/models/summary.dart';
import '../theme/tokens.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  final SummaryItem article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Shadcn: Subtle border, clean background
    final borderColor = Theme.of(context).dividerColor.withOpacity(0.5);
    final bg = Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.r12), // Slightly tighter radius
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: AppTokens.accent.withOpacity(0.05),
          highlightColor: Colors.black.withOpacity(0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              _ArticleImage(url: article.imageUrl),
              
              // Content Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meta Header
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            (article.author.isEmpty ? 'Unknown' : article.author),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTokens.textMuted,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('•', style: TextStyle(color: AppTokens.textMuted)),
                        ),
                        Flexible(
                          child: Text(
                            article.feedTitle ?? article.sourceDomain ?? 'Source',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTokens.textSubtle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Title
                    Hero(
                      tag: 'article_title_${article.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          article.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Badges (Shadcn "Outline" style)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (article.points.isNotEmpty)
                          _MetaBadge(
                            icon: Icons.lightbulb_outline,
                            text: '${article.points.length} Ideas',
                          ),
                        _MetaBadge(
                          icon: Icons.bar_chart,
                          text: _formatReads(article.reads),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleImage extends StatelessWidget {
  const _ArticleImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = url?.trim();
    if (u == null || u.isEmpty) {
      return const SizedBox.shrink(); // Collapsed if no image, or use fallback
    }

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final logicalWidth = MediaQuery.of(context).size.width;
    final cacheWidth = (logicalWidth * devicePixelRatio).clamp(360.0, 1280.0).round();
    final cacheHeight = (180 * devicePixelRatio).clamp(180.0, 720.0).round();

    return Container(
      height: 180, // Fixed height for consistency
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTokens.cardAlt.withOpacity(0.5),
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5))),
      ),
      child: Image.network(
        u,
        fit: BoxFit.cover,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(color: AppTokens.cardAlt.withOpacity(0.35));
        },
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6), // Squared corners
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTokens.textMuted),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTokens.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatReads(int? n) {
  if (n == null) return 'Unread';
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}