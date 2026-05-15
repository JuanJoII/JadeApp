import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/monitoring/monitoring_screen.dart';
import 'features/monitoring/jade_overlay_screen.dart';
import 'features/routines/routines_screen.dart';
import 'features/routines/deep_work_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/settings/settings_screen.dart';
import 'widgets/main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/monitoring',
          builder: (context, state) => const MonitoringScreen(),
        ),
        GoRoute(
          path: '/routines',
          builder: (context, state) => const RoutinesScreen(),
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
    GoRoute(
      path: '/overlay',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const JadeOverlayScreen(),
    ),
    GoRoute(
      path: '/deep-work',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DeepWorkScreen(),
    ),
  ],
);
