import 'package:flutter/material.dart';

import '../api/models/summary.dart';
import '../theme/tokens.dart';
import '../widgets/idea_card.dart';
import '../widgets/motion.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({
    super.key,
    required this.summary,
  });

  final SummaryItem summary;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final Set<String> _savedIdeaIds = <String>{};
  final Set<String> _likedIdeaIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final readsText = widget.summary.reads == null ? '— reads' : '${widget.summary.reads} reads';
    final author = widget.summary.author.isEmpty ? 'Unknown' : widget.summary.author;
    final borderColor = Theme.of(context).dividerColor;
    final titleTag = 'article_title_${widget.summary.id}';
    
    // Shadcn: Clean background
    final bg = Theme.of(context).scaffoldBackgroundColor;

    final slivers = <Widget>[
      SliverAppBar(
        pinned: true,
        backgroundColor: bg,
        surfaceTintColor: bg,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, size: 18),
              splashRadius: 20,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          'Reading',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTokens.textMuted),
        ),
      ),
      SliverToBoxAdapter(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTokens.p12),
                  // Title Area
                  Hero(
                    tag: titleTag,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget.summary.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.8,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.p16),
                  
                  // Metadata Row (Shadcn Badge Style)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                       _MetaBadge(
                         icon: Icons.person_outline, 
                         text: author,
                       ),
                       _MetaBadge(
                         icon: Icons.bar_chart, 
                         text: readsText,
                       ),
                       _MetaBadge(
                         icon: Icons.lightbulb_outline, 
                         text: '${widget.summary.points.length} Ideas',
                         isActive: true, // Highlight slightly
                       ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTokens.p24),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: AppTokens.p24),
                ],
              ),
            ),
          ),
        ),
      ),
    ];

    if (widget.summary.points.isEmpty) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.p16),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notes, size: 40, color: AppTokens.textMuted.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      Text(
                        'No ideas extracted yet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTokens.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.only(bottom: AppTokens.p32),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.p24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Key Takeaways',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppTokens.p16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final childCount = widget.summary.points.length * 2 - 1;
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.only(bottom: AppTokens.p32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                if (i.isOdd) return const SizedBox(height: 16);

                final index = i ~/ 2;
                final point = widget.summary.points[index];
                final ideaId = '${widget.summary.id}:$index';
                final saved = _savedIdeaIds.contains(ideaId);
                final liked = _likedIdeaIds.contains(ideaId);
                final text = _ideaText(point);

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 780),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTokens.p24),
                      child: RepaintBoundary(
                        child: IdeaCard(
                          key: ValueKey(ideaId),
                          text: text,
                          saved: saved,
                          liked: liked,
                          onShare: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Share (coming soon)')),
                            );
                          },
                          onToggleSaved: () {
                            setState(() {
                              saved ? _savedIdeaIds.remove(ideaId) : _savedIdeaIds.add(ideaId);
                            });
                          },
                          onToggleLiked: () {
                            setState(() {
                              liked ? _likedIdeaIds.remove(ideaId) : _likedIdeaIds.add(ideaId);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: childCount,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: slivers,
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.icon, required this.text, this.isActive = false});

  final IconData icon;
  final String text;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    // Shadcn Badge: Outline style
    final borderColor = Theme.of(context).dividerColor;
    final fg = isActive ? Theme.of(context).colorScheme.primary : AppTokens.textMuted;
    final bg = isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6), // Slightly squared for Shadcn look
        border: Border.all(color: isActive ? fg.withOpacity(0.3) : borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

String _ideaText(SummaryPoint point) {
  final heading = (point.heading ?? '').trim();
  final paragraph = (point.paragraph ?? '').trim();

  if (paragraph.isNotEmpty) {
    return heading.isEmpty ? paragraph : '$heading\n\n$paragraph';
  }

  if (point.bullets.isNotEmpty) {
    final bullets = point.bullets.map((b) => '• ${b.trim()}').join('\n');
    return heading.isEmpty ? bullets : '$heading\n\n$bullets';
  }

  return heading.isEmpty ? '—' : heading;
}