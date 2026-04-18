import 'package:flutter/material.dart';

import 'package:lsp_mkc_app/pages/home_page.dart';
// import 'package:lsp_mkc_app/pages/history_page.dart';
// import 'package:lsp_mkc_app/pages/profile_page.dart';

// import 'package:lsp_mkc_app/lib/core/custom_bottom_navbar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    // HistoryPage(),
    // ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      // bottomNavigationBar: CustomBottomNavBar(
      //   currentIndex: _currentIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //   },
      // ),
    );
  }
}
