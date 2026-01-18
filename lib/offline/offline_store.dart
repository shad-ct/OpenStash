import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/models/summary.dart';

class OfflineStore {
  const OfflineStore({this.namespace = 'openstash'});

  final String namespace;

  String _k(String key) => '$namespace:$key';

  static const String _feedKey = 'feed.v1';
  static const String _lastRefreshAtKey = 'feed.lastRefreshAtMs';

  Future<List<SummaryItem>> getCachedFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_k(_feedKey));
    if (raw == null || raw.isEmpty) return const <SummaryItem>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <SummaryItem>[];
      return decoded
          .whereType<Map>()
          .map((m) => m.cast<String, Object?>())
          .map(SummaryItem.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const <SummaryItem>[];
    }
  }

  Future<void> setCachedFeed(List<SummaryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_k(_feedKey), raw);
  }

  Future<DateTime?> getLastRefreshAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_k(_lastRefreshAtKey));
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastRefreshAt(DateTime at) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_k(_lastRefreshAtKey), at.millisecondsSinceEpoch);
  }
}
