import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_navigation_viewmodel.dart';
import '../viewmodels/publication_viewmodel.dart';
import 'about_screen.dart';
import 'overview_screen.dart';
import 'search_screen.dart';
import 'trend_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _pages = [
    OverviewScreen(),
    TrendScreen(),
    SearchScreen(),
    AboutScreen(),
    ProfileScreen(),

  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PublicationViewModel>();
      if (!provider.hasData && !provider.isDashboardLoading) {
        provider.loadDefaultDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppNavigationViewModel>();

    return Scaffold(
      body: IndexedStack(
        index: nav.tabIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.tabIndex,
        onDestinationSelected: (index) {
          context.read<AppNavigationViewModel>().goToTab(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'About',
          ),

          NavigationDestination(
    icon: Icon(Icons.person_outline),
    selectedIcon: Icon(Icons.person),
    label: 'Profile',
  ),
        ],
      ),
    );
  }
}
