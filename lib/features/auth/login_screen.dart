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

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _loginSuccessful = false; // Prevent UI reset during navigation

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Clear any error state on init
    _errorMessage = null;

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
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
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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
          final apiUrl = ref.read(apiClientProvider).dio.options.baseUrl;
          message =
              '🌐 Cannot connect to server.\n\nPlease ensure the backend is running at:\n$apiUrl';
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
              AppTheme.primaryDeepBlue.withOpacity(0.85),
              AppTheme.primaryDeepBlue.withOpacity(0.7),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    elevation: 24,
                    shadowColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.surface,
                            theme.colorScheme.surface.withOpacity(0.95),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Logo and branding
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primaryDeepBlue.withOpacity(0.1),
                                      AppTheme.primaryDeepBlue.withOpacity(
                                        0.05,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 72,
                                  color: AppTheme.primaryDeepBlue,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'AppyDex Admin',
                                style: textTheme.headlineLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Platform Control Center',
                                style: textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),

                              // Error message with animation
                              if (_errorMessage != null &&
                                  _errorMessage!.trim().isNotEmpty) ...[
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 300),
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Opacity(
                                        opacity: value,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.shade50,
                                          Colors.red.shade100.withOpacity(0.5),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.red.shade300,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.shade200
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.error_outline_rounded,
                                            color: Colors.red.shade700,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: Colors.red.shade900,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.5,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Email/Phone input with enhanced styling
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                style: textTheme.bodyLarge,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  _passwordFocusNode.requestFocus();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Email or Phone',
                                  labelStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  hintText: 'admin@appydex.com',
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.3),
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(12),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryDeepBlue
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.email_rounded,
                                      color: AppTheme.primaryDeepBlue,
                                      size: 20,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryDeepBlue,
                                      width: 2.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.error,
                                      width: 2.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email or phone is required';
                                  }
                                  if (!value.contains('@') &&
                                      value.length < 8) {
                                    return 'Enter a valid email or phone';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Password input with enhanced styling
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                obscureText: _obscurePassword,
                                style: textTheme.bodyLarge,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleLogin(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  hintText: '••••••••',
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.3),
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(12),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryDeepBlue
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.lock_rounded,
                                      color: AppTheme.primaryDeepBlue,
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        size: 20,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
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
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: AppTheme.primaryDeepBlue,
                                      width: 2.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.error,
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.error,
                                      width: 2.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // Login button with gradient and animation
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: _isLoading
                                      ? LinearGradient(
                                          colors: [
                                            AppTheme.primaryDeepBlue
                                                .withOpacity(0.7),
                                            AppTheme.primaryDeepBlue
                                                .withOpacity(0.6),
                                          ],
                                        )
                                      : LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            AppTheme.primaryDeepBlue,
                                            AppTheme.primaryDeepBlue
                                                .withOpacity(0.85),
                                          ],
                                        ),
                                  boxShadow: _isLoading
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: AppTheme.primaryDeepBlue
                                                .withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: _isLoading
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      Colors.white.withOpacity(
                                                        0.9,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Logging in...',
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.login_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Sign In',
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Security notice
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shield_rounded,
                                    size: 16,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Secured with 256-bit encryption',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }
}
