import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/article_card.dart';
import '../widgets/motion.dart';
import '../widgets/offline_banner.dart';
import '../widgets/skeleton.dart';
import '../widgets/streak_badge.dart';
import '../widgets/streak_calendar_bottom_sheet.dart';
import '../api/api_client.dart';
import '../api/models/summary.dart';
import '../repositories/summary_repository.dart';
import '../repositories/streak_repository.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.apiClient,
    this.repository,
    this.testMode = false,
  });

  final ApiClient? apiClient;
  final SummaryRepository? repository;
  final bool testMode;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _HomeUiState { loading, empty, content }

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _streakCount = 0;

  late final ApiClient _api = widget.apiClient ?? ApiClient();
  late final SummaryRepository _repo = widget.repository ?? SummaryRepository(api: _api);
  Timer? _refreshTimer;

  _HomeUiState _state = _HomeUiState.loading;
  bool _offline = false;
  bool _isRefreshing = false;
  List<SummaryItem> _items = const <SummaryItem>[];



  @override
  Widget build(BuildContext context) {
    // Shadcn-like background color
    final backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF09090B) // Zinc 950
        : const Color(0xFFFFFFFF); // White

    final body = switch (_state) {
      _HomeUiState.loading => _LoadingFeed(key: const ValueKey('home_loading')),
      _HomeUiState.empty => _EmptyFeed(key: const ValueKey('home_empty')),
      _HomeUiState.content => _ContentFeed(
          key: const ValueKey('home_content'),
          offline: _offline,
          items: _items,
        ),
    };

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTokens.p16),
                  _TopBar(
                    streakCount: _streakCount,
                    onTapStreak: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const StreakCalendarBottomSheet(),
                      ).then((_) => _loadStreakCount());
                    },
                    isRefreshing: _isRefreshing,
                    onTapRefresh: _fetchFromMongo,
                    onTapProfile: _openSettings,
                  ),
                  const SizedBox(height: AppTokens.p16),
                  // Shadcn: Subtle separator
                  Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.5)),
                  const SizedBox(height: AppTokens.p16),
                  Expanded(
                    child: widget.testMode
                        ? body
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeOutCubic,
                            transitionBuilder: (child, animation) =>
                                Motion.fadeSlide(child: child, animation: animation),
                            child: body,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
    _loadStreakCount();

    if (!widget.testMode) {
      WidgetsBinding.instance.addObserver(this);
      _scheduleNextRefresh();
    }
  }

  Future<void> _loadStreakCount() async {
    final dates = await streakRepository.getCompletedDates();
    if (!mounted) return;
    
    // Simple streak calculation (how many consecutive days from today backwards)
    int currentStreak = 0;
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    
    // Convert to normalized dates
    final dateSet = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    
    DateTime checkDate = today;
    // If today is not in set, check yesterday. If yesterday is not in set, streak is 0.
    if (!dateSet.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      if (!dateSet.contains(checkDate)) {
        setState(() {
          _streakCount = 0;
        });
        return;
      }
    }
    
    // Count backwards
    while (dateSet.contains(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    setState(() {
      _streakCount = currentStreak;
    });
  }

  @override
  void dispose() {
    if (!widget.testMode) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.testMode) return;
    if (state == AppLifecycleState.resumed) {
      _attemptRefreshIfDue();
      _scheduleNextRefresh();
      _loadStreakCount();
    }
  }

  Future<void> _load() async {
    if (widget.testMode) {
      // Synchronous mock for tests: set state instantly, no async/await.
      final page = await _api.getSummaries(page: 1, limit: 100);
      final all = page.items.where((item) => item.id.isNotEmpty).toList();
      setState(() {
        _items = List<SummaryItem>.unmodifiable(all);
        _state = _items.isEmpty ? _HomeUiState.empty : _HomeUiState.content;
        _offline = false;
      });
      return;
    }

    setState(() {
      _state = _items.isEmpty ? _HomeUiState.loading : _HomeUiState.content;
      _offline = false;
    });

    final cached = await _repo.loadFeedFromCache();
    if (!mounted) return;

    setState(() {
      _items = List<SummaryItem>.unmodifiable(cached);
      _state = _items.isEmpty ? _HomeUiState.empty : _HomeUiState.content;
      // Default to showing the "saved content" banner unless we successfully refresh.
      _offline = true;
    });

    await _attemptRefreshIfDue();
  }

  Future<void> _attemptRefreshIfDue() async {
    if (widget.testMode) return;

    try {
      final decision = await _repo.canRefreshNow();
      if (!decision.allowed) {
        if (!mounted) return;
        setState(() {
          _offline = true;
        });
        return;
      }

      final refreshed = await _repo.refreshFeedIfDue();
      if (!mounted) return;

      setState(() {
        _items = List<SummaryItem>.unmodifiable(refreshed);
        _state = _items.isEmpty ? _HomeUiState.empty : _HomeUiState.content;
        _offline = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        // Keep showing cached data.
        _offline = true;
        _state = _items.isEmpty ? _HomeUiState.empty : _HomeUiState.content;
      });
    }
  }

  /// Pulls latest articles from MongoDB via /api/summaries (no backend job triggered).
  Future<void> _fetchFromMongo() async {
    if (widget.testMode || _isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final refreshed = await _repo.forceRefreshFeed();
      if (!mounted) return;
      setState(() {
        _items = List<SummaryItem>.unmodifiable(refreshed);
        _state = _items.isEmpty ? _HomeUiState.empty : _HomeUiState.content;
        _offline = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feed updated from MongoDB!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reach the server.')),
      );
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _refreshBackend() async {
    if (widget.testMode || _isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Triggering fresh summary generation...')),
    );

    try {
      // Step 1: Tell the backend to fetch & summarise new articles
      await _api.refreshFeed(force: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backend refreshed! Pulling latest articles...')),
      );

      // Step 2: Always pull fresh data from MongoDB, bypassing the daily gate
      final refreshed = await _repo.forceRefreshFeed();
      if (!mounted) return;

      setState(() {
        _items = List<SummaryItem>.unmodifiable(refreshed);
        _state = _items.isEmpty ? _HomeUiState.empty : _HomeUiState.content;
        _offline = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feed updated!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to trigger refresh. Check your connection.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SettingsSheet(
        isRefreshing: _isRefreshing,
        onFetchNew: () {
          Navigator.of(context).pop();
          _refreshBackend();
        },
      ),
    );
  }

  void _scheduleNextRefresh() {
    _refreshTimer?.cancel();
    final nextAt = _repo.nextScheduledRefresh();
    final delay = nextAt.difference(DateTime.now());
    if (delay.isNegative) return;

    _refreshTimer = Timer(delay, () {
      _attemptRefreshIfDue();
      _scheduleNextRefresh();
    });
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.streakCount,
    required this.onTapStreak,
    required this.onTapProfile,
    required this.onTapRefresh,
    this.isRefreshing = false,
  });

  final int streakCount;
  final VoidCallback? onTapStreak;
  final VoidCallback? onTapProfile;
  final VoidCallback? onTapRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand / Title Area
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            Text(
              'Discover new insights',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTokens.textMuted,
                  ),
            ),
          ],
        ),

        // Actions Area
        Row(
          children: [
            StreakBadge(
              key: const Key('streak_badge'),
              count: streakCount,
              onTap: onTapStreak,
            ),
            // Refresh button — pulls latest from /api/summaries
            isRefreshing
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    color: AppTokens.textMuted,
                    tooltip: 'Refresh feed',
                    onPressed: onTapRefresh,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
            // Profile avatar button
            GestureDetector(
              onTap: onTapProfile,
              child: CircleAvatar(
                radius: 18,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Settings Bottom Sheet ──────────────────────────────────────────────────────

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({
    required this.isRefreshing,
    required this.onFetchNew,
  });

  final bool isRefreshing;
  final VoidCallback onFetchNew;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF09090B);
    final mutedColor = isDark
        ? const Color(0xFF71717A)
        : const Color(0xFF52525B);
    final divColor = isDark
        ? const Color(0xFF27272A)
        : const Color(0xFFE4E4E7);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: divColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header row
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Profile',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Settings & Preferences',
                    style: TextStyle(fontSize: 13, color: mutedColor),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(height: 1, color: divColor),
          const SizedBox(height: 20),

          // Section label
          Text(
            'DATA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 12),

          // Fetch New button
          _SettingsTile(
            icon: Icons.cloud_download_outlined,
            label: 'Fetch New Data',
            sublabel: 'Calls /api/refresh to generate fresh summaries',
            trailing: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppTokens.textMuted),
            onTap: isRefreshing ? null : onFetchNew,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg =
        isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final textColor = isDark ? Colors.white : const Color(0xFF09090B);
    final mutedColor =
        isDark ? const Color(0xFF71717A) : const Color(0xFF52525B);

    return Material(
      color: tileBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppTokens.textMuted),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sublabel,
                      style: TextStyle(fontSize: 12, color: mutedColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentFeed extends StatelessWidget {
  const _ContentFeed({
    super.key,
    required this.offline,
    required this.items,
  });

  final bool offline;
  final List<SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const PageStorageKey('home_feed'),
      padding: const EdgeInsets.only(bottom: AppTokens.p16),
      itemCount: items.length + (offline ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 16), // Increased spacing
      itemBuilder: (context, index) {
        if (offline) {
          if (index == 0) return const OfflineBanner();
          index -= 1;
        }

        final summary = items[index];
        return ArticleCard(
          article: summary,
          onTap: () {
            Navigator.of(context).push(
              Motion.pageRoute((_) => ArticleDetailScreen(summary: summary)),
            ).then((_) {
              // Refresh streak when returning from reading
              if (context.mounted) {
                final state = context.findAncestorStateOfType<_HomeScreenState>();
                state?._loadStreakCount();
              }
            });
          },
        );
      },
    );
  }
}

class _LoadingFeed extends StatelessWidget {
  const _LoadingFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const PageStorageKey('home_loading'),
      padding: const EdgeInsets.only(bottom: AppTokens.p16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(AppTokens.r12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
               SkeletonBox(height: 140, radius: 8), // Replaces Image
               SizedBox(height: 12),
               SkeletonBox(height: 18, width: 200),
               SizedBox(height: 8),
               SkeletonBox(height: 14, width: double.infinity),
               SizedBox(height: 4),
               SkeletonBox(height: 14, width: 150),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppTokens.textMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No articles found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your next great idea is one read away.\nCheck back later.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}