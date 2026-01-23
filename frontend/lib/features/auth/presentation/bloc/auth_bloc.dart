import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  RegisterRequested(this.email, this.password);
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String token;
  AuthAuthenticated(this.token);
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authRepository.login(event.email, event.password);
        emit(AuthAuthenticated(token));
      } catch (e) {
        emit(AuthFailure("Login failed"));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authRepository.register(event.email, event.password);
        emit(AuthAuthenticated(token));
      } catch (e) {
        emit(AuthFailure("Registration failed: ${e.toString()}"));
      }
    });
  }
}
