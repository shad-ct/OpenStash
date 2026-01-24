import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/models/summary.dart';
import '../repositories/summary_repository.dart';
import '../theme/tokens.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/topic_tile.dart';
import '../widgets/motion.dart';
import '../widgets/skeleton.dart';
import 'article_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    this.apiClient,
    this.repository,
  });

  final ApiClient? apiClient;
  final SummaryRepository? repository;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

enum _ExploreUiState { loading, empty, content }

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedGroup;

  // Map categories to broader groups
  static const _categoryGroups = {
    'Science & Technology': [
      'Acoustics', 'Aerospace Engineering', 'Artificial Intelligence', 'Astronomy', 
      'Automation', 'Biotechnology', 'Blockchain', 'Cloud Computing', 'Computer Vision',
      'Cryptography', 'Cybersecurity', 'Data Science', 'Electrical Engineering',
      'Game Development', 'Genetics', 'Geology', 'Hacking', 'Information Technology',
      'Internet of Things (IoT)', 'Machine Learning', 'Nanotechnology', 'Neuroscience',
      'Quantum Mechanics', 'Robotics', 'Software Engineering', 'Space Exploration',
      'Virtual Reality (VR)', 'Web Development',
    ],
    'Humanities & Social Sciences': [
      'Anthropology', 'Archaeology', 'Cognitive Science', 'Criminology', 'Geography',
      'History (Ancient, Medieval, Modern)', 'International Relations', 
      'Law (Constitutional, Corporate, Criminal)', 'Linguistics', 'Philosophy',
      'Political Science', 'Psychology (Clinical, Social, Behavioral)', 'Religious Studies', 'Sociology',
    ],
    'Business & Economics': [
      'Accounting', 'Advertising', 'Behavioral Economics', 'Branding', 'Business Ethics',
      'Corporate Governance', 'Cryptocurrency', 'Digital Marketing', 'E-commerce',
      'Entrepreneurship', 'Finance (Personal, Corporate)', 'Human Resources',
      'Industrial Relations', 'Insurance', 'International Trade', 'Investing',
      'Logistics', 'Macroeconomics', 'Management', 'Microeconomics', 'Operations Management',
      'Project Management', 'Real Estate', 'Sales', 'Stock Market', 'Supply Chain Management',
      'Taxation', 'Venture Capital',
    ],
    'Arts, Culture & Media': [
      'Animation', 'Architecture', 'Art History', 'Calligraphy', 'Cinematography',
      'Creative Writing', 'Culinary Arts', 'Dance', 'Design (Graphic, Industrial, Interior)',
      'Fashion', 'Film Studies', 'Fine Arts', 'Journalism', 'Literature', 'Music Theory',
      'Performing Arts', 'Photography', 'Poetry', 'Pop Culture', 'Publishing', 'Sculpture',
      'Stand-up Comedy', 'Television', 'Textile Design', 'Theater', 'Video Games', 'Visual Arts',
    ],
    'Health, Lifestyle & Sports': [
      'Alternative Medicine', 'Athletic Training', 'Biohacking', 'Dental Hygiene',
      'Dermatology', 'Dietetics', 'Emergency Medicine', 'Ergonomics', 'Fitness',
      'Gastronomy', 'Geriatrics', 'Holistic Health', 'Kinesiology', 'Meditation',
      'Mental Health', 'Minimalism', 'Nursing', 'Nutrition', 'Occupational Therapy',
      'Parenting', 'Pediatrics', 'Personal Development', 'Physical Therapy', 'Productivity',
      'Psychiatry', 'Public Health', 'Sports Management', 'Sports Psychology', 'Sports Science',
      'Survivalism', 'Travel & Tourism', 'Veterinary Medicine', 'Wellness', 'Yoga',
    ],
    'Niche & Miscellaneous': [
      'Astrology', 'Aviation', 'Bibliophilia', 'Carpentry', 'Chess',
      'Collecting (Philately, Numismatics)', 'Conspiracy Theories', 'Cryptozoology',
      'DIY & Making', 'Esotericism', 'Etiquette', 'Futurism', 'Gardening', 'Genealogy',
      'Horticulture', 'Magic (Illusion)', 'Maritime Studies', 'Military Strategy',
      'Numismatics', 'Occultism', 'Parapsychology', 'Philanthropy', 'Survival Skills',
      'Transhumanism', 'True Crime', 'Vexillology (Flags)',
    ],
  };

  List<SummaryItem> _filterArticlesByGroup(String? group) {
    if (group == null) return [];
    final categoriesInGroup = _categoryGroups[group] ?? [];
    return _allArticles.where((item) {
      return item.categories.any((cat) => categoriesInGroup.contains(cat));
    }).toList();
  }

  List<String> _extractUniqueCategories(List<SummaryItem> articles) {
    final categories = <String>{};
    for (final article in articles) {
      categories.addAll(article.categories);
    }
    return categories.toList()..sort();
  }

  IconData _getCategoryIcon(String category) {
    const categoryIcons = {
      // Science & Technology
      'Acoustics': Icons.volume_up,
      'Aerospace Engineering': Icons.airplanemode_active,
      'Artificial Intelligence': Icons.smart_toy,
      'Astronomy': Icons.star,
      'Automation': Icons.precision_manufacturing,
      'Biotechnology': Icons.biotech,
      'Blockchain': Icons.link,
      'Cloud Computing': Icons.cloud,
      'Computer Vision': Icons.visibility,
      'Cryptography': Icons.lock,
      'Cybersecurity': Icons.security,
      'Data Science': Icons.analytics,
      'Electrical Engineering': Icons.electrical_services,
      'Game Development': Icons.games,
      'Genetics': Icons.science,
      'Geology': Icons.terrain,
      'Hacking': Icons.bug_report,
      'Information Technology': Icons.computer,
      'Internet of Things (IoT)': Icons.router,
      'Machine Learning': Icons.psychology,
      'Nanotechnology': Icons.zoom_in,
      'Neuroscience': Icons.psychology,
      'Quantum Mechanics': Icons.blur_on,
      'Robotics': Icons.precision_manufacturing,
      'Software Engineering': Icons.code,
      'Space Exploration': Icons.rocket,
      'Virtual Reality (VR)': Icons.videogame_asset,
      'Web Development': Icons.language,
      
      // Humanities & Social Sciences
      'Anthropology': Icons.people,
      'Archaeology': Icons.history,
      'Cognitive Science': Icons.lightbulb,
      'Criminology': Icons.gavel,
      'Geography': Icons.map,
      'History (Ancient, Medieval, Modern)': Icons.history,
      'International Relations': Icons.public,
      'Law (Constitutional, Corporate, Criminal)': Icons.balance,
      'Linguistics': Icons.language,
      'Philosophy': Icons.school,
      'Political Science': Icons.how_to_vote,
      'Psychology (Clinical, Social, Behavioral)': Icons.psychology,
      'Religious Studies': Icons.church,
      'Sociology': Icons.group,
      
      // Business & Economics
      'Accounting': Icons.calculate,
      'Advertising': Icons.campaign,
      'Branding': Icons.flag,
      'Business Ethics': Icons.handshake,
      'Cryptocurrency': Icons.currency_bitcoin,
      'Digital Marketing': Icons.trending_up,
      'E-commerce': Icons.shopping_cart,
      'Entrepreneurship': Icons.lightbulb,
      'Finance (Personal, Corporate)': Icons.money,
      'Human Resources': Icons.person_add,
      'Investing': Icons.trending_up,
      'Management': Icons.assessment,
      'Real Estate': Icons.home,
      'Stock Market': Icons.show_chart,
      'Supply Chain Management': Icons.local_shipping,
      
      // Arts, Culture & Media
      'Animation': Icons.animation,
      'Architecture': Icons.domain,
      'Art History': Icons.palette,
      'Cinematography': Icons.videocam,
      'Creative Writing': Icons.edit,
      'Culinary Arts': Icons.restaurant,
      'Dance': Icons.directions_walk,
      'Design (Graphic, Industrial, Interior)': Icons.brush,
      'Fashion': Icons.checkroom,
      'Film Studies': Icons.movie,
      'Fine Arts': Icons.art_track,
      'Journalism': Icons.newspaper,
      'Literature': Icons.library_books,
      'Music Theory': Icons.music_note,
      'Photography': Icons.camera_alt,
      'Poetry': Icons.edit_note,
      'Theater': Icons.theaters,
      'Visual Arts': Icons.palette,
      
      // Health, Lifestyle & Sports
      'Athletic Training': Icons.fitness_center,
      'Dental Hygiene': Icons.health_and_safety,
      'Dermatology': Icons.favorite,
      'Dietetics': Icons.restaurant_menu,
      'Emergency Medicine': Icons.local_hospital,
      'Fitness': Icons.fitness_center,
      'Geriatrics': Icons.elderly,
      'Mental Health': Icons.mood,
      'Nursing': Icons.local_hospital,
      'Nutrition': Icons.apple,
      'Parenting': Icons.family_restroom,
      'Pediatrics': Icons.child_care,
      'Personal Development': Icons.trending_up,
      'Physical Therapy': Icons.accessibility,
      'Psychiatry': Icons.psychology,
      'Public Health': Icons.health_and_safety,
      'Sports Management': Icons.sports,
      'Sports Psychology': Icons.sports_handball,
      'Sports Science': Icons.sports,
      'Travel & Tourism': Icons.flight,
      'Veterinary Medicine': Icons.pets,
      'Wellness': Icons.spa,
      'Yoga': Icons.self_improvement,
      
      // Niche & Miscellaneous
      'Aviation': Icons.airplanemode_active,
      'Chess': Icons.sports_esports,
      'DIY & Making': Icons.build,
      'Futurism': Icons.rocket,
      'Gardening': Icons.grass,
      'Horticulture': Icons.grass,
      'Magic (Illusion)': Icons.auto_awesome,
      'Military Strategy': Icons.security,
      'Occultism': Icons.dark_mode,
      'Survival Skills': Icons.emergency,
      'Transhumanism': Icons.upgrade,
      'True Crime': Icons.shield,
    };
    
    return categoryIcons[category] ?? Icons.local_offer;
  }
  late final ApiClient _api = widget.apiClient ?? ApiClient();
  late final SummaryRepository _repo = widget.repository ?? SummaryRepository(api: _api);

  _ExploreUiState _state = _ExploreUiState.loading;
  List<SummaryItem> _allArticles = [];
  List<SummaryItem> _filteredArticles = [];
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = _ExploreUiState.loading);

    try {
      final cached = await _repo.loadFeedFromCache();
      if (!mounted) return;
      final categories = _extractUniqueCategories(cached);
      setState(() {
        _allArticles = cached;
        _filteredArticles = [];
        _availableCategories = categories;
        _state = categories.isEmpty ? _ExploreUiState.empty : _ExploreUiState.content;
      });

      // If the daily refresh is due (>= 9 AM and not done today), refresh once.
      final decision = await _repo.canRefreshNow();
      if (!decision.allowed) return;
      final refreshed = await _repo.refreshFeedIfDue();
      if (!mounted) return;
      final refreshedCategories = _extractUniqueCategories(refreshed);
      setState(() {
        _allArticles = refreshed;
        _availableCategories = refreshedCategories;
        // Keep current selection, just recompute the filtered list.
        _filteredArticles = _filterArticlesByGroup(_selectedGroup);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = _ExploreUiState.empty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[
      const SliverToBoxAdapter(child: SizedBox(height: AppTokens.p8)),
      SliverToBoxAdapter(
        child: SearchBarWidget(
          onTap: () {
            if (_selectedGroup != null) {
              setState(() {
                _selectedGroup = null;
              });
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search (coming soon)')),
            );
          },
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppTokens.p16)),
      
      // Show group selection or articles
      if (_selectedGroup == null)
        SliverToBoxAdapter(
          child: Text(
            'Explore by category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        )
      else
        SliverToBoxAdapter(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedGroup = null;
                  });
                },
              ),
              Text('$_selectedGroup', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      
      const SliverToBoxAdapter(child: SizedBox(height: AppTokens.p8)),
      
      // Group selection grid
      if (_selectedGroup == null)
        SliverToBoxAdapter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppTokens.p12,
              crossAxisSpacing: AppTokens.p12,
              childAspectRatio: 1.05,
            ),
            itemCount: _categoryGroups.keys.length,
            itemBuilder: (context, index) {
              final group = _categoryGroups.keys.elementAt(index);
              return TopicTile(
                topic: _TopicAdapter(
                  name: group,
                  icon: _getGroupIcon(group),
                ),
                onTap: () {
                  setState(() {
                    _selectedGroup = group;
                    _filteredArticles = _filterArticlesByGroup(group);
                  });
                },
                selected: false,
              );
            },
          ),
        )
      // Articles for selected group
      else
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTokens.p8),
              _filteredArticles.isEmpty
                  ? const Text('No articles found in this category.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = _filteredArticles[index];
                        return Card(
                          color: AppTokens.card,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  article.author,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: article.categories
                                      .map((cat) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTokens.accent.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          cat,
                                          style: Theme.of(context).textTheme.labelSmall,
                                        ),
                                      ))
                                      .toList(),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ArticleDetailScreen(summary: article),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_forward, size: 16),
                                    label: const Text('Read'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
    ];

    return PopScope(
      canPop: _selectedGroup == null,
      onPopInvoked: (didPop) {
        if (!didPop) {
          setState(() {
            _selectedGroup = null;
            _filteredArticles = [];
          });
        }
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.p16),
          child: CustomScrollView(
            key: const PageStorageKey('explore_scroll'),
            slivers: [
              ...slivers,
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGroupIcon(String group) {
    const groupIcons = {
      'Science & Technology': Icons.science,
      'Humanities & Social Sciences': Icons.school,
      'Business & Economics': Icons.business,
      'Arts, Culture & Media': Icons.palette,
      'Health, Lifestyle & Sports': Icons.fitness_center,
      'Niche & Miscellaneous': Icons.category,
    };
    return groupIcons[group] ?? Icons.category;
  }
}

class _TopicAdapter {
  const _TopicAdapter({
    required this.name,
    this.icon = Icons.local_offer_outlined,
  });

  final String name;
  final IconData icon;
}
