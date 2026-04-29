import 'dart:async';

import '../api/api_client.dart';
import '../api/models/summary.dart';
import '../offline/offline_store.dart';

class RefreshDecision {
  const RefreshDecision._({required this.allowed, required this.reason});

  final bool allowed;
  final String reason;

  static const RefreshDecision allowedNow = RefreshDecision._(
    allowed: true,
    reason: 'Due for daily refresh',
  );

  static const RefreshDecision notYet = RefreshDecision._(
    allowed: false,
    reason: 'Not 9:00 AM yet',
  );

  static const RefreshDecision alreadyDoneToday = RefreshDecision._(
    allowed: false,
    reason: 'Already refreshed today',
  );
}

class SummaryRepository {
  SummaryRepository({
    ApiClient? api,
    OfflineStore? store,
    DateTime Function()? now,
    this.refreshHour = 9,
    this.refreshMinute = 0,
  })  : _api = api ?? ApiClient(),
        _store = store ?? const OfflineStore(),
        _now = now ?? DateTime.now;

  final ApiClient _api;
  final OfflineStore _store;
  final DateTime Function() _now;

  final int refreshHour;
  final int refreshMinute;

  Future<List<SummaryItem>> loadFeedFromCache() => _store.getCachedFeed();

  DateTime _todayRefreshAt(DateTime now) {
    return DateTime(now.year, now.month, now.day, refreshHour, refreshMinute);
  }

  Future<RefreshDecision> canRefreshNow() async {
    final now = _now();
    final todayAt9 = _todayRefreshAt(now);
    
    // The most recent 9 AM boundary
    final mostRecent9AM = now.isBefore(todayAt9) 
        ? todayAt9.subtract(const Duration(days: 1)) 
        : todayAt9;

    final last = await _store.getLastRefreshAt();
    if (last == null) {
      return const RefreshDecision._(allowed: true, reason: 'Never refreshed');
    }

    if (last.isBefore(mostRecent9AM)) {
      return const RefreshDecision._(allowed: true, reason: 'Due for daily refresh');
    }

    return RefreshDecision.alreadyDoneToday;
  }

  Future<List<SummaryItem>> refreshFeedIfDue() {
    _refreshInFlight ??= _refreshFeedIfDueImpl();
    return _refreshInFlight!;
  }

  /// Force a full fetch from the API, bypassing the daily schedule gate.
  /// Use this after calling /api/refresh to ensure local data is up to date.
  Future<List<SummaryItem>> forceRefreshFeed() async {
    return _fetchAllPages();
  }

  Future<List<SummaryItem>> _refreshFeedIfDueImpl() async {
    try {
      final decision = await canRefreshNow();
      if (!decision.allowed) {
        return _store.getCachedFeed();
      }

      return await _fetchAllPages();
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<List<SummaryItem>> _fetchAllPages() async {
    const limit = 100;
    const maxPages = 50;

    var pageNum = 1;
    var hasNext = true;

    final seenIds = <String>{};
    final all = <SummaryItem>[];

    while (hasNext && pageNum <= maxPages) {
      final page = await _api.getSummaries(page: pageNum, limit: limit);

      for (final item in page.items) {
        if (item.id.isEmpty) continue;
        if (seenIds.add(item.id)) all.add(item);
      }

      hasNext = page.pageInfo.hasNext && page.items.isNotEmpty;
      pageNum++;
    }

    await _store.setCachedFeed(all);
    await _store.setLastRefreshAt(_now());
    return List<SummaryItem>.unmodifiable(all);
  }

  Future<DateTime?> getLastRefreshAt() => _store.getLastRefreshAt();

  DateTime nextScheduledRefresh({DateTime? from}) {
    final base = from ?? _now();
    final todayAt = _todayRefreshAt(base);
    if (base.isBefore(todayAt)) return todayAt;
    final tomorrow = base.add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, refreshHour, refreshMinute);
  }

  FutureOr<void> dispose() {}

  Future<List<SummaryItem>>? _refreshInFlight;
}
