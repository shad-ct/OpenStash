import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
                        if (article.ingestedAt != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text('•', style: TextStyle(color: AppTokens.textMuted)),
                          ),
                          Text(
                            _formatDate(article.ingestedAt),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTokens.textSubtle,
                            ),
                          ),
                        ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (article.points.isNotEmpty)
                              _MetaBadge(
                                icon: Icons.lightbulb_outline,
                                text: '${article.points.length} Ideas',
                              ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Share button
                            IconButton(
                              icon: const Icon(Icons.share_outlined, size: 16),
                              color: AppTokens.textMuted,
                              tooltip: 'Share',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              onPressed: () => Share.share(
                                '${article.title}\n${article.url}',
                              ),
                            ),
                            if (article.url.isNotEmpty)
                              TextButton(
                                onPressed: () => _launchUrl(article.url),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text('Read more', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    SizedBox(width: 4),
                                    Icon(Icons.open_in_new, size: 12),
                                  ],
                                ),
                              ),
                          ],
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

String _formatDate(DateTime? date) {
  if (date == null) return '';
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]}';
}

Future<void> _launchUrl(String urlString) async {
  final uri = Uri.tryParse(urlString);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}