import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRepository {
  Future<String> login(String email, String password);
  Future<String> register(String email, String password);
}

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;

  AuthRepositoryImpl(this.dio);

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['access_token'];
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
      return response.data['access_token'];
    } catch (e) {
      throw ServerException();
    }
  }
}
