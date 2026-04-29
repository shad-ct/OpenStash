import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../api/models/summary.dart';
import '../theme/tokens.dart';
import '../widgets/idea_card.dart';
import '../repositories/streak_repository.dart';
import '../repositories/library_repository.dart';

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
  final Set<int> _readIdeaIndices = <int>{};
  
  late final List<GlobalKey<IdeaCardState>> _cardKeys;
  bool _articleCompletedRecorded = false;

  @override
  void initState() {
    super.initState();
    _cardKeys = List.generate(
      widget.summary.points.length,
      (_) => GlobalKey<IdeaCardState>(),
    );
    
    _loadInitialState();
  }
  
  Future<void> _loadInitialState() async {
    final articleId = widget.summary.id;
    final prefs = await SharedPreferences.getInstance();
    final savedKey = 'read_ideas_$articleId';
    final persistedReadIds = prefs.getStringList(savedKey)?.toSet() ?? {};

    final saved = await libraryRepository.getSavedIdeaIdsForArticle(articleId);
    final liked = await libraryRepository.getLikedIdeaIdsForArticle(articleId);

    if (!mounted) return;

    // Map persisted idea IDs ("articleId:index") back to indices.
    final readIndices = <int>{};
    for (int i = 0; i < widget.summary.points.length; i++) {
      final key = '$articleId:$i';
      if (persistedReadIds.contains(key)) readIndices.add(i);
    }

    setState(() {
      _savedIdeaIds.addAll(saved);
      _likedIdeaIds.addAll(liked);
      _readIdeaIndices.addAll(readIndices);
    });

    // If all were already read, mark article completed without snackbar.
    if (_readIdeaIndices.length == widget.summary.points.length) {
      _articleCompletedRecorded = true;
    }
  }

  void _onCardRead(int index) async {
    setState(() {
      _readIdeaIndices.add(index);
    });

    // Persist to SharedPreferences.
    final ideaKey = '${widget.summary.id}:$index';
    final savedKey = 'read_ideas_${widget.summary.id}';
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(savedKey)?.toSet() ?? {};
    existing.add(ideaKey);
    await prefs.setStringList(savedKey, existing.toList());

    if (_readIdeaIndices.length == widget.summary.points.length && !_articleCompletedRecorded) {
      _articleCompletedRecorded = true;
      await streakRepository.recordArticleCompleted(DateTime.now());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Awesome! Article completed, streak updated 🔥'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Tracks the visibility fraction [0.0–1.0] of each card by its index.
  final Map<int, double> _visibilityFractions = {};
  int? _activeReadingIndex;

  void _updateActiveReading(int index, double fraction) {
    _visibilityFractions[index] = fraction;

    // Find the lowest-indexed card that is ≥60% visible and not yet read.
    int? best;
    for (final entry in _visibilityFractions.entries) {
      final i = entry.key;
      final f = entry.value;
      if (f < 0.6) continue;
      if (_readIdeaIndices.contains(i)) continue;
      if (best == null || i < best) best = i;
    }

    if (best == _activeReadingIndex) return; // No change.

    // Cancel the old active card.
    if (_activeReadingIndex != null) {
      _cardKeys[_activeReadingIndex!].currentState?.cancelReading();
    }

    _activeReadingIndex = best;

    if (best != null) {
      _cardKeys[best].currentState?.startReading();
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _toggleSaved(String ideaId, String text) async {
    final isSaved = _savedIdeaIds.contains(ideaId);
    if (isSaved) {
      await libraryRepository.removeSavedIdea(ideaId);
      setState(() {
        _savedIdeaIds.remove(ideaId);
      });
    } else {
      // For now, save to default folder. You can add a folder picker bottom sheet here later.
      final defaultFolder = await libraryRepository.getDefaultFolder();
      if (defaultFolder != null) {
        await libraryRepository.saveIdea(
          ideaId: ideaId,
          articleId: widget.summary.id,
          articleTitle: widget.summary.title,
          articleUrl: widget.summary.url,
          textContent: text,
          folderId: defaultFolder.id,
        );
        setState(() {
          _savedIdeaIds.add(ideaId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to Read Later')),
          );
        }
      }
    }
  }

  void _toggleLiked(String ideaId, String text) async {
    final isLiked = _likedIdeaIds.contains(ideaId);
    if (isLiked) {
      await libraryRepository.unlikeIdea(ideaId);
      setState(() {
        _likedIdeaIds.remove(ideaId);
      });
    } else {
      await libraryRepository.likeIdea(
        ideaId: ideaId,
        articleId: widget.summary.id,
        articleTitle: widget.summary.title,
        articleUrl: widget.summary.url,
        textContent: text,
      );
      setState(() {
        _likedIdeaIds.add(ideaId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.summary.author.isEmpty ? 'Unknown' : widget.summary.author;
    final borderColor = Theme.of(context).dividerColor;
    final titleTag = 'article_title_${widget.summary.id}';
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.p24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTokens.p12),
                  Hero(
                    tag: titleTag,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget.summary.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.8,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.p16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                       _MetaBadge(icon: Icons.person_outline, text: author),
                       _MetaBadge(
                         icon: Icons.lightbulb_outline, 
                         text: '${widget.summary.points.length} Ideas',
                         isActive: true,
                       ),
                       // Share button
                       GestureDetector(
                         onTap: () => Share.share(
                           '${widget.summary.title}\n${widget.summary.url}',
                         ),
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(6),
                             border: Border.all(color: Theme.of(context).dividerColor),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(Icons.share_outlined, size: 14, color: AppTokens.textMuted),
                               const SizedBox(width: 6),
                               Text(
                                 'Share',
                                 style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                   fontWeight: FontWeight.w500,
                                   color: AppTokens.textMuted,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.p16),
                  Divider(height: 1, color: borderColor),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: widget.summary.points.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  itemCount: widget.summary.points.length + 1, // +1 for "Read More" button
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == widget.summary.points.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchUrl(widget.summary.url),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Read full article'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTokens.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      );
                    }

                    final point = widget.summary.points[index];
                    final ideaId = '${widget.summary.id}:$index';
                    final saved = _savedIdeaIds.contains(ideaId);
                    final liked = _likedIdeaIds.contains(ideaId);
                    final text = _ideaText(point);
                    final isRead = _readIdeaIndices.contains(index);

                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 780),
                        child: VisibilityDetector(
                          key: Key(ideaId),
                          onVisibilityChanged: (info) {
                            _updateActiveReading(index, info.visibleFraction);
                          },
                          child: IdeaCard(
                            key: _cardKeys[index],
                            text: text,
                            saved: saved,
                            liked: liked,
                            initialRead: isRead,
                            onRead: () => _onCardRead(index),
                            onShare: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Share (coming soon)')),
                              );
                            },
                            onToggleSaved: () => _toggleSaved(ideaId, text),
                            onToggleLiked: () => _toggleLiked(ideaId, text),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
    final borderColor = Theme.of(context).dividerColor;
    final fg = isActive ? Theme.of(context).colorScheme.primary : AppTokens.textMuted;
    final bg = isActive ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
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