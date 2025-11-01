import 'package:flutter/material.dart';

class FilterRow extends StatelessWidget {
  const FilterRow({super.key, required this.children, this.showBorder = true});

  final List<Widget> children;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: showBorder
            ? Border.all(color: theme.dividerColor.withValues(alpha: 0.2))
            : null,
      ),
      child: Wrap(spacing: 12, runSpacing: 12, children: children),
    );
  }
}
