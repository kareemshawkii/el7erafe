import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  LoginCubit({required this.authRepository}) : super(AuthInitial());
  Future<void> login(String phoneNumber, String password) async {
    emit(AuthLoading());
    final result = await authRepository.login(phoneNumber, password);
    result.fold(
      (failure) {
        if (failure.message == "OTP") {
          emit(OtpSent());
        } else if (failure.message == "TECHNICIANOTP") {
          emit(TechnicianOtpSent());
        } else if (failure.message == "PENDING") {
          emit(AuthPending());
        } else if (failure.message == "REJECTED") {
          emit(AuthRejected());
        } else if (failure.message == "BLOCKED") {
          emit(AuthBlocked(error: "تم حظر حسابك. يرجى التواصل مع الدعم."));
        } else {
          emit(AuthFailure(error: failure.message));
        }
      },
      (user) => emit(AuthSuccess()),
    );
  }
}
