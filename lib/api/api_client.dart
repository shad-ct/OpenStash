import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models/summary.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    this.baseUrl = 'https://btlearn.up.railway.app',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<SummariesPage> getSummaries({int page = 1, int limit = 20}) async {
    final uri = Uri.parse('$baseUrl/api/summaries').replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
      },
    );

    final res = await _client.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('GET /api/summaries failed (${res.statusCode})');
    }

    if (kIsWeb) {
      final json = jsonDecode(res.body) as Map<String, Object?>;
      return SummariesPage.fromJson(json);
    }

    return compute(_decodeSummariesPage, res.body);
  }

  Future<SummaryItem> getSummaryById(String id, {bool includeRaw = false}) async {
    final uri = Uri.parse('$baseUrl/api/summaries/$id').replace(
      queryParameters: includeRaw ? const {'includeRaw': 'true'} : null,
    );

    final res = await _client.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException('GET /api/summaries/:id failed (${res.statusCode})');
    }

    if (kIsWeb) {
      final json = jsonDecode(res.body) as Map<String, Object?>;
      return SummaryItem.fromJson(json);
    }

    return compute(_decodeSummaryItem, res.body);
  }
}

SummariesPage _decodeSummariesPage(String body) {
  final json = jsonDecode(body) as Map<String, Object?>;
  return SummariesPage.fromJson(json);
}

SummaryItem _decodeSummaryItem(String body) {
  final json = jsonDecode(body) as Map<String, Object?>;
  return SummaryItem.fromJson(json);
}

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}
