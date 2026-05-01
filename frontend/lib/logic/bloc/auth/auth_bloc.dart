import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);
    on<AuthProfilePhotoUpdated>(_onAuthProfilePhotoUpdated);
    on<AuthProfilePhotoDeleted>(_onAuthProfilePhotoDeleted);
    on<AuthChangePasswordRequested>(_onAuthChangePasswordRequested);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final hasToken = await authRepository.hasToken();
    if (hasToken) {
      try {
        final user = await authRepository.getMe();
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        // If token is invalid or expired
        await authRepository.logout();
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.username, event.password);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.register(event.username, event.email, event.password);
      // Auto login after register
      final user = await authRepository.login(event.username, event.password);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthUpdateProfileRequested(AuthUpdateProfileRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      try {
        final updatedUser = await authRepository.updateProfile(event.username, event.email);
        emit(AuthAuthenticated(user: updatedUser));
      } catch (e) {
        emit(AuthError(e.toString()));
        // Kembalikan ke state sebelumnya agar UI tidak nge-blank
        emit(AuthAuthenticated(user: currentState.user));
      }
    }
  }

  Future<void> _onAuthChangePasswordRequested(AuthChangePasswordRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      try {
        await authRepository.changePassword(event.oldPassword, event.newPassword);
        // Bisa dispatch event sukses jika ada UI yang mendengarkan, atau biarkan state tetap Authenticated
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(AuthAuthenticated(user: currentState.user));
      }
    }
  }

  Future<void> _onAuthProfilePhotoUpdated(AuthProfilePhotoUpdated event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      try {
        final updatedUser = await authRepository.uploadProfilePhoto(event.image);
        emit(AuthAuthenticated(user: updatedUser));
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(AuthAuthenticated(user: currentState.user));
      }
    }
  }

  Future<void> _onAuthProfilePhotoDeleted(AuthProfilePhotoDeleted event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      try {
        final updatedUser = await authRepository.deleteProfilePhoto();
        emit(AuthAuthenticated(user: updatedUser));
      } catch (e) {
        emit(AuthError(e.toString()));
        emit(AuthAuthenticated(user: currentState.user));
      }
    }
  }
}
