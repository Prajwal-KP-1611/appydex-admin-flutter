enum AppRoute {
  diagnostics('/diagnostics'),
  login('/login'),
  dashboard('/dashboard'),
  vendors('/vendors'),
  services('/services'),
  plans('/plans'),
  bookings('/bookings'),
  subscriptions('/subscriptions');

  const AppRoute(this.path);
  final String path;
}
