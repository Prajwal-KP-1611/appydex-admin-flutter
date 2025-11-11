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
  userId: 101,
  companyName: 'Acme Corp',
  slug: 'acme-corp',
  status: 'pending',
  createdAt: DateTime(2024, 1, 1),
  metadata: const {
    'contact_email': 'owner@acme.test',
    'contact_phone': '+9100000000',
  },
  documents: const [],
);

class _FakeVendorRepository extends VendorRepository {
  _FakeVendorRepository() : super(null as dynamic);

  final Pagination<Vendor> _page = Pagination<Vendor>(
    items: [_baseVendor],
    total: 1,
    page: 1,
    pageSize: 20,
  );

  int statusCalls = 0;

  @override
  Future<Vendor> get(int id) async => _page.items.first;

  @override
  Future<Pagination<Vendor>> list({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? query,
  }) async {
    return Pagination<Vendor>(
      items: [_baseVendor],
      total: 1,
      page: 1,
      pageSize: 20,
    );
  }

  Future<VendorStatusChangeResult> _emitStatus({
    required int id,
    required String status,
    String? notes,
  }) async {
    statusCalls++;
    return VendorStatusChangeResult(
      vendorId: id,
      status: status,
      previousStatus: 'pending',
      verifiedAt: DateTime.now(),
      notes: notes,
    );
  }

  @override
  Future<VendorStatusChangeResult> verifyOrReject({
    required int id,
    required String status,
    String? notes,
  }) => _emitStatus(id: id, status: status, notes: notes);

  @override
  Future<VendorStatusChangeResult> verify(int id, {String? notes}) =>
      _emitStatus(id: id, status: 'verified', notes: notes);

  @override
  Future<VendorStatusChangeResult> reject(int id, {required String reason}) =>
      _emitStatus(id: id, status: 'rejected', notes: reason);

  @override
  Future<List<VendorDocument>> getDocuments(int vendorId) async => [];
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

    expect(fakeRepo.statusCalls, 1);
  });
}
