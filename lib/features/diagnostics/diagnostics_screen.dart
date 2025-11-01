import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart'
    show
        RefreshAttempt,
        lastRefreshAttemptProvider,
        lastRequestFailureProvider,
        lastTraceIdProvider,
        LastRequestFailure;
import '../../core/auth/auth_controller.dart';
import '../../core/config.dart';
import 'diagnostics_controller.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key, required this.initialBaseUrl});

  final String initialBaseUrl;

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  late final TextEditingController _baseUrlController;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(text: widget.initialBaseUrl);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diagnosticsState = ref.watch(diagnosticsControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final mockMode = ref.watch(mockModeProvider);
    final baseUrl = ref.watch(apiBaseUrlProvider);
    final lastFailure = ref.watch(lastRequestFailureProvider);
    final lastTrace = ref.watch(lastTraceIdProvider);
    final lastRefreshAttempt = ref.watch(lastRefreshAttemptProvider);

    if (_baseUrlController.text != baseUrl) {
      _baseUrlController.value = _baseUrlController.value.copyWith(
        text: baseUrl,
      );
    }

    final cards = <Widget>[
      _buildBaseUrlCard(context, diagnosticsState),
      _buildHealthCard(context, diagnosticsState),
      _buildDnsCard(context, diagnosticsState),
      _buildOtpUnavailableCard(context),
      _buildTokenCard(
        context,
        diagnosticsState,
        authState,
        lastRefreshAttempt,
        baseUrl,
      ),
      _buildLastFailureCard(context, lastFailure, lastTrace),
      _buildMockModeCard(context, mockMode),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          if (isWide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: (constraints.maxWidth - 48) / 2,
                        child: card,
                      ),
                    )
                    .toList(),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final card in cards) ...[card, const SizedBox(height: 24)],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBaseUrlCard(BuildContext context, DiagnosticsState state) {
    final theme = Theme.of(context);
    final controller = ref.read(diagnosticsControllerProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API Base URL', style: theme.textTheme.displayMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Override base URL',
                hintText: 'https://api.appydex.co',
              ),
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _handleSaveBaseUrl(controller),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: state.isSavingBaseUrl
                      ? null
                      : () => _handleSaveBaseUrl(controller),
                  child: state.isSavingBaseUrl
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save override'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await controller.resetBaseUrl();
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Base URL reset')),
                    );
                  },
                  child: const Text('Reset to default'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(BuildContext context, DiagnosticsState state) {
    final controller = ref.read(diagnosticsControllerProvider.notifier);
    final theme = Theme.of(context);
    final result = state.healthResult;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Healthz', style: theme.textTheme.displayMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: result.isLoading ? null : controller.pingHealthz,
              child: result.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ping /healthz'),
            ),
            const SizedBox(height: 12),
            result.when(
              data: (data) => _diagnosticResultContent(
                context,
                data,
                emptyLabel: 'Health check not run yet.',
              ),
              loading: () => const Text('Running health check...'),
              error: (error, _) => Text(
                'Health check error: $error',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDnsCard(BuildContext context, DiagnosticsState state) {
    final controller = ref.read(diagnosticsControllerProvider.notifier);
    final theme = Theme.of(context);
    final result = state.dnsResult;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DNS', style: theme.textTheme.displayMedium),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: result.isLoading ? null : controller.runDnsCheck,
              child: result.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Run DNS lookup'),
            ),
            const SizedBox(height: 12),
            result.when(
              data: (data) {
                if (data == null) {
                  return const Text('DNS lookup not run yet.');
                }
                final statusColor = data.success
                    ? const Color(0xFF00A86B)
                    : theme.colorScheme.error;
                final latency = data.latency.inMilliseconds > 0
                    ? '${data.latency.inMilliseconds} ms'
                    : 'n/a';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.success ? 'Resolved' : 'Failed',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Latency: $latency'),
                    if (data.addresses.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Addresses: ${data.addresses.join(', ')}'),
                    ],
                    if (data.message != null) ...[
                      const SizedBox(height: 8),
                      Text(data.message!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                );
              },
              loading: () => const Text('Running DNS lookup...'),
              error: (error, _) => Text(
                'DNS error: $error',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpUnavailableCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last OTP', style: theme.textTheme.displayMedium),
            const SizedBox(height: 12),
            Tooltip(
              message:
                  'Not available on this backend — request backend debug endpoint if needed.',
              child: ElevatedButton(
                onPressed: null,
                child: const Text('Fetch latest OTP'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This environment does not expose a last-OTP endpoint.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenCard(
    BuildContext context,
    DiagnosticsState diagnosticsState,
    AuthState authState,
    RefreshAttempt? lastAttempt,
    String baseApiUrl,
  ) {
    final controller = ref.read(diagnosticsControllerProvider.notifier);
    final authController = ref.read(authControllerProvider.notifier);
    final theme = Theme.of(context);
    final accessToken = authState.tokens?.accessToken;
    final refreshToken = authState.tokens?.refreshToken;
    final isLoadingRefresh = diagnosticsState.refreshResult.isLoading;
    final manualResult = diagnosticsState.refreshResult;
    final isAutoAttempt = lastAttempt?.source == 'auto';
    final autoResult = lastAttempt == null || !isAutoAttempt
        ? null
        : buildDiagnosticResult(
            url:
                lastAttempt.response?.requestOptions.uri.toString() ??
                '$baseApiUrl/auth/refresh',
            response: lastAttempt.response,
            error: lastAttempt.error,
            latency: null,
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tokens', style: theme.textTheme.displayMedium),
            const SizedBox(height: 12),
            Text('Access: ${maskToken(accessToken)}'),
            const SizedBox(height: 8),
            Text('Refresh: ${maskToken(refreshToken)}'),
            if (authState.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                authState.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isLoadingRefresh
                      ? null
                      : controller.forceRefreshToken,
                  child: isLoadingRefresh
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Force refresh token'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: authState.isAuthenticated
                      ? authController.logout
                      : null,
                  child: const Text('Clear tokens'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Manual refresh result', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            manualResult.when(
              data: (data) => _diagnosticResultContent(
                context,
                data,
                emptyLabel: 'Manual refresh not run yet.',
              ),
              loading: () => const Text('Requesting refresh...'),
              error: (error, _) => Text(
                '$error',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            if (autoResult != null) ...[
              const SizedBox(height: 16),
              Text('Last automatic refresh', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              _diagnosticResultContent(
                context,
                autoResult,
                emptyLabel: 'No automatic refresh recorded.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLastFailureCard(
    BuildContext context,
    LastRequestFailure? failure,
    String? lastTrace,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Request Failure', style: theme.textTheme.displayMedium),
            const SizedBox(height: 12),
            if (failure == null)
              const Text('All clear. No failed requests recorded.')
            else ...[
              Text(
                '${failure.method} ${failure.statusCode ?? 'n/a'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(failure.url),
              const SizedBox(height: 8),
              SelectableText(
                'Trace ID: ${failure.traceId ?? 'n/a'}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (failure.responseBody != null)
                SelectableText(
                  failure.responseBody!,
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _copyToClipboard(failure.toCurl()),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy curl'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: failure.traceId == null
                        ? null
                        : () => _copyToClipboard(failure.traceId!),
                    child: const Text('Copy trace ID'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Last trace ID: ${lastTrace ?? 'n/a'}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockModeCard(BuildContext context, bool mockMode) {
    final controller = ref.read(diagnosticsControllerProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: mockMode,
          onChanged: (value) => controller.toggleMockMode(value),
          title: const Text('Mock mode (dev only)'),
          subtitle: const Text(
            'Simulate backend responses for local QA. Requires app restart.',
          ),
        ),
      ),
    );
  }

  Widget _diagnosticResultContent(
    BuildContext context,
    DiagnosticCallResult? result, {
    required String emptyLabel,
  }) {
    final theme = Theme.of(context);
    if (result == null) {
      return Text(emptyLabel);
    }

    final statusColor = result.isSuccess
        ? const Color(0xFF00A86B)
        : theme.colorScheme.error;
    final latencyLabel = result.latency != null
        ? '${result.latency!.inMilliseconds} ms'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status: ${result.statusLabel}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SelectableText('URL: ${result.url}'),
        if (latencyLabel != null) ...[
          const SizedBox(height: 8),
          Text('Latency: $latencyLabel'),
        ],
        const SizedBox(height: 8),
        SelectableText('Trace ID: ${result.traceId ?? 'n/a'}'),
        if (result.errorMessage != null) ...[
          const SizedBox(height: 8),
          SelectableText(
            result.errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (result.hint != null) ...[
          const SizedBox(height: 8),
          Text(
            result.hint!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (result.bodyPreview != null) ...[
          const SizedBox(height: 8),
          SelectableText(result.bodyPreview!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _copyToClipboard(result.url),
              icon: const Icon(Icons.link),
              label: const Text('Copy URL'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: result.traceId == null
                  ? null
                  : () => _copyToClipboard(result.traceId!),
              child: const Text('Copy trace ID'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleSaveBaseUrl(DiagnosticsController controller) async {
    final value = _baseUrlController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    await controller.applyBaseUrl(value);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          value.isEmpty
              ? 'Cleared base URL override.'
              : 'Base URL updated to $value',
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(String value) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }
}

String maskToken(String? token) {
  if (token == null || token.isEmpty) return '****';
  if (token.length <= 8) {
    return '${token.substring(0, 2)}****${token.substring(token.length - 2)}';
  }
  return '${token.substring(0, 4)}****${token.substring(token.length - 4)}';
}
