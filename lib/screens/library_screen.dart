import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/tokens.dart';
import '../repositories/library_repository.dart';
import '../database/database.dart';

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
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Folder Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Create')),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      await libraryRepository.createFolder(name.trim());
      _loadFolders();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _folders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final folder = _folders[index];
          return ListTile(
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            leading: Icon(
              folder.isDefault ? Icons.bookmark : Icons.folder,
              color: AppTokens.textMuted,
            ),
            title: Text(folder.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FolderScreen(folder: folder)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createFolder,
        backgroundColor: AppTokens.accent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.create_new_folder),
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
            padding: const EdgeInsets.all(16),
            itemCount: ideas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final idea = ideas[index];
              return _IdeaListItem(
                articleTitle: idea.articleTitle,
                textContent: idea.textContent,
                articleUrl: idea.articleUrl,
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
          padding: const EdgeInsets.all(16),
          itemCount: ideas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final idea = ideas[index];
            return _IdeaListItem(
              articleTitle: idea.articleTitle,
              textContent: idea.textContent,
              articleUrl: idea.articleUrl,
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
    required this.articleTitle,
    required this.textContent,
    required this.articleUrl,
    required this.onRemove,
    required this.icon,
  });

  final String articleTitle;
  final String textContent;
  final String articleUrl;
  final VoidCallback onRemove;
  final IconData icon;

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _launchUrl(articleUrl),
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('Read Article', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
