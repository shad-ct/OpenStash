import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/idea_card.dart';
import '../widgets/library_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _grid = false;
  int _filterIndex = 0;

  final Set<String> _savedIdeaIds = <String>{};
  final Set<String> _likedIdeaIds = <String>{};

  @override
  Widget build(BuildContext context) {
    // Intentionally empty until the backend exposes a saved-ideas endpoint.
    // Ensures no content is shown from local mocks.
    const savedIdeas = <dynamic>[];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create folder (coming soon)')),
          );
        },
        backgroundColor: AppTokens.cardAlt,
        foregroundColor: Colors.white,
        elevation: 0,
        label: const Text('+ Folder'),
        icon: const Icon(Icons.create_new_folder_outlined),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTokens.p8),
              Row(
                children: [
                  Text('Library', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    'Synced',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTokens.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.p12),
              Row(
                children: [
                  Expanded(
                    child: LibraryTile(
                      label: 'Read Later',
                      icon: Icons.bookmark_outline,
                      background: AppTokens.stashReadLaterBg,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppTokens.p12),
                  Expanded(
                    child: LibraryTile(
                      label: 'My Scanned Books',
                      icon: Icons.document_scanner_outlined,
                      background: AppTokens.stashScannedBg,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.p16),
              Row(
                children: [
                  _FilterChip(
                    label: 'Recent First',
                    selected: _filterIndex == 0,
                    onTap: () => setState(() => _filterIndex = 0),
                  ),
                  const SizedBox(width: AppTokens.p8),
                  _FilterChip(
                    label: 'Saved',
                    selected: _filterIndex == 1,
                    onTap: () => setState(() => _filterIndex = 1),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(() => _grid = !_grid),
                    icon: Icon(_grid ? Icons.view_agenda_outlined : Icons.grid_view_outlined),
                    splashRadius: 22,
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.p12),
              Expanded(
                child: _grid
                    ? GridView.builder(
                        key: const PageStorageKey('library_grid'),
                        padding: const EdgeInsets.only(bottom: 96),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppTokens.p12,
                          crossAxisSpacing: AppTokens.p12,
                          childAspectRatio: 0.92,
                        ),
                        itemCount: savedIdeas.length,
                        itemBuilder: (context, index) {
                          final idea = savedIdeas[index];
                          final saved = _savedIdeaIds.contains(idea.id);
                          final liked = _likedIdeaIds.contains(idea.id);
                          return IdeaCard(
                            text: idea.text,
                            saved: saved,
                            liked: liked,
                            onShare: () {},
                            onToggleSaved: () => setState(() {
                              saved ? _savedIdeaIds.remove(idea.id) : _savedIdeaIds.add(idea.id);
                            }),
                            onToggleLiked: () => setState(() {
                              liked ? _likedIdeaIds.remove(idea.id) : _likedIdeaIds.add(idea.id);
                            }),
                            onLongPress: () => _showMoveSheet(context),
                          );
                        },
                      )
                    : ListView.separated(
                        key: const PageStorageKey('library_list'),
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: savedIdeas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppTokens.p12),
                        itemBuilder: (context, index) {
                          final idea = savedIdeas[index];
                          final saved = _savedIdeaIds.contains(idea.id);
                          final liked = _likedIdeaIds.contains(idea.id);
                          return IdeaCard(
                            text: idea.text,
                            saved: saved,
                            liked: liked,
                            onShare: () {},
                            onToggleSaved: () => setState(() {
                              saved ? _savedIdeaIds.remove(idea.id) : _savedIdeaIds.add(idea.id);
                            }),
                            onToggleLiked: () => setState(() {
                              liked ? _likedIdeaIds.remove(idea.id) : _likedIdeaIds.add(idea.id);
                            }),
                            onLongPress: () => _showMoveSheet(context),
                          );
                        },
                      ),
              ),
              if (savedIdeas.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppTokens.p16),
                  child: Text(
                    'No saved ideas yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTokens.textMuted),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMoveSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTokens.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.r16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Move to folder', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppTokens.p12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bookmark_outline),
                  title: const Text('Read Later'),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.document_scanner_outlined),
                  title: const Text('My Scanned Books'),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
