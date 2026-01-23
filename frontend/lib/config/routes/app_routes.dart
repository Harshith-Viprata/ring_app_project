import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/main_scaffold_page.dart';
import '../../features/health/presentation/pages/ecg_page.dart';
import '../../features/device/presentation/pages/scanning_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String scan = '/scan';
  static const String ecg = '/ecg';

  static final GoRouter router = GoRouter(
    initialLocation: login, // TODO: Check token for auto-login
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const MainScaffoldPage(),
      ),
      GoRoute(
        path: scan,
        name: 'scan',
        builder: (context, state) => const ScanningPage(),
      ),
      GoRoute(
        path: ecg,
        name: 'ecg',
        builder: (context, state) => const ECGPage(),
      ),
    ],
  );
}
