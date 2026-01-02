import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: const Center(
        child: Text(
          'Báo mới',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

