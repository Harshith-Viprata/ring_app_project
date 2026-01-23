import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'di/app_binding.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/device/presentation/bloc/device_bloc.dart';
import 'features/health/presentation/bloc/health_bloc.dart';
import 'features/home/presentation/pages/main_scaffold_page.dart';
import 'features/health/presentation/pages/ecg_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/device/presentation/pages/scanning_page.dart';
import 'config/theme/app_theme.dart';

import 'package:yc_product_plugin/yc_product_plugin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  // Initialize YC SDK
  YcProductPlugin().initPlugin(isReconnectEnable: true, isLogEnable: true);
  
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/login', // TODO: Check token
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScaffoldPage(),
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ScanningPage(), // Deprecated/Hidden
    ),
    GoRoute(
      path: '/ecg',
      builder: (context, state) => const ECGPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => di.sl<DeviceBloc>()),
        BlocProvider(create: (context) => di.sl<HealthBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Ring App Project',
        theme: AppTheme.darkTheme,
        routerConfig: _router,
      ),
    );
  }
}
