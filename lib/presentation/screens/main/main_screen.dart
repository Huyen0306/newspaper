import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:iconsax/iconsax.dart';
import '../news/news_screen.dart';
import '../saved/saved_screen.dart';
import '../rewards/rewards_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const NewsScreen(),
    const SavedScreen(),
    const RewardsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          Icon(Iconsax.document_text, size: 26, color: Colors.white),
          Icon(Iconsax.bookmark, size: 26, color: Colors.white),
          Icon(Iconsax.gift, size: 26, color: Colors.white),
          Icon(Iconsax.profile_circle, size: 26, color: Colors.white),
        ],
        color: Color(0xFF1e293b),
        buttonBackgroundColor: Color(0xFF1e293b),
        backgroundColor: Colors.white,
        animationCurve: Curves.linear,
        animationDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}
