import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/tokens.dart';
import '../repositories/library_repository.dart';
import '../database/database.dart';
import '../api/api_client.dart';
import '../repositories/summary_repository.dart';
import 'article_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Library',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Saved'),
              Tab(text: 'Liked'),
            ],
            indicatorColor: AppTokens.accent,
            labelColor: AppTokens.accent,
            unselectedLabelColor: AppTokens.textMuted,
          ),
        ),
        body: TabBarView(
          children: [
            _SavedTab(),
            _LikedTab(),
          ],
        ),
      ),
    );
  }
}

class _SavedTab extends StatefulWidget {
  const _SavedTab();

  @override
  State<_SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<_SavedTab> {
  List<Folder> _folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() => _isLoading = true);
    final folders = await libraryRepository.getFolders();
    if (mounted) {
      setState(() {
        _folders = folders;
        _isLoading = false;
      });
    }
  }

  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTokens.card,
        title: const Text('New Folder', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Folder Name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: TextButton.styleFrom(foregroundColor: AppTokens.accent),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await libraryRepository.createFolder(name.trim());
      _loadFolders();
    }
  }

  Future<void> _editFolder(Folder folder) async {
    final controller = TextEditingController(text: folder.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTokens.card,
        title: const Text('Rename Folder', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Folder Name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: TextButton.styleFrom(foregroundColor: AppTokens.accent),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty && name.trim() != folder.name) {
      await libraryRepository.updateFolder(folder.id, name.trim());
      _loadFolders();
    }
  }

  Future<void> _deleteFolder(Folder folder) async {
    if (folder.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default folder cannot be deleted.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTokens.card,
        title: const Text('Delete Folder?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will permanently delete "${folder.name}" and all ideas inside it.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await libraryRepository.deleteFolder(folder.id);
      _loadFolders();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.separated(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
        itemCount: _folders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final folder = _folders[index];
          return ListTile(
            tileColor: Theme.of(context).cardColor.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
            leading: Icon(
              folder.isDefault ? Icons.bookmark_rounded : Icons.folder_rounded,
              color: folder.isDefault ? AppTokens.accent : AppTokens.textMuted,
            ),
            title: Text(
              folder.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  color: AppTokens.card,
                  surfaceTintColor: Colors.transparent,
                  onSelected: (value) {
                    if (value == 'edit') _editFolder(folder);
                    if (value == 'delete') _deleteFolder(folder);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 12),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    if (!folder.isDefault)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                  ],
                ),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FolderScreen(folder: folder)),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: _createFolder,
          backgroundColor: AppTokens.accent,
          foregroundColor: Colors.white,
          child: const Icon(Icons.create_new_folder),
        ),
      ),
    );
  }
}

class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key, required this.folder});
  final Folder folder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(folder.name),
      ),
      body: StreamBuilder<List<SavedIdea>>(
        stream: libraryRepository.watchSavedIdeas(folder.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final ideas = snapshot.data ?? [];
          if (ideas.isEmpty) {
            return const Center(child: Text('No ideas saved in this folder.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            itemCount: ideas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final idea = ideas[index];
              return _IdeaListItem(
                articleId: idea.articleId,
                articleTitle: idea.articleTitle,
                textContent: idea.textContent,
                articleUrl: idea.articleUrl,
                imageUrl: idea.imageUrl,
                onRemove: () => libraryRepository.removeSavedIdea(idea.id),
                icon: Icons.bookmark_remove,
              );
            },
          );
        },
      ),
    );
  }
}

class _LikedTab extends StatelessWidget {
  const _LikedTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LikedIdea>>(
      stream: libraryRepository.watchLikedIdeas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final ideas = snapshot.data ?? [];
        if (ideas.isEmpty) {
          return const Center(child: Text('No liked ideas yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
          itemCount: ideas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final idea = ideas[index];
            return _IdeaListItem(
              articleId: idea.articleId,
              articleTitle: idea.articleTitle,
              textContent: idea.textContent,
              articleUrl: idea.articleUrl,
              imageUrl: idea.imageUrl,
              onRemove: () => libraryRepository.unlikeIdea(idea.id),
              icon: Icons.favorite_border,
            );
          },
        );
      },
    );
  }
}

class _IdeaListItem extends StatelessWidget {
  const _IdeaListItem({
    required this.articleId,
    required this.articleTitle,
    required this.textContent,
    required this.articleUrl,
    required this.onRemove,
    required this.icon,
    this.imageUrl,
  });

  final String articleId;
  final String articleTitle;
  final String textContent;
  final String articleUrl;
  final String? imageUrl;
  final VoidCallback onRemove;
  final IconData icon;

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _navigateToFullArticle(BuildContext context) async {
    final repo = SummaryRepository(api: ApiClient());
    final cached = await repo.loadFeedFromCache();
    final article = cached.where((a) => a.id == articleId).firstOrNull;
    
    if (context.mounted) {
      if (article != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ArticleDetailScreen(summary: article)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article no longer available locally.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (imageUrl != null)
            Positioned.fill(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  articleTitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTokens.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(icon, size: 20, color: AppTokens.textMuted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            textContent,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _navigateToFullArticle(context),
                icon: const Icon(Icons.article_outlined, size: 14),
                label: const Text('Full Article', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppTokens.accent,
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _launchUrl(articleUrl),
                icon: const Icon(Icons.open_in_new, size: 14),
                label: const Text('Source URL', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppTokens.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
      ),
    );
  }
}
