import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_google.dart';
import '../../domain/usecases/sign_out.dart';
// import '../../domain/usecases/sign_up.dart'; // we can just reuse sign-in params for sign up, but wait we didn't export SignUp separately, it's in sign_up.dart oh wait, I put SignUp in sign_in_up.dart 
// Let's import the right file for SignUp
import '../../domain/usecases/sign_in_up.dart' as sign_up_usecase;
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser getCurrentUser;
  final SignIn signIn;
  final sign_up_usecase.SignUp signUp;
  final SignInGoogle signInGoogle;
  final SignOut signOut;

  AuthBloc({
    required this.getCurrentUser,
    required this.signIn,
    required this.signUp,
    required this.signInGoogle,
    required this.signOut,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final result = await getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(const AuthError('Failed to get current user.')),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signIn(SignInParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signUp(SignInParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthGoogleSignInRequested(AuthGoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signInGoogle(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signOut(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
