import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smoke_smarter_app/features/auth/presentation/screens/login_screen.dart';
import 'package:smoke_smarter_app/features/auth/presentation/screens/register_screen.dart';
import 'package:smoke_smarter_app/features/auth/providers/auth_providers.dart';
import 'package:smoke_smarter_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:smoke_smarter_app/features/interests/presentation/screens/interests_screen.dart';
import 'package:smoke_smarter_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:smoke_smarter_app/features/progress/presentation/screens/progress_screen.dart';
import 'package:smoke_smarter_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:smoke_smarter_app/features/user_profile/providers/user_profile_providers.dart';
import 'package:smoke_smarter_app/shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Routes that don't require authentication.
const _unauthRoutes = {'/onboarding', '/login', '/register'};

GoRouter buildAppRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final isLoggedIn = ref.read(authStateProvider).valueOrNull != null;
      final loc = state.matchedLocation;

      // Not logged in → only unauth routes allowed
      if (!isLoggedIn) {
        return _unauthRoutes.contains(loc) ? null : '/login';
      }

      // Logged in → redirect away from unauth routes
      if (_unauthRoutes.contains(loc)) {
        final profileAsync = ref.read(userProfileProvider);
        // Profile still loading — stay put; _RouterNotifier will re-trigger
        // once Firestore responds so we can decide correctly then.
        if (profileAsync.isLoading) return null;
        final hasInterests = profileAsync.valueOrNull?.hasInterests ?? false;
        return hasInterests ? '/dashboard' : '/interests';
      }

      // Logged in + on /interests (first-time setup) —
      // if profile already has interests, skip to dashboard.
      if (loc == '/interests') {
        final profileAsync = ref.read(userProfileProvider);
        if (profileAsync.hasValue &&
            (profileAsync.valueOrNull?.hasInterests ?? false)) {
          return '/dashboard';
        }
        return null;
      }

      // Logged in + on /interests/edit → always allow (coming from Settings)
      if (loc == '/interests/edit') return null;

      // Logged in + on any other protected route → ensure interests are done
      final profileAsync = ref.read(userProfileProvider);
      if (profileAsync.hasValue) {
        final hasInterests = profileAsync.valueOrNull?.hasInterests ?? false;
        if (!hasInterests) return '/interests';
      }

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
      GoRoute(
        path: '/interests',
        builder: (context, state) => const InterestsScreen(),
      ),
      GoRoute(
        path: '/interests/edit',
        builder: (context, state) => const InterestsScreen(isEditing: true),
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

/// Notifies GoRouter whenever auth state or user profile changes.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(userProfileProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>(buildAppRouter);
