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
  final int? height;
  final int? weight;
  final int? gender;
  final String? birthDate;

  RegisterRequested(
    this.email, 
    this.password, {
    this.height,
    this.weight,
    this.gender,
    this.birthDate,
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class GetProfileRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

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

class ProfileLoaded extends AuthState {
  final Map<String, dynamic> user;
  ProfileLoaded(this.user);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>((event, emit) async {
       emit(AuthLoading());
       try {
         final token = await authRepository.getToken();
         if (token != null) {
           emit(AuthAuthenticated(token));
         } else {
           emit(AuthInitial());
         }
       } catch (e) {
         emit(AuthInitial());
       }
    });

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
        final token = await authRepository.register(
            event.email, 
            event.password,
            height: event.height,
            weight: event.weight,
            gender: event.gender,
            birthDate: event.birthDate,
        );
        emit(AuthAuthenticated(token));
      } catch (e) {
        emit(AuthFailure("Registration failed: ${e.toString()}"));
      }
    });

    on<GetProfileRequested>((event, emit) async {
       emit(AuthLoading());
       try {
         final user = await authRepository.getProfile();
         emit(ProfileLoaded(user));
       } catch (e) {
         emit(AuthFailure("Failed to load profile"));
       }
    });
  }
}
