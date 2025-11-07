import 'package:flutter/material.dart';

class ReviewDetailScreen extends StatelessWidget {
  const ReviewDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement review detail with Hide/Remove/Restore actions, moderation dialog
    return Scaffold(
      appBar: AppBar(title: const Text('Review Detail')),
      body: Center(child: Text('Review detail with moderation actions')),
    );
  }
}
