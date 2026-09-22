import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analysis/presentation/category_page.dart';
import '../../features/analysis/presentation/compass_page.dart';
import '../../features/analysis/presentation/measurements_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/onboarding/presentation/splash_page.dart';
import '../../features/plans/presentation/plans_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/reports/presentation/report_preview_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../theme/app_colors.dart';
import '../widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => const NoTransitionPage(child: SplashPage()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _fadePage(state, const OnboardingPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => const NoTransitionPage(child: ReportsPage()),
          ),
          GoRoute(
            path: '/plans',
            pageBuilder: (context, state) => const NoTransitionPage(child: PlansPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),
      GoRoute(
        path: '/analysis/categories',
        pageBuilder: (context, state) => _slidePage(state, const CategoryPage()),
      ),
      GoRoute(
        path: '/analysis/compass',
        pageBuilder: (context, state) => _slidePage(state, const CompassPage()),
      ),
      GoRoute(
        path: '/analysis/measurements',
        pageBuilder: (context, state) => _slidePage(state, const MeasurementsPage()),
      ),
      GoRoute(
        path: '/report/preview',
        pageBuilder: (context, state) => _slidePage(state, const ReportPreviewPage()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.ivory,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_outlined, size: 58, color: AppColors.gold),
              const SizedBox(height: 14),
              Text('This direction is unavailable', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(state.error?.toString() ?? 'The requested page could not be opened.'),
              const SizedBox(height: 18),
              FilledButton(onPressed: () => context.go('/home'), child: const Text('Return home')),
            ],
          ),
        ),
      ),
    ),
  );
});

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}

