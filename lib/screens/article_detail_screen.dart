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
import '../database/database.dart';

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
  bool _tiktokMode = false;

  @override
  void initState() {
    super.initState();
    _cardKeys = List.generate(
      widget.summary.points.length,
      (_) => GlobalKey<IdeaCardState>(),
    );
    
    _loadInitialState();
    _loadTikTokMode();
  }

  Future<void> _loadTikTokMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _tiktokMode = prefs.getBool('openstash:prefs.tiktokMode') ?? false;
      });
    }
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

  void _toggleSaved(String ideaId, String text, String? imageUrl) async {
    final isSaved = _savedIdeaIds.contains(ideaId);
    if (isSaved) {
      await libraryRepository.removeSavedIdea(ideaId);
      setState(() {
        _savedIdeaIds.remove(ideaId);
      });
      return;
    }

    // Show folder picker
    final folders = await libraryRepository.getFolders();
    if (!mounted) return;

    Folder? selectedFolder = await showModalBottomSheet<Folder>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FolderPickerSheet(folders: folders),
    );

    // If dismissed, default to "Read Later" (first default folder found)
    if (selectedFolder == null) {
      selectedFolder = await libraryRepository.getDefaultFolder();
    }

    if (selectedFolder != null) {
      await libraryRepository.saveIdea(
        ideaId: ideaId,
        articleId: widget.summary.id,
        articleTitle: widget.summary.title,
        articleUrl: widget.summary.url,
        textContent: text,
        imageUrl: imageUrl,
        folderId: selectedFolder.id,
      );
      setState(() {
        _savedIdeaIds.add(ideaId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to ${selectedFolder!.name}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleLiked(String ideaId, String text, String? imageUrl) async {
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
        imageUrl: imageUrl,
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
      extendBodyBehindAppBar: _tiktokMode,
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: _tiktokMode ? Colors.transparent : bg,
        surfaceTintColor: _tiktokMode ? Colors.transparent : bg,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _tiktokMode ? Colors.black26 : Colors.transparent,
              border: Border.all(color: _tiktokMode ? Colors.white24 : borderColor),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, size: 18, color: _tiktokMode ? Colors.white : null),
              splashRadius: 20,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: _tiktokMode ? null : Text(
          'Reading',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTokens.textMuted),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!_tiktokMode) 
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
              : _tiktokMode 
                ? _buildTikTokInsights(context)
                : _buildNormalInsights(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalInsights(BuildContext context) {
    return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 780),
                      child: Column(
                        children: [
                          ...List.generate(widget.summary.points.length, (index) {
                            final point = widget.summary.points[index];
                            final ideaId = '${widget.summary.id}:$index';
                            final saved = _savedIdeaIds.contains(ideaId);
                            final liked = _likedIdeaIds.contains(ideaId);
                            final text = _ideaText(point);
                            final isRead = _readIdeaIndices.contains(index);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
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
                                    Share.share(text);
                                  },
                                  onToggleSaved: () => _toggleSaved(ideaId, text, point.imageUrl),
                                  onToggleLiked: () => _toggleLiked(ideaId, text, point.imageUrl),
                                  imageUrl: point.imageUrl,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
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
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
  }

  Widget _buildTikTokInsights(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.summary.points.length + 2, // +1 for Header, +1 for Read more
      onPageChanged: (index) {
        if (index > 0 && index <= widget.summary.points.length) {
          _updateActiveReading(index - 1, 1.0);
        } else {
          // Cancel reading for all cards if on header or read more page
          if (_activeReadingIndex != null) {
            _cardKeys[_activeReadingIndex!].currentState?.cancelReading();
            _activeReadingIndex = null;
          }
        }
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildTikTokHeader(context);
        }
        if (index == widget.summary.points.length + 1) {
          return _buildTikTokReadMore(context);
        }

        final pointIndex = index - 1;
        final point = widget.summary.points[pointIndex];
        final ideaId = '${widget.summary.id}:$pointIndex';
        final saved = _savedIdeaIds.contains(ideaId);
        final liked = _likedIdeaIds.contains(ideaId);
        final text = _ideaText(point);
        final isRead = _readIdeaIndices.contains(pointIndex);

        return IdeaCard(
          key: _cardKeys[pointIndex],
          text: text,
          saved: saved,
          liked: liked,
          initialRead: isRead,
          isFullScreen: true,
          onRead: () => _onCardRead(pointIndex),
          onShare: () => Share.share(text),
          onToggleSaved: () => _toggleSaved(ideaId, text, point.imageUrl),
          onToggleLiked: () => _toggleLiked(ideaId, text, point.imageUrl),
          imageUrl: point.imageUrl,
        );
      },
    );
  }

  Widget _buildTikTokHeader(BuildContext context) {
    final author = widget.summary.author.isEmpty ? 'Unknown' : widget.summary.author;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTokens.accent.withOpacity(0.3),
            Colors.black,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTokens.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'FEATURED ARTICLE',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.summary.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'by $author',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 60),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppTokens.accent, size: 24),
                const SizedBox(width: 12),
                Text(
                  '${widget.summary.points.length} Key Insights',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  const Text('Swipe up to start reading', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 12),
                  const Icon(Icons.keyboard_double_arrow_up_rounded, color: Colors.white24, size: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTikTokReadMore(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: AppTokens.accent),
            const SizedBox(height: 24),
            const Text(
              'Article Completed!',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _launchUrl(widget.summary.url),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Read full article'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
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
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: fg,
              ),
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

class _FolderPickerSheet extends StatefulWidget {
  const _FolderPickerSheet({required this.folders});
  final List<Folder> folders;

  @override
  State<_FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<_FolderPickerSheet> {
  late List<Folder> _localFolders;

  @override
  void initState() {
    super.initState();
    _localFolders = List.from(widget.folders);
  }

  Future<void> _createNewFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTokens.card,
        title: const Text('New Category', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter name...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTokens.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppTokens.accent),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await libraryRepository.createFolder(name.trim());
      final updated = await libraryRepository.getFolders();
      if (mounted) {
        setState(() {
          _localFolders = updated;
        });
        // Auto-select the newly created folder (usually the last one or by name)
        final newFolder = updated.firstWhere((f) => f.name == name.trim(), orElse: () => updated.last);
        Navigator.pop(context, newFolder);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.folder_outlined, color: AppTokens.accent),
                    const SizedBox(width: 12),
                    Text(
                      'Select Category',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _createNewFolder,
                  icon: const Icon(Icons.add_circle_outline, color: AppTokens.accent),
                  tooltip: 'New Category',
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _localFolders.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    leading: const Icon(Icons.add, color: AppTokens.accent),
                    title: const Text('Create New Category', style: TextStyle(color: AppTokens.accent, fontWeight: FontWeight.w600)),
                    onTap: _createNewFolder,
                  );
                }
                final folder = _localFolders[index - 1];
                return ListTile(
                  leading: Icon(
                    folder.isDefault ? Icons.bookmark_outline : Icons.folder_open,
                    color: AppTokens.textMuted,
                  ),
                  title: Text(folder.name),
                  onTap: () => Navigator.pop(context, folder),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}