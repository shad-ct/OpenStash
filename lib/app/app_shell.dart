import 'dart:ui';
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
      extendBody: true,
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: _index,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: const Color(0xFF1D1D24).withOpacity(0.65),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(_index == 0 ? Icons.home_rounded : Icons.home_outlined), 
                  label: 'Home'
                ),
                BottomNavigationBarItem(
                  icon: Icon(_index == 1 ? Icons.explore_rounded : Icons.explore_outlined), 
                  label: 'Explore'
                ),
                BottomNavigationBarItem(
                  icon: Icon(_index == 2 ? Icons.library_books_rounded : Icons.library_books_outlined), 
                  label: 'Library'
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
