import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<String> register(String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl(this.dio, this.sharedPreferences);

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['access_token'];
      await sharedPreferences.setString('token', token);
      return token;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> register(String email, String password) async {
    try {
      final response = await dio.post('/auth/register', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['access_token'];
      await sharedPreferences.setString('token', token);
      return token;
    } catch (e) {
      throw ServerException();
    }
  }
}
