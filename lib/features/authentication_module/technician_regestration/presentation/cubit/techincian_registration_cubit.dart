import 'dart:io';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/model/technician_registration_model.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_registration_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianRegistrationCubit extends Cubit<TechnicianRegistrationState> {
  final TechnicianRegRepository technicianRegRepository;

  TechnicianRegistrationCubit({required this.technicianRegRepository})
      : super(TechnicianRegInitial());

  Future<void> loadServices() async {
    emit(TechnicianRegLoading());
    final result = await technicianRegRepository.getServices();
    result.fold(
      (failure) => emit(TechnicianRegServicesFailure(error: failure.message)),
      (services) => emit(TechnicianRegServicesLoaded(services: services)),
    );
  }

  Future<void> register(
      String name,
      String phone,
      String email,
      String password,
      File profileImage,
      File frontIdImage,
      File backIdImage,
      File criminalRecordImage,
      String governorate,
      String city,
      String serviceType) async {
    emit(TechnicianRegLoading());

    final requestModel = TechnicianRegistrationRequestModel(
      name: name,
      phoneNumber: phone,
      email: email,
      password: password,
      profileImage: profileImage,
      frontIdImage: frontIdImage,
      backIdImage: backIdImage,
      criminalRecordImage: criminalRecordImage,
      governorate: governorate,
      city: city,
      serviceType: serviceType,
    );

    final result =
        await technicianRegRepository.registerTechnician(requestModel);

    result.fold(
      (failure) {
        if (failure.message.contains('BLOCKED')) {
          emit(TecnicianRegBlocked(
              message:
                  'تم حظر حسابك. الرجاء التواصل مع الدعم لمزيد من المعلومات.'));
        } else {
          emit(TechnicianRegFailure(error: failure.message));
        }
      },
      (success) => emit(TechnicianRegSuccess()),
    );
  }
}
