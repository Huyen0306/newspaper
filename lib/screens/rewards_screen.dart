import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: const CustomAppBar(
        title: 'Đổi thưởng',
      ),
      body: const Center(
        child: Text(
          'Đổi thưởng',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

