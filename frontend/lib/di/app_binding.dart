import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/device/data/repositories/device_repository_impl.dart';
import '../features/device/domain/repositories/device_repository.dart';
import '../features/device/presentation/bloc/device_bloc.dart';
import '../features/dashboard/data/mock_health_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  sl.registerLazySingleton(() => Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.67:3000', // Update with your IP if running on device
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  ));

  // Services
  sl.registerLazySingleton(() => MockHealthService());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<DeviceRepository>(() => DeviceRepositoryImpl());

  // Blocs
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => DeviceBloc(sl()));
}
