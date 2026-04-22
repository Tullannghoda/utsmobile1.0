class AppConstants {
  AppConstants._();

  // Roles
  static const String roleUser = 'user';
  static const String roleHelpdesk = 'helpdesk';
  static const String roleAdmin = 'admin';

  // Ticket Status
  static const String statusOpen = 'open';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';
  static const String statusClosed = 'closed';

  // Routes
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeDashboard = '/dashboard';
  static const String routeTicketList = '/tickets';
  static const String routeTicketDetail = '/ticket-detail';
  static const String routeCreateTicket = '/create-ticket';
  static const String routeProfile = '/profile';
  static const String routeNotification = '/notification';

  // SharedPreferences Keys
  static const String keyToken = 'token';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserRole = 'user_role';
  static const String keyThemeMode = 'theme_mode';

  // App Info
  static const String appName = 'E-Helpdesk';
  static const String appVersion = '1.0.0';
}