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
    int skip = 0,
    int limit = 100,
    String? status,
    String? search,
  }) async {
    return Pagination<Vendor>(
      items: [_baseVendor],
      total: 1,
      page: 1,
      pageSize: 20,
    );
  }

  @override
  Future<Vendor> patch(int id, Map<String, dynamic> changes) async {
    return _baseVendor.copyWith(
      isVerified: changes['is_verified'] as bool? ?? _baseVendor.isVerified,
      isActive: changes['is_active'] as bool? ?? _baseVendor.isActive,
      notes: changes['notes'] as String? ?? _baseVendor.notes,
    );
  }

  @override
  Future<VendorVerificationResult> verifyOrReject({
    required int id,
    required String action,
    String? notes,
  }) async {
    return VendorVerificationResult(
      vendorId: id,
      status: action == 'approve' ? 'verified' : 'rejected',
      verifiedAt: DateTime.now(),
      notes: notes,
    );
  }

  @override
  Future<Vendor> verify(int id, {String? notes}) async {
    patchCalls++;
    return _page.items.first.copyWith(isVerified: true, notes: notes);
  }

  @override
  Future<Vendor> reject(int id, {required String reason}) async {
    patchCalls++;
    return _page.items.first.copyWith(isVerified: false, notes: reason);
  }

  @override
  Future<List<VendorDocument>> getDocuments(int vendorId) async => [];

  @override
  Future<List<Vendor>> bulkVerify(List<int> vendorIds, {String? notes}) async =>
      [];
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
