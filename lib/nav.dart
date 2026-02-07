import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wanderlog/pages/alerts/alerts_page.dart';
import 'package:wanderlog/pages/auth/login_page.dart';
import 'package:wanderlog/pages/auth/register_page.dart';
import 'package:wanderlog/pages/disbursements/disbursements_page.dart';
import 'package:wanderlog/pages/home/dashboard_page.dart';
import 'package:wanderlog/pages/profile/profile_page.dart';
import 'package:wanderlog/pages/settings/merchant_config_page.dart';
import 'package:wanderlog/theme.dart';

/// GoRouter configuration for app navigation
class AppRouter {
  // Navigator keys to keep state of each tab
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // Reserved for future nested routing per section.
  // ignore: unused_field
  static final _sectionNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    routes: [
      // Authentication routes (outside main navigation)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: RegisterPage(),
        ),
      ),

      // Main app routes with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.disbursements,
                name: 'disbursements',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DisbursementsPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.alerts,
                name: 'alerts',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AlertsPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfilePage(),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.merchantConfig,
                    name: 'merchantConfig',
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: MerchantConfigPage(
                        api: state.extra as dynamic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String disbursements = '/disbursements';
  static const String alerts = '/alerts';
  static const String profile = '/profile';
  static const String merchantConfig = 'config';
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          backgroundColor: Theme.of(context).cardTheme.color,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon:
                  Icon(Icons.dashboard_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon:
                  Icon(Icons.payments_rounded, color: AppColors.primary),
              label: 'Payouts',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon:
                  Icon(Icons.notifications_rounded, color: AppColors.primary),
              label: 'Alerts',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon:
                  Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
