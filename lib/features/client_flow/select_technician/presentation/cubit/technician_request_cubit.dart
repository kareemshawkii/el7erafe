import 'package:el7erafe/features/client_flow/select_technician/data/repositories/select_technician_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el7erafe/features/client_flow/select_technician/data/models/request_model.dart';
import 'technician_request_state.dart'; 

class TechnicianRequestCubit extends Cubit<TechnicianRequestState> {
  final TechnicianRequestRepository _repository;

  TechnicianRequestCubit(this._repository) : super(TechnicianRequestInitial());

  void fetchTechnicians({
    required String service,
    required String city,
    required bool sort,
  }) async {
    emit(FetchTechniciansLoading());

    final result = await _repository.fetchCraftsmanData(service, city, sort);

    result.fold(
      (error) {
        if (error == "401 unauthorized") {
          emit(TechnicianRequestUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          emit(FetchTechniciansError(error));
        }
      },
      (data) {
        emit(FetchTechniciansSuccess(data));
      },
    );
  }

  void submitReservation(TechnicianReservationRequest request) async {
    emit(SubmitReservationLoading());

    final result = await _repository.submitTechnicianReservation(request);

    result.fold(
      (error) {
        if (error == "401 unauthorized") {
          emit(TechnicianRequestUnauth("انتهت صلاحية الجلسة، الرجاء تسجيل الدخول مرة أخرى."));
        } else if (error.startsWith("409 ")) {
            final String cleanMessage = error.replaceFirst("409 ", "");
            emit(ServiceRequestConflict(cleanMessage));
          }
        else {
          emit(SubmitReservationError(error));
        }
      },
      (successMessage) {
        emit(SubmitReservationSuccess(successMessage));
      },
    );
  }
}