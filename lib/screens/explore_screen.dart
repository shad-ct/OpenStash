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
  String? _selectedMainTopic;

  List<SummaryItem> _filterArticlesByMainTopic(String? mainTopic) {
    if (mainTopic == null) return [];
    final subtopics = _subTopics[mainTopic] ?? [];
    return _allArticles.where((item) {
      final text = ((item.feedTitle ?? '') + ' ' + item.title).toLowerCase();
      return subtopics.any((sub) => text.contains(sub.toLowerCase()));
    }).toList();
  }
  late final ApiClient _api = widget.apiClient ?? ApiClient();
  late final SummaryRepository _repo = widget.repository ?? SummaryRepository(api: _api);

  _ExploreUiState _state = _ExploreUiState.loading;
  List<SummaryItem> _allArticles = [];
  List<SummaryItem> _filteredArticles = [];

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
      setState(() {
        _allArticles = cached;
        _filteredArticles = [];
        _state = _mainTopics.isEmpty ? _ExploreUiState.empty : _ExploreUiState.content;
      });

      // If the daily refresh is due (>= 9 AM and not done today), refresh once.
      final decision = await _repo.canRefreshNow();
      if (!decision.allowed) return;
      final refreshed = await _repo.refreshFeedIfDue();
      if (!mounted) return;
      setState(() {
        _allArticles = refreshed;
        // Keep current selection, just recompute the filtered list.
        _filteredArticles = _filterArticlesByMainTopic(_selectedMainTopic);
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search (coming soon)')),
            );
          },
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppTokens.p16)),
      SliverToBoxAdapter(
        child: Text(
          _selectedMainTopic == null
              ? 'Explore by main topic'
              : 'Select a subtopic in $_selectedMainTopic',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppTokens.p8)),
      if (_selectedMainTopic == null)
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
            itemCount: _mainTopics.length,
            itemBuilder: (context, index) {
              final main = _mainTopics[index];
              return TopicTile(
                topic: _TopicAdapter(name: main),
                onTap: () {
                  setState(() {
                    _selectedMainTopic = main;
                    _filteredArticles = _filterArticlesByMainTopic(main);
                  });
                },
                selected: false,
              );
            },
          ),
        )
      else
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedMainTopic = null;
                        _filteredArticles = [];
                      });
                    },
                  ),
                  Text('Articles for "$_selectedMainTopic"', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: AppTokens.p8),
              _filteredArticles.isEmpty
                  ? const Text('No articles found for this topic.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = _filteredArticles[index];
                        return Card(
                          color: AppTokens.card,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(article.title),
                            subtitle: Text(article.author),
                            trailing: Icon(Icons.arrow_forward_ios, color: AppTokens.accent),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailScreen(summary: article),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.p16),
        child: CustomScrollView(
          key: const PageStorageKey('explore_scroll'),
          slivers: [
            ...slivers,
          ],
        ),
      ),
    );
  }
}

class _TopicsLoading extends StatelessWidget {
  const _TopicsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppTokens.p12,
      crossAxisSpacing: AppTokens.p12,
      childAspectRatio: 1.05,
      children: const [
        SkeletonBox(height: 120, radius: AppTokens.r16),
        SkeletonBox(height: 120, radius: AppTokens.r16),
        SkeletonBox(height: 120, radius: AppTokens.r16),
        SkeletonBox(height: 120, radius: AppTokens.r16),
      ],
    );
  }
}

class _TopicsEmpty extends StatelessWidget {
  const _TopicsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.p16),
      child: Text(
        'No topics yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTokens.textMuted),
      ),
    );
  }
}

class _TopicsGrid extends StatelessWidget {
  const _TopicsGrid({
    super.key,
    required this.topics,
    required this.selectedTopic,
    required this.onTopicSelected,
  });

  final List<_ExploreTopic> topics;
  final String? selectedTopic;
  final ValueChanged<String> onTopicSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppTokens.p12,
        crossAxisSpacing: AppTokens.p12,
        childAspectRatio: 1.05,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final t = topics[index];
        final isSelected = t.label == selectedTopic;
        return TopicTile(
          topic: t.asTopic(),
          onTap: () => onTopicSelected(t.label),
          selected: isSelected,
        );
      },
    );
  }
}


const List<String> _mainTopics = [
  'Science & Technology',
  'Humanities & Social Sciences',
  'Business & Economics',
  'Arts, Culture & Media',
  'Health, Lifestyle & Sports',
  'Niche & Miscellaneous',
];

const Map<String, List<String>> _subTopics = {
  'Science & Technology': [
    "Acoustics", "Aerospace Engineering", "Agronomy", "Artificial Intelligence", "Astronomy", "Astrophysics", "Automation", "Bioinformatics", "Biotechnology", "Blockchain", "Botany", "Chemical Engineering", "Civil Engineering", "Cloud Computing", "Computer Vision", "Consumer Electronics", "Cryptography", "Cybersecurity", "Data Science", "Ecology", "Electrical Engineering", "Entomology", "Epidemiology", "Evolutionary Biology", "Forensic Science", "Game Development", "Genetics", "Geology", "Hacking", "Hydrology", "Immunology", "Information Technology", "Internet of Things (IoT)", "Machine Learning", "Marine Biology", "Materials Science", "Mechanical Engineering", "Meteorology", "Microbiology", "Nanotechnology", "Neuroscience", "Nuclear Physics", "Oceanography", "Optics", "Organic Chemistry", "Paleontology", "Particle Physics", "Pharmacology", "Quantum Mechanics", "Robotics", "Software Engineering", "Space Exploration", "Sustainability", "Telecommunications", "Thermodynamics", "Toxicology", "Virtual Reality (VR)", "Web Development", "Zoology",
  ],
  'Humanities & Social Sciences': [
    "Anthropology", "Archaeology", "Cognitive Science", "Criminology", "Demography", "Developmental Psychology", "Epistemology", "Ethics", "Ethnography", "Gender Studies", "Genealogy", "Geography", "Geopolitics", "History (Ancient, Medieval, Modern)", "Human Rights", "International Relations", "Law (Constitutional, Corporate, Criminal)", "Linguistics", "Logic", "Media Studies", "Metaphysics", "Military History", "Mythology", "Pedagogy", "Philosophy", "Political Science", "Psychology (Clinical, Social, Behavioral)", "Public Administration", "Religious Studies", "Social Work", "Sociology", "Theology", "Urban Planning",
  ],
  'Business & Economics': [
    "Accounting", "Advertising", "Behavioral Economics", "Branding", "Business Ethics", "Corporate Governance", "Cryptocurrency", "Digital Marketing", "E-commerce", "Entrepreneurship", "Finance (Personal, Corporate)", "Human Resources", "Industrial Relations", "Insurance", "International Trade", "Investing", "Logistics", "Macroeconomics", "Management", "Microeconomics", "Operations Management", "Project Management", "Real Estate", "Sales", "Stock Market", "Supply Chain Management", "Taxation", "Venture Capital",
  ],
  'Arts, Culture & Media': [
    "Animation", "Architecture", "Art History", "Calligraphy", "Cinematography", "Creative Writing", "Culinary Arts", "Dance", "Design (Graphic, Industrial, Interior)", "Fashion", "Film Studies", "Fine Arts", "Journalism", "Literature", "Music Theory", "Performing Arts", "Photography", "Poetry", "Pop Culture", "Publishing", "Sculpture", "Stand-up Comedy", "Television", "Textile Design", "Theater", "Video Games", "Visual Arts",
  ],
  'Health, Lifestyle & Sports': [
    "Alternative Medicine", "Athletic Training", "Biohacking", "Dental Hygiene", "Dermatology", "Dietetics", "Emergency Medicine", "Ergonomics", "Fitness", "Gastronomy", "Geriatrics", "Holistic Health", "Kinesiology", "Meditation", "Mental Health", "Minimalism", "Nursing", "Nutrition", "Occupational Therapy", "Parenting", "Pediatrics", "Personal Development", "Physical Therapy", "Productivity", "Psychiatry", "Public Health", "Sports Management", "Sports Psychology", "Sports Science", "Survivalism", "Travel & Tourism", "Veterinary Medicine", "Wellness", "Yoga",
  ],
  'Niche & Miscellaneous': [
    "Astrology", "Aviation", "Bibliophilia", "Carpentry", "Chess", "Collecting (Philately, Numismatics)", "Conspiracy Theories", "Cryptozoology", "DIY & Making", "Esotericism", "Etiquette", "Futurism", "Gardening", "Genealogy", "Horticulture", "Magic (Illusion)", "Maritime Studies", "Military Strategy", "Numismatics", "Occultism", "Parapsychology", "Philanthropy", "Survival Skills", "Transhumanism", "True Crime", "Vexillology (Flags)"
  ],
};

class _ExploreTopic {
  const _ExploreTopic({required this.label});

  final String label;

  // Uses a generic icon to avoid hardcoded topic taxonomy.
  // We keep `TopicTile` reusable without introducing new UI.
  dynamic asTopic() {
    // Local adapter object for TopicTile's expected type.
    return _TopicAdapter(name: label);
  }
}

class _TopicAdapter {
  const _TopicAdapter({required this.name});

  final String name;

  // TopicTile expects `topic.icon` and `topic.name`.
  IconData get icon => Icons.local_offer_outlined;
}

List<_ExploreTopic> _deriveTopics(List<SummaryItem> items) {
  final set = <String>{};
  final out = <_ExploreTopic>[];

  for (final it in items) {
    final label = (it.feedTitle ?? it.sourceDomain ?? '').trim();
    if (label.isEmpty) continue;
    if (set.add(label)) out.add(_ExploreTopic(label: label));
  }

  out.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  return out;
}

class _DiveDeeperCard extends StatelessWidget {
  const _DiveDeeperCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.r16),
      child: Material(
        color: AppTokens.card,
        child: InkWell(
          onTap: onTap,
          splashColor: AppTokens.accent.withOpacity(0.10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.p12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white.withOpacity(0.85)),
                const SizedBox(height: 8),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
