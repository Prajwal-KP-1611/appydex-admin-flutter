import 'core/config.dart';

enum AppRoute {
  login('/login'),
  dashboard('/dashboard'),
  analytics('/analytics'),
  admins('/admins'),
  vendors('/vendors'),
  vendorDetail('/vendors/detail'),
  users('/users'),
  services('/services'),
  serviceTypeRequests('/service-type-requests'),
  plans('/plans'),
  subscriptions('/subscriptions'),
  campaigns('/campaigns'),
  reviews('/reviews'),
  payments('/payments'),
  audit('/audit'),
  reports('/reports'),
  diagnostics('/diagnostics');

  const AppRoute(this.path);
  final String path;
  
  /// Check if route should be available in current flavor
  bool get isAvailable {
    // Hide diagnostics in production
    if (this == AppRoute.diagnostics && kAppFlavor == 'prod') {
      return false;
    }
    return true;
  }
}
