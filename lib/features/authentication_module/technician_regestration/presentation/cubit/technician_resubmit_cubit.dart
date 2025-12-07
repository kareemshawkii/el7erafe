import 'package:el7erafe/core/services/models/rejected_user.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/model/rejected_technician_model.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_resubmit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianResubmitCubit extends Cubit<TechnicianResubmitState> {
  final TechnicianRegRepository technicianRegRepository;

  TechnicianResubmitCubit({required this.technicianRegRepository})
      : super(TechnicianResubmitInitial());

  Future<void> resubmitTechnicianRegistration(
  RejectedTechnicianModel requestModel,
  RejectedUser rejectedUser,
) async {
  emit(TechnicianResubmitLoading());

  final result = await technicianRegRepository.resubmitTechnicianFiles(
    requestModel,
    rejectedUser,
  );

  result.fold(
    (failure) {
      if (failure.message == 'BLOCKED') {
        emit(TechnicianResubmitBlocked(
          message: 'تم حظر حسابك ولا يمكنك إعادة التقديم.',
        ));
      } 
      else {
        emit(TechnicianResubmitFailure(error: failure.message));
      }
    },
    (success) {
      emit(TechnicianResubmitSuccess());
    },
  );
}


}