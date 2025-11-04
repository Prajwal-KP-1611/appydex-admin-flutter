import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/utils/toast_service.dart';
import '../../features/shared/admin_sidebar.dart';
import '../../models/plan.dart';
import '../../repositories/plan_repo.dart';
import '../../routes.dart';
import 'plan_form_dialog.dart';

/// Plans management screen
/// Displays all subscription plans with CRUD operations
class PlansListScreen extends ConsumerWidget {
  const PlansListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansProvider);

    return AdminScaffold(
      currentRoute: AppRoute.plans,
      title: 'Subscription Plans',
      actions: [
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
                onPressed: () => ref.refresh(plansProvider),
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
                  const Text(
                    'No subscription plans yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
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
                      title: 'Total Subscribers',
                      value: plans
                          .fold<int>(
                            0,
                            (sum, p) => sum + (p.subscriberCount ?? 0),
                          )
                          .toString(),
                      icon: Icons.people,
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
                          color: Colors.grey.shade100,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade300),
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
                                'Billing Period',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Subscribers',
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
  });

  final Plan plan;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
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
          Expanded(child: Text(plan.billingPeriodDisplay)),
          Expanded(
            child: Text(
              plan.subscriberCount?.toString() ?? '0',
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
                  : Colors.grey.shade200,
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
                      Icons.block,
                      size: 20,
                      color: AppTheme.dangerRed,
                    ),
                    tooltip: 'Deactivate Plan',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
