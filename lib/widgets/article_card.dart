import 'dart:ui';
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
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppTokens.r24),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppTokens.accent.withOpacity(0.15),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ArticleImage(url: article.imageUrl),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTokens.accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTokens.accent.withOpacity(0.3)),
                              ),
                              child: Text(
                                article.feedTitle ?? article.sourceDomain ?? 'Source',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTokens.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Hero(
                        tag: 'article_title_${article.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            article.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  color: Colors.white.withOpacity(0.95),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (article.author.isEmpty ? 'Unknown Author' : article.author),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTokens.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (article.ingestedAt != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(color: AppTokens.textMuted.withOpacity(0.5)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(article.ingestedAt),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTokens.textSubtle,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (article.points.isNotEmpty)
                            _MetaBadge(
                              icon: Icons.auto_awesome_rounded,
                              text: '${article.points.length} Key Insights',
                            )
                          else
                            const SizedBox.shrink(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.ios_share_rounded, size: 20),
                                color: Colors.white70,
                                tooltip: 'Share',
                                visualDensity: VisualDensity.compact,
                                onPressed: () => Share.share(
                                  '${article.title}\n${article.url}',
                                ),
                              ),
                              if (article.url.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.public_rounded, size: 20),
                                  color: Colors.white70,
                                  tooltip: 'Open in Browser',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _launchUrl(article.url),
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
      return const SizedBox.shrink();
    }

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final logicalWidth = MediaQuery.of(context).size.width;
    final cacheWidth = (logicalWidth * devicePixelRatio).clamp(360.0, 1280.0).round();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTokens.cardAlt.withOpacity(0.5),
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            u,
            fit: BoxFit.cover,
            cacheWidth: cacheWidth,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(color: Colors.black26);
            },
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          // Subtle gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTokens.card.withOpacity(0.4),
                ],
              ),
            ),
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
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