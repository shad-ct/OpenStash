class SummariesPage {
  const SummariesPage({required this.items, required this.pageInfo});

  final List<SummaryItem> items;
  final PageInfo pageInfo;

  factory SummariesPage.fromJson(Map<String, Object?> json) {
    final itemsJson = (json['items'] as List<Object?>? ?? const <Object?>[]);
    final pageInfoJson = (json['pageInfo'] as Map<String, Object?>? ?? const <String, Object?>{});

    return SummariesPage(
      items: itemsJson
          .whereType<Map<String, Object?>>()
          .map(SummaryItem.fromJson)
          .toList(growable: false),
      pageInfo: PageInfo.fromJson(pageInfoJson),
    );
  }
}

class PageInfo {
  const PageInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.hasNext,
  });

  final int page;
  final int limit;
  final int total;
  final bool hasNext;

  factory PageInfo.fromJson(Map<String, Object?> json) {
    return PageInfo(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      hasNext: (json['hasNext'] as bool?) ?? false,
    );
  }
}

class SummaryItem {
  const SummaryItem({
    required this.id,
    required this.title,
    required this.author,
    required this.url,
    required this.feedTitle,
    required this.sourceDomain,
    required this.reads,
    required this.publishedAt,
    required this.ingestedAt,
    required this.imageUrl,
    required this.points,
  });

  final String id;
  final String title;
  final String author;
  final String url;
  final String? feedTitle;
  final String? sourceDomain;
  final int? reads;
  final DateTime? publishedAt;
  final DateTime? ingestedAt;
  final String? imageUrl;
  final List<SummaryPoint> points;

  factory SummaryItem.fromJson(Map<String, Object?> json) {
    final feed = json['feed'] as Map<String, Object?>?;
    final source = json['source'] as Map<String, Object?>?;
    final content = json['content'] as Map<String, Object?>?;
    final summary = json['summary'] as Map<String, Object?>?;
    final pointsJson = (summary?['points'] as List<Object?>? ?? const <Object?>[]);

    return SummaryItem(
      id: (json['_id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      author: (json['author'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
      feedTitle: feed?['title'] as String?,
      sourceDomain: source?['domain'] as String?,
      reads: (json['reads'] as num?)?.toInt(),
      publishedAt: _parseDate(json['publishedAt']),
      ingestedAt: _parseDate(json['ingestedAt']),
      imageUrl: content?['imageUrl'] as String?,
      points: pointsJson
          .whereType<Map<String, Object?>>()
          .map(SummaryPoint.fromJson)
          .toList(growable: false),
    );
  }
}

class SummaryPoint {
  const SummaryPoint({
    required this.heading,
    required this.bullets,
    required this.paragraph,
  });

  final String? heading;
  final List<String> bullets;
  final String? paragraph;

  factory SummaryPoint.fromJson(Map<String, Object?> json) {
    return SummaryPoint(
      heading: json['heading'] as String?,
      bullets: (json['bullets'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toList(growable: false),
      paragraph: json['paragraph'] as String?,
    );
  }
}

DateTime? _parseDate(Object? value) {
  final s = value as String?;
  if (s == null || s.isEmpty) return null;
  return DateTime.tryParse(s);
}
