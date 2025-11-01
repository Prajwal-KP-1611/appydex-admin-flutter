enum AppRoute {
  dashboard('/dashboard'),
  vendors('/vendors'),
  vendorDetail('/vendors/detail'),
  subscriptions('/subscriptions'),
  audit('/audit'),
  diagnostics('/diagnostics');

  const AppRoute(this.path);
  final String path;
}
