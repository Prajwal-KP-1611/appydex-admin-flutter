import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../core/utils/toast_service.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../models/plan.dart';
import '../../repositories/plan_repo.dart';
import '../../routes.dart';
import 'plan_form_dialog.dart';

/// Plans management screen
/// Displays all subscription plans with CRUD operations
class PlansListScreen extends ConsumerStatefulWidget {
  const PlansListScreen({super.key});

  @override
  ConsumerState<PlansListScreen> createState() => _PlansListScreenState();
}

class _PlansListScreenState extends ConsumerState<PlansListScreen> {
  bool? _filterActive;

  static const _filterKey = 'admin_plans_filter';

  @override
  void initState() {
    super.initState();
    // Load persisted filter and initial data
    Future.microtask(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final stored = prefs.getString(_filterKey);
        setState(() {
          _filterActive = stored == null
              ? null
              : stored == 'true'
              ? true
              : false;
        });
        await ref.read(plansProvider.notifier).load(isActive: _filterActive);
      } catch (_) {
        // Fallback to default load if prefs unavailable
        await ref.read(plansProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(plansProvider);

    return AdminScaffold(
      currentRoute: AppRoute.plans,
      title: 'Subscription Plans',
      actions: [
        // Filter dropdown
        PopupMenuButton<bool?>(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filter Plans',
          onSelected: (value) async {
            setState(() => _filterActive = value);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
              _filterKey,
              value == null ? 'all' : value.toString(),
            );
            ref.read(plansProvider.notifier).load(isActive: value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: null,
              child: Row(
                children: [
                  if (_filterActive == null)
                    const Icon(Icons.check, size: 16)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  const Text('All Plans'),
                ],
              ),
            ),
            PopupMenuItem(
              value: true,
              child: Row(
                children: [
                  if (_filterActive == true)
                    const Icon(Icons.check, size: 16)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  const Text('Active Only'),
                ],
              ),
            ),
            PopupMenuItem(
              value: false,
              child: Row(
                children: [
                  if (_filterActive == false)
                    const Icon(Icons.check, size: 16)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  const Text('Inactive/Legacy'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () => _showPlanDialog(context, ref, null),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Create Plan'),
        ),
        const SizedBox(width: 16),
      ],
      child: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load plans: $error'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.read(plansProvider.notifier).load(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (plans) {
          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _filterActive == null
                        ? 'No subscription plans yet'
                        : _filterActive!
                        ? 'No active plans'
                        : 'No inactive/legacy plans',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _showPlanDialog(context, ref, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Plan'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats cards
                Row(
                  children: [
                    _StatCard(
                      title: 'Total Plans',
                      value: plans.length.toString(),
                      icon: Icons.inventory_2,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      title: 'Active Plans',
                      value: plans.where((p) => p.isActive).length.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 16),
                    _StatCard(
                      title: 'Inactive Plans',
                      value: plans.where((p) => !p.isActive).length.toString(),
                      icon: Icons.archive,
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Plans table
                Card(
                  child: Column(
                    children: [
                      // Table header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Plan Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Code',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Price',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Duration',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Trial',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                'Actions',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table rows
                      ...plans.map(
                        (plan) => _PlanRow(
                          plan: plan,
                          onEdit: () => _showPlanDialog(context, ref, plan),
                          onDeactivate: () =>
                              _deactivatePlan(context, ref, plan),
                          onReactivate: () =>
                              _reactivatePlan(context, ref, plan),
                          onHardDelete: () =>
                              _hardDeletePlan(context, ref, plan),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPlanDialog(BuildContext context, WidgetRef ref, Plan? plan) {
    showDialog(
      context: context,
      builder: (context) => PlanFormDialog(plan: plan),
    );
  }

  Future<void> _deactivatePlan(
    BuildContext context,
    WidgetRef ref,
    Plan plan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Plan'),
        content: Text(
          'Are you sure you want to deactivate "${plan.name}"?\n\n'
          'This will set the plan to inactive. Existing subscriptions will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(plansProvider.notifier).deactivate(plan.id);
        if (context.mounted) {
          ToastService.showSuccess(
            context,
            'Plan "${plan.name}" deactivated successfully',
          );
        }
      } catch (error) {
        if (context.mounted) {
          ToastService.showError(context, 'Failed to deactivate plan: $error');
        }
      }
    }
  }

  Future<void> _hardDeletePlan(
    BuildContext context,
    WidgetRef ref,
    Plan plan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanently Delete Plan'),
        content: Text(
          'This will permanently delete "${plan.name}".\n\n'
          'Preconditions:\n'
          '• Plan must be inactive.\n'
          '• Plan must not be referenced by subscriptions or payments.\n\n'
          'This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(plansProvider.notifier).hardDelete(plan.id);
        if (context.mounted) {
          ToastService.showSuccess(context, 'Plan permanently deleted');
        }
      } catch (e) {
        final message = e.toString();
        if (message.contains('PLAN_ACTIVE_CANNOT_HARD_DELETE')) {
          ToastService.showError(
            context,
            'Deactivate the plan first before hard delete.',
          );
        } else if (message.contains('PLAN_IN_USE_CANNOT_HARD_DELETE')) {
          ToastService.showError(
            context,
            'Plan is referenced by subscriptions or payments.',
          );
        } else {
          ToastService.showError(context, 'Failed to hard delete plan');
        }
      }
    }
  }

  Future<void> _reactivatePlan(
    BuildContext context,
    WidgetRef ref,
    Plan plan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reactivate Plan'),
        content: Text(
          'Are you sure you want to reactivate "${plan.name}"?\n\n'
          'This will make the plan available for new subscriptions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Reactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(plansProvider.notifier).reactivate(plan.id);
        if (context.mounted) {
          ToastService.showSuccess(
            context,
            'Plan "${plan.name}" reactivated successfully',
          );
        }
      } catch (error) {
        if (context.mounted) {
          ToastService.showError(context, 'Failed to reactivate plan: $error');
        }
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.plan,
    required this.onEdit,
    required this.onDeactivate,
    required this.onReactivate,
    required this.onHardDelete,
  });

  final Plan plan;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;
  final VoidCallback onReactivate;
  final VoidCallback onHardDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (plan.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan.description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Text(
              plan.code,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            child: Text(
              plan.priceDisplay,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(plan.durationDisplay)),
          Expanded(
            child: Text(
              '${plan.trialDays ?? 0} days',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 100,
            child: Chip(
              label: Text(
                plan.isActive ? 'Active' : 'Inactive',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: plan.isActive
                  ? Colors.green.shade100
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  tooltip: 'Edit Plan',
                ),
                if (plan.isActive)
                  IconButton(
                    onPressed: onDeactivate,
                    icon: Icon(
                      Icons.visibility_off,
                      size: 20,
                      color: AppTheme.dangerRed,
                    ),
                    tooltip: 'Delete (Deactivate) Plan',
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        onPressed: onReactivate,
                        icon: Icon(
                          Icons.restore,
                          size: 20,
                          color: Colors.green,
                        ),
                        tooltip: 'Reactivate Plan',
                      ),
                      IconButton(
                        onPressed: onHardDelete,
                        icon: Icon(
                          Icons.delete_forever,
                          size: 20,
                          color: AppTheme.dangerRed,
                        ),
                        tooltip: 'Hard Delete (Permanent)',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
