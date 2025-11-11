import 'package:appydex_admin/core/pagination.dart';
import 'package:appydex_admin/features/vendors/vendors_list_screen.dart';
import 'package:appydex_admin/models/vendor.dart';
import 'package:appydex_admin/providers/mock_admin_fallback.dart';
import 'package:appydex_admin/providers/vendors_provider.dart';
import 'package:appydex_admin/repositories/vendor_repo.dart';
import 'package:appydex_admin/widgets/data_table_simple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _FakeVendorRepository extends VendorRepository {
  _FakeVendorRepository() : super(null as dynamic);
  final Pagination<Vendor> _page = Pagination<Vendor>(
    items: [
      Vendor(
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
      ),
    ],
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
    return _page;
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
  testWidgets('renders vendor list and triggers verify action', (tester) async {
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
        ],
        child: const MaterialApp(home: VendorsListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.byType(DataTableSimple), findsOneWidget);

    await tester.tap(find.text('Verify').first);
    await tester.pumpAndSettle();

    expect(fakeRepo.statusCalls, 1);
  });
}
