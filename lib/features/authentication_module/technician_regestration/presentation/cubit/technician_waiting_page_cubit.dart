import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_waititng_page_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianStatusCubit extends Cubit<TechnicianStatusState> {
  AuthLocalStorage authLocalStorage = AuthLocalStorage();
  final TechnicianRegRepository statusRepository;

  TechnicianStatusCubit({required this.statusRepository})
      : super(TechnicianStatusInitial());

  Future<void> checkApprovalStatus() async {
    emit(TechnicianStatusLoading());

    final String? tempToken = await authLocalStorage.getTempToken();
    if (tempToken == null || tempToken.isEmpty) {
      emit(TechnicianStatusError(error: 'الرمز المؤقت غير موجود. الرجاء تسجيل الدخول مرة أخرى.'));
      return;
    }
    final result = await statusRepository.checkTechnicianStatus(tempToken);

    result.fold(
      (failure) {
        if (failure.message.contains('PENDING') || failure.message.contains('REJECTED')) {
           final message = failure.message.contains('PENDING') ?
             'طلبك بيتراجع حاليا وهنرد عليك خلال 24 ساعة....' :
             'تم رفض طلبك. برجاء مراجعه الملفات المرفقه ومحاولة التسجيل مرة أخرى.';
           final statusType = failure.message.contains('PENDING') ? 'تحت المراجعة' : 'مرفوض';
           emit(TechnicianStatusDenied(
             message: message,
             status: statusType,
           ));
        } else if (failure.message.contains('BLOCKED')) {
          emit(TechnicianStatusBlocked(
            message: 'تم حظر حسابك. الرجاء التواصل مع الدعم لمزيد من المعلومات.',
          ));
        }
        else {
           emit(TechnicianStatusError(error: failure.message));
        }
      },
      (success) {
        emit(TechnicianStatusApproved());
      },
    );
  }
}