// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openstash/api/api_client.dart';
import 'package:openstash/app/app_shell.dart';

void main() {
  testWidgets('Bottom nav exists and tab switching preserves state', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/summaries') {
        final items = List.generate(100, (i) {
          return {
            "_id": "id_$i",
            "title": "Title $i",
            "author": "Author $i",
            "url": "https://example.com/$i",
            "feed": {"title": "Feed"},
            "source": {"domain": "example.com"},
            "summary": {
              "version": 1,
              "points": [
                {"heading": "H", "bullets": ["B1"], "paragraph": ""}
              ]
            }
          };
        });

        final body = jsonEncode({
          'items': items,
          'pageInfo': {'page': 1, 'limit': 20, 'total': 30, 'hasNext': false},
        });
        return http.Response(
          body,
          200,
          headers: const {'content-type': 'application/json'},
        );
      }
      return http.Response('{"message":"Not found"}', 404);
    });

    await tester.pumpWidget(MaterialApp(
      home: AppShell(apiClient: ApiClient(client: mockClient), testMode: true),
      debugShowCheckedModeBanner: false,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Scroll Home feed down so an older item is visible.
    expect(find.text('Title 0'), findsOneWidget);
    await tester.fling(find.byType(Scrollable), const Offset(0, -900), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Title 0'), findsNothing);

    // Switch to Explore and back; Home should preserve scroll position.
    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.home_filled));
    await tester.pumpAndSettle();
    expect(find.text('Title 0'), findsNothing);
  });
}
