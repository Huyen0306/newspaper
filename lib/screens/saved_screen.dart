import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: const Center(
        child: Text(
          'Đã lưu',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

