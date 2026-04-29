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
    return _fetchFirstPage();
  }

  Future<SummariesPage> getSummariesPage({int page = 1, int limit = 10}) async {
    return _api.getSummaries(page: page, limit: limit);
  }

  Future<List<SummaryItem>> _refreshFeedIfDueImpl() async {
    try {
      final decision = await canRefreshNow();
      if (!decision.allowed) {
        return _store.getCachedFeed();
      }

      return await _fetchFirstPage();
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<List<SummaryItem>> _fetchFirstPage() async {
    const limit = 10;
    final page = await _api.getSummaries(page: 1, limit: limit);
    final items = page.items.where((item) => item.id.isNotEmpty).toList();

    await _store.setCachedFeed(items);
    await _store.setLastRefreshAt(_now());
    return List<SummaryItem>.unmodifiable(items);
  }

  Future<DateTime?> getLastRefreshAt() => _store.getLastRefreshAt();

  DateTime nextScheduledRefresh({DateTime? from}) {
    final base = from ?? _now();
    final todayAt = _todayRefreshAt(base);
    if (base.isBefore(todayAt)) return todayAt;
    final tomorrow = base.add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, refreshHour, refreshMinute);
  }

  Future<bool> getTikTokMode() => _store.getTikTokMode();
  Future<void> setTikTokMode(bool enabled) => _store.setTikTokMode(enabled);

  FutureOr<void> dispose() {}

  Future<List<SummaryItem>>? _refreshInFlight;
}
