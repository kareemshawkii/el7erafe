import 'dart:io';
import 'package:el7erafe/features/client_flow/client_home/data/models/quick_reservation_request.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/data/repositories/quick_reserve_repo.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/cubit/quick_reserve_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  final ReservationRequest requestModel;
  final ImagePicker _picker = ImagePicker();
  final ServiceRequestRepository _repository = ServiceRequestRepository();

  ServiceRequestCubit(this.requestModel) : super(ServiceRequestInitial());

  Future<File> _compressImage(File file) async {
    int size = file.lengthSync();
    if (size <= 1024 * 1024) return file;
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );
    return result != null ? File(result.path) : file;
  }

  Future<void> pickImage(ImageSource source) async {
    if ((requestModel.images?.length ?? 0) >= 4) {
      emit(ServiceRequestError("عفواً، الحد الأقصى 4 صور فقط"));
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        File originalFile = File(image.path);
        File compressedFile = await _compressImage(originalFile);
        if (compressedFile.lengthSync() == 0) {
          emit(ServiceRequestError(
              "حدث خطأ أثناء معالجة الصورة. الرجاء المحاولة مرة أخرى."));
          return;
        }

        requestModel.images ??= [];
        requestModel.images!.add(compressedFile);
        emit(ServiceRequestImageUpdated());
      }
    } catch (e) {
      emit(ServiceRequestError("حدث خطأ أثناء اختيار الصورة."));
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
        (failure) {
          if (failure.contains("unauthorized") || failure.contains("401")) {
            emit(ServiceRequestUnauthorized(
                "انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى"));
          } else if (failure.startsWith("409 ")) {
            final String cleanMessage = failure.replaceFirst("409 ", "");
            emit(ServiceRequestConflict(cleanMessage));
          } else {
            emit(ServiceRequestError(failure));
          }
        },
        (success) => emit(ServiceRequestSuccess()),
      );
    } catch (e) {
      emit(ServiceRequestError("حدث خطأ غير متوقع: ${e.toString()}"));
    }
  }
}
