import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: const Center(
        child: Text(
          'Đổi thưởng',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

