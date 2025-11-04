enum AppRoute {
  login('/login'),
  dashboard('/dashboard'),
  admins('/admins'),
  vendors('/vendors'),
  vendorDetail('/vendors/detail'),
  users('/users'),
  services('/services'),
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
}
