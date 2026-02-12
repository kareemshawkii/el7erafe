import 'dart:io';
import 'package:el7erafe/features/client_flow/client_home/data/models/quick_reservation_request.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/data/repositories/quick_reserve_repo.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/cubit/quick_reserve_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  final ReservationRequest requestModel;
  final ImagePicker _picker = ImagePicker();
  final ServiceRequestRepository _repository = ServiceRequestRepository();

  ServiceRequestCubit(this.requestModel) : super(ServiceRequestInitial());

  Future<void> pickImage(ImageSource source) async {
    if ((requestModel.images?.length ?? 0) >= 4) {
      emit(ServiceRequestError("عفواً، الحد الأقصى 4 صور فقط"));
      return;
    }

    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      requestModel.images ??= [];
      requestModel.images!.add(File(image.path));
      emit(ServiceRequestImageUpdated());
    }
  }

  void removeImage(int index) {
    requestModel.images?.removeAt(index);
    emit(ServiceRequestImageUpdated());
  }

  void setGovernorate(String? governorate) {
    requestModel.governorate = governorate;
    requestModel.city = null;
    emit(ServiceRequestImageUpdated());
  }

  void setCity(String? city) {
    requestModel.city = city;
    emit(ServiceRequestImageUpdated());
  }

  void toggleAllDay(bool value) {
    requestModel.allDayAvailability = value;
    emit(ServiceRequestImageUpdated());
  }

  void submitQuickRequest() async {
    emit(ServiceRequestLoading());
    if (requestModel.description == null || requestModel.description!.isEmpty) {
      emit(ServiceRequestError("برجاء كتابة وصف للمشكلة"));
      return;
    }
    if (requestModel.day == null) {
      emit(ServiceRequestError("برجاء اختيار اليوم"));
      return;
    }
    if (!requestModel.allDayAvailability &&
        (requestModel.availableFrom == null ||
            requestModel.availableTo == null)) {
      emit(ServiceRequestError("برجاء تحديد الوقت المناسب"));
      return;
    }
    try {
      final result = await _repository.submitQuickReservation(requestModel);
      result.fold(
        (errorMsg) => emit(ServiceRequestError(errorMsg)),
        (successMsg) => emit(ServiceRequestSuccess()),
      );
    } catch (e) {
      emit(ServiceRequestError("حدث خطأ غير متوقع: $e"));
    }
  }
}
