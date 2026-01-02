import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: const Center(
        child: Text('Profile', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
