import 'package:appydex_admin/core/pagination.dart';
import 'package:appydex_admin/features/vendors/vendor_detail_screen.dart';
import 'package:appydex_admin/models/vendor.dart';
import 'package:appydex_admin/providers/mock_admin_fallback.dart';
import 'package:appydex_admin/providers/vendors_provider.dart';
import 'package:appydex_admin/repositories/vendor_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _baseVendor = Vendor(
  id: 1,
  name: 'Acme Corp',
  ownerEmail: 'owner@acme.test',
  phone: '+9100000000',
  planCode: 'pro',
  isActive: true,
  isVerified: false,
  onboardingScore: 0.9,
  createdAt: DateTime(2024, 1, 1),
  notes: 'Demo vendor',
);

class _FakeVendorRepository implements VendorRepository {
  final Pagination<Vendor> _page = Pagination<Vendor>(
    items: [_baseVendor],
    total: 1,
    page: 1,
    pageSize: 20,
  );

  int patchCalls = 0;

  @override
  Future<Vendor> get(int id) async => _page.items.first;

  @override
  Future<Pagination<Vendor>> list({
    String? query,
    String? status,
    String? planCode,
    bool? verified,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int page = 1,
    int pageSize = 20,
  }) async => _page;

  @override
  Future<Vendor> patch(int id, Map<String, dynamic> changes) async {
    patchCalls++;
    return _page.items.first.copyWith(
      isVerified:
          changes['is_verified'] as bool? ?? _page.items.first.isVerified,
      notes: changes['notes'] as String? ?? _page.items.first.notes,
      isActive: changes['is_active'] as bool? ?? _page.items.first.isActive,
    );
  }
}

void main() {
  testWidgets('vendor detail verify flow triggers notifier', (tester) async {
    final fakeRepo = _FakeVendorRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vendorsProvider.overrideWith(
            (ref) => VendorsNotifier(
              ref,
              repository: fakeRepo,
              fallback: const MockAdminFallback(),
            ),
          ),
          vendorDetailProvider.overrideWith((ref, id) async => _baseVendor),
          vendorServicesProvider.overrideWith((ref, id) async => const []),
          vendorAvailabilityProvider.overrideWith((ref, id) async => const []),
          vendorBookingsProvider.overrideWith((ref, id) async => const []),
          vendorLeadsProvider.overrideWith((ref, id) async => const []),
          vendorReviewsProvider.overrideWith((ref, id) async => const []),
          vendorAuditProvider.overrideWith((ref, id) async => const []),
        ],
        child: const MaterialApp(
          home: VendorDetailScreen(args: VendorDetailArgs(vendorId: 1)),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Acme Corp'), findsOneWidget);

    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();

    expect(fakeRepo.patchCalls, 1);
  });
}
