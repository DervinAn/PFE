import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

// ─── Events ───────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email];
}

class SignupEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String? phone;
  const SignupEvent({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
  });
  @override
  List<Object?> get props => [email, fullName];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

// ─── States ───────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignup);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      emit(
        Authenticated(
          UserEntity(id: 'u1', fullName: 'Amira Mansour', email: event.email),
        ),
      );
    } catch (e) {
      emit(AuthError('Invalid credentials'));
    }
  }

  Future<void> _onSignup(SignupEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(
        Authenticated(
          UserEntity(id: 'u1', fullName: event.fullName, email: event.email),
        ),
      );
    } catch (e) {
      emit(AuthError('Signup failed'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(Unauthenticated());
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Check shared preferences / secure storage for token
    // For demo, always unauthenticated on cold start
    emit(Unauthenticated());
  }
}
