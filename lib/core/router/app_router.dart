import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smoke_smarter_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:smoke_smarter_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:smoke_smarter_app/features/progress/presentation/screens/progress_screen.dart';
import 'package:smoke_smarter_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:smoke_smarter_app/shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
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
