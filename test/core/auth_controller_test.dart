import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:appydex_admin/core/auth/auth_controller.dart';
import 'package:appydex_admin/core/auth/auth_repository.dart';
import 'package:appydex_admin/core/auth/token_storage.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

Future<void> _flush() => pumpEventQueue();

void main() {
  late ProviderContainer container;
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initialises as authenticated when cached tokens exist', () async {
    const tokens = TokenPair(
      accessToken: 'cached-access',
      refreshToken: 'cached-refresh',
    );
    when(() => repository.loadTokens()).thenAnswer((_) async => tokens);

    final state = container.read(authControllerProvider);
    expect(state.status, AuthStatus.unknown);

    await _flush();

    final updated = container.read(authControllerProvider);
    expect(updated.status, AuthStatus.authenticated);
    expect(updated.tokens, tokens);
  });

  test('falls back to unauthenticated when no tokens found', () async {
    when(() => repository.loadTokens()).thenAnswer((_) async => null);

    container.read(authControllerProvider);
    await _flush();

    final updated = container.read(authControllerProvider);
    expect(updated.status, AuthStatus.unauthenticated);
    expect(updated.tokens, isNull);
  });

  test('refreshTokens updates state when repository returns tokens', () async {
    const refreshed = TokenPair(
      accessToken: 'fresh-access',
      refreshToken: 'fresh-refresh',
    );
    when(() => repository.loadTokens()).thenAnswer((_) async => null);
    when(() => repository.forceRefresh()).thenAnswer((_) async => refreshed);

    final controller = container.read(authControllerProvider.notifier);
    await controller.refreshTokens();

    final state = container.read(authControllerProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.tokens, refreshed);
    verifyNever(() => repository.clearTokens());
  });

  test('refreshTokens keeps session when repository returns null', () async {
    when(() => repository.loadTokens()).thenAnswer((_) async => null);
    when(() => repository.forceRefresh()).thenAnswer((_) async => null);

    final controller = container.read(authControllerProvider.notifier);
    await controller.refreshTokens();

    final state = container.read(authControllerProvider);
    expect(state.status, AuthStatus.unauthenticated);
    expect(state.tokens, isNull);
    verifyNever(() => repository.clearTokens());
  });

  test('refreshTokens surfaces errors', () async {
    when(() => repository.loadTokens()).thenAnswer((_) async => null);
    when(() => repository.forceRefresh()).thenThrow(Exception('network'));

    final controller = container.read(authControllerProvider.notifier);

    await _flush();

    await expectLater(controller.refreshTokens(), throwsA(isA<Exception>()));

    await _flush();

    final state = container.read(authControllerProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, contains('Exception: network'));
  });
}
