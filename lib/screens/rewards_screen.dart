import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: const Center(
        child: Text(
          'Đổi thưởng',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

