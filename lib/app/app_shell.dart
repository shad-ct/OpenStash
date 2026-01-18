import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../repositories/summary_repository.dart';
import '../screens/explore_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';


class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.apiClient,
    this.repository,
    this.testMode = false,
  });

  final ApiClient? apiClient;
  final SummaryRepository? repository;
  final bool testMode;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final PageStorageBucket _bucket = PageStorageBucket();

  late final SummaryRepository _repo =
      widget.repository ?? SummaryRepository(api: widget.apiClient ?? ApiClient());

  late final List<Widget> _screens = [
    HomeScreen(apiClient: widget.apiClient, repository: _repo, testMode: widget.testMode),
    ExploreScreen(apiClient: widget.apiClient, repository: _repo),
    const LibraryScreen(),
  ];

  @override
  void dispose() {
    _repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: _index,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), label: 'Library'),
        ],
      ),
    );
  }
}
