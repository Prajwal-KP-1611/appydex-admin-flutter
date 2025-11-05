import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/shared/admin_sidebar.dart';
import '../../routes.dart';

class ReviewsListScreen extends ConsumerStatefulWidget {
  const ReviewsListScreen({super.key});

  @override
  ConsumerState<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends ConsumerState<ReviewsListScreen> {
  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: AppRoute.reviews,
      title: 'Reviews',
      child: Center(child: Text('Reviews List Placeholder')),
    );
  }
}
