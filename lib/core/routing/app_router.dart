import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/dashboard/syndic_dashboard_screen.dart';
import '../../presentation/screens/dashboard/resident_dashboard_screen.dart';
import '../../presentation/screens/appartements/appartements_screen.dart';
import '../../presentation/screens/paiements/paiements_screen.dart';
import '../../presentation/screens/paiements/payment_form_screen.dart';
import '../../presentation/screens/incidents/incidents_screen.dart';
import '../../presentation/screens/incidents/incident_detail_screen.dart';
import '../../presentation/screens/documents/documents_screen.dart';
import '../../presentation/screens/ag/ag_list_screen.dart';
import '../../presentation/screens/ag/ag_presence_screen.dart';
import '../../presentation/screens/ag/ag_votes_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/dashboard/notice_board_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      final session = authState.value?.session;
      final isAuthenticated = session != null;

      if (!isAuthenticated && state.uri.toString() != '/login') {
        return '/login';
      }

      if (isAuthenticated && (state.uri.toString() == '/login' || state.uri.toString() == '/')) {
        // Read directly from current session to avoid async issues in redirect
        final role = session.user.appMetadata?['role'] as String?;
        if (role == 'syndic' || role == 'president' || role == 'tresorier') {
          return '/dashboard/syndic';
        } else {
          return '/dashboard/resident';
        }
      }

      // Role Guards
      if (isAuthenticated) {
        final role = session.user.appMetadata?['role'] as String?;
        final isAdmin = role == 'syndic' || role == 'president' || role == 'tresorier';

        final adminRoutes = ['/appartements', '/paiements', '/documents', '/settings'];
        if (!isAdmin && adminRoutes.any((r) => state.uri.toString().startsWith(r))) {
          return '/dashboard/resident'; // Redirect to their safe dashboard
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard/syndic',
        builder: (context, state) => const SyndicDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/resident',
        builder: (context, state) => const ResidentDashboardScreen(),
      ),
      GoRoute(
        path: '/appartements',
        builder: (context, state) => const AppartementsScreen(),
      ),
      GoRoute(
        path: '/paiements',
        builder: (context, state) => const PaiementsScreen(),
      ),
      GoRoute(
        path: '/paiements/new',
        builder: (context, state) => const PaymentFormScreen(),
      ),
      GoRoute(
        path: '/incidents',
        builder: (context, state) => const IncidentsScreen(),
      ),
      GoRoute(
        path: '/incidents/:id',
        builder: (context, state) => IncidentDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: '/ag',
        builder: (context, state) => const AgListScreen(),
      ),
      GoRoute(
        path: '/ag/:id/presence',
        builder: (context, state) => AgPresenceScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ag/:id/votes',
        builder: (context, state) => AgVotesScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notice-board',
        builder: (context, state) => const NoticeBoardScreen(),
      ),
    ],
  );
});
