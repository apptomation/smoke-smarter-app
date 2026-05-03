import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smoke_smarter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:smoke_smarter_app/features/auth/presentation/screens/register_screen.dart';
import 'package:smoke_smarter_app/features/auth/providers/auth_providers.dart';
import 'package:smoke_smarter_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:smoke_smarter_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:smoke_smarter_app/features/progress/presentation/screens/progress_screen.dart';
import 'package:smoke_smarter_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:smoke_smarter_app/shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Public routes that do NOT require authentication.
const _publicRoutes = {'/onboarding', '/login', '/register'};

GoRouter buildAppRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isPublic = _publicRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !isPublic) return '/login';
      if (isLoggedIn && isPublic) return '/dashboard';
      return null;
    },
    refreshListenable: _RouterNotifier(ref),
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Notifies GoRouter whenever the Firebase auth state changes.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>(buildAppRouter);
