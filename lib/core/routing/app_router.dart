import 'package:go_router/go_router.dart';

import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/dashboard/resident_dashboard_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login', // Starting point per memory context before navigating
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const ResidentDashboardScreen(),
      ),
      // Future routes can be added here
    ],
    // Basic redirect logic to simulate auth state if needed, skipping for now per task scope
  );
}
