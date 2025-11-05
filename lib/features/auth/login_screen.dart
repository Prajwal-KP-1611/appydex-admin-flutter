import '../../core/auth/otp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme.dart';
import '../../core/navigation/last_route.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _otpRequested = false;
  bool _loginSuccessful = false; // Prevent UI reset during navigation

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final otpRepo = ref.read(otpRepositoryProvider);
      final result = await otpRepo.requestOtp(
        emailOrPhone: _emailController.text.trim(),
      );

      // Persist OTP requested state
      setState(() {
        _otpRequested = true;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on OtpException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to request OTP. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController(text: '000000');

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Clear any error state on init
    _errorMessage = null;
    _loadLastEmail();
  }

  Future<void> _loadLastEmail() async {
    try {
      final authService = ref.read(authServiceProvider);
      final lastEmail = await authService.getLastEmail();
      if (lastEmail != null && mounted) {
        _emailController.text = lastEmail;
      }
    } catch (e) {
      // Silently fail if we can't load last email
      // This is not critical for login functionality
      debugPrint('Could not load last email: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Synchronously check and set loading flag to prevent race conditions
    if (_isLoading) {
      debugPrint('[LoginScreen] Duplicate submission blocked');
      return;
    }

    _isLoading = true; // Set synchronously before setState

    if (!_formKey.currentState!.validate()) {
      _isLoading = false;
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      await ref
          .read(adminSessionProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            otp: _otpController.text.trim(),
          );

      // Mark login as successful to prevent UI from resetting
      if (mounted) {
        setState(() {
          _loginSuccessful = true;
        });
      }

      // Persist last route and navigate by clearing the stack to avoid
      // returning to the login screen via back or stale hash.
      if (mounted) {
        // ignore: unawaited_futures
        LastRoute.write('/dashboard');
        // Use a slight delay to ensure state update completes
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
        }
      }
    } catch (e) {
      String message = 'Login failed. Please check your credentials.';

      if (e is AppHttpException) {
        // Use the backend error message and make it user-friendly
        final backendMessage = e.message.toUpperCase();

        if (backendMessage.contains('INVALID_CREDENTIALS') ||
            backendMessage.contains('INVALID CREDENTIALS') ||
            backendMessage.contains('UNAUTHORIZED')) {
          message =
              '❌ Invalid email or password.\n\nPlease check your credentials and try again.';
        } else if (backendMessage.contains('NOT_FOUND') ||
            backendMessage.contains('NOT FOUND')) {
          message = '❌ Account not found.\n\nPlease check your email address.';
        } else if (backendMessage.contains('LOCKED') ||
            backendMessage.contains('DISABLED') ||
            backendMessage.contains('SUSPENDED')) {
          message =
              '🔒 Account locked or disabled.\n\nPlease contact support for assistance.';
        } else if (backendMessage.contains('OTP') ||
            backendMessage.contains('2FA')) {
          message =
              '🔐 Two-factor authentication required.\n\nPlease check your device or email.';
        } else {
          // Use the backend message but make it readable
          message =
              '⚠️ Login failed.\n\n${e.message.replaceAll('_', ' ').toLowerCase()}';
        }
      } else {
        // Handle network and other errors
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('failed host lookup') ||
            errorStr.contains('connection refused') ||
            errorStr.contains('socketexception') ||
            errorStr.contains('network')) {
          message =
              '🌐 Cannot connect to server.\n\nPlease ensure the backend is running at:\nhttp://localhost:16110';
        } else if (errorStr.contains('timeout')) {
          message =
              '⏱️ Request timed out.\n\nPlease check your network connection and try again.';
        } else if (errorStr.contains('invalid_credentials')) {
          message =
              '❌ Invalid email or password.\n\nPlease check your credentials and try again.';
        } else {
          // For debugging: show a cleaner error message
          final cleanError = e
              .toString()
              .replaceAll('DioException [bad response]: null\n', '')
              .replaceAll('Error: ', '')
              .replaceAll('AppHttpException(', '')
              .replaceAll('statusCode:', '\nStatus:')
              .replaceAll('traceId:', '\nTrace ID:')
              .replaceAll('message:', '\nMessage:')
              .replaceAll(')', '');
          message = '⚠️ Login Error:\n$cleanError';
        }
      }

      if (mounted) {
        setState(() {
          _errorMessage = message;
          _loginSuccessful = false; // Reset on error
        });
      }
    } finally {
      _isLoading = false; // Reset synchronously
      if (mounted) {
        setState(() {
          // Ensure login successful is false if we had an error
          if (_errorMessage != null) {
            _loginSuccessful = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Show loading screen if login was successful to prevent UI from resetting
    if (_loginSuccessful) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryDeepBlue,
                AppTheme.primaryDeepBlue.withOpacity(0.8),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Logging in...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryDeepBlue,
              AppTheme.primaryDeepBlue.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 64,
                          color: AppTheme.primaryDeepBlue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AppyDex Admin',
                          style: textTheme.displaySmall?.copyWith(
                            // Improve contrast in both light and dark themes
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Platform Control Center',
                          style: textTheme.bodyMedium?.copyWith(
                            // Use onSurface with opacity to adapt to theme brightness
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        if (_errorMessage != null &&
                            _errorMessage!.trim().isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.red.shade900,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Step 1: Email/Phone input and Request OTP
                        if (!_otpRequested) ...[
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email or Phone',
                              prefixIcon: Icon(Icons.email_outlined),
                              hintText: 'root@appydex.com or +1234567890',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email or phone is required';
                              }
                              // Simple check for email or phone
                              if (!value.contains('@') && value.length < 8) {
                                return 'Enter a valid email or phone';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _requestOtp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Request OTP'),
                          ),
                        ],

                        // Step 2: OTP and Password input, Login
                        if (_otpRequested) ...[
                          // Show email that OTP was sent to
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.colorScheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'OTP sent to: ${_emailController.text.trim()}',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _otpRequested = false;
                                      _otpController.clear();
                                      _errorMessage = null;
                                    });
                                  },
                                  child: const Text('Change'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'OTP (One-Time Password)',
                              prefixIcon: Icon(Icons.pin_outlined),
                              hintText: '000000',
                              helperText:
                                  'Enter the OTP sent to your email or phone',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'OTP is required';
                              }
                              if (value.length != 6) {
                                return 'OTP must be 6 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 22,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.75),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        ],

                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentEmerald.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.accentEmerald.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppTheme.accentEmerald,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Default Admin Credentials',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: AppTheme.accentEmerald,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Email: admin@appydex.local',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.85),
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                'Password: admin123!@#',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.85),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
