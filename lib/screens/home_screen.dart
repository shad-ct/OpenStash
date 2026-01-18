import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/article_card.dart';
import '../widgets/motion.dart';
import '../widgets/offline_banner.dart';
import '../widgets/skeleton.dart';
import '../widgets/streak_badge.dart';
import '../api/api_client.dart';
import '../api/models/summary.dart';
import '../repositories/summary_repository.dart';
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
  List<SummaryItem> _items = const <SummaryItem>[];

  DateTime _lastUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);

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
                    onTapStreak: null,
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

    if (!widget.testMode) {
      WidgetsBinding.instance.addObserver(this);
      _scheduleNextRefresh();
    }
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
    }
  }

  Future<void> _load() async {
    if (widget.testMode) {
      // Synchronous mock for tests: set state instantly, no async/await.
      final page = await _api.getSummaries(page: 1, limit: 100);
      final all = page.items.where((item) => item.id.isNotEmpty).toList();
      setState(() {
        _items = List<SummaryItem>.unmodifiable(all);
        _streakCount = _items.length;
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
      _streakCount = _items.length;
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
        _streakCount = _items.length;
        _state = _items.isEmpty ? _HomeUiState.empty : _HomeUiState.content;
        _offline = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        // Keep showing cached data.
        _offline = true;
        _streakCount = _items.length;
        _state = _items.isEmpty ? _HomeUiState.empty : _HomeUiState.content;
      });
    }
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
  const _TopBar({required this.streakCount, required this.onTapStreak});

  final int streakCount;
  final VoidCallback? onTapStreak;

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
            const SizedBox(width: AppTokens.p12),
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: AppTokens.cardAlt,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: const Icon(Icons.person, size: 18, color: AppTokens.textMuted),
            ),
          ],
        ),
      ],
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
            );
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