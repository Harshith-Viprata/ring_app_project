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
import 'config/routes/app_routes.dart';

import 'package:yc_product_plugin/yc_product_plugin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  // Initialize YC SDK
  YcProductPlugin().initPlugin(isReconnectEnable: true, isLogEnable: true);
  
  runApp(const MyApp());
}

final _router = AppRoutes.router;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Check for existing token
    di.sl<AuthBloc>().add(CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => di.sl<DeviceBloc>()),
        BlocProvider(create: (context) => di.sl<HealthBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _router.go(AppRoutes.home);
          } else if (state is AuthInitial) {
            _router.go(AppRoutes.login);
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Ring App Project',
          theme: AppTheme.lightTheme,
          routerConfig: _router,
        ),
      ),
    );
  }
}
