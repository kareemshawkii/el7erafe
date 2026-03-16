import 'package:el7erafe/features/technician_flow/tech_profile/data/models/tech_schedule_model.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/data/repositories/tech_schedule_repository.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/cubit/tech_schedule_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechScheduleCubit extends Cubit<TechScheduleState> {
  final TechScheduleRepository repository;
  List<TechScheduleModel> currentSchedule = [];

  TechScheduleCubit({required this.repository}) : super(TechScheduleInitial());

  void fetchSchedule(String token) async {
    emit(TechScheduleLoading());
    final result = await repository.getSchedule(token);
    result.fold(
      (error) {
        if (error == "401") {
          emit(TechScheduleUnauthorized());
        } else {
          emit(TechScheduleError(error));
        }
      },
      (schedule) {
        currentSchedule = schedule;
        emit(TechScheduleLoaded(schedule));
      },
    );
  }

  void updateSchedule(String token, List<TechScheduleModel> schedule) async {
    emit(TechScheduleUpdateLoading());
    final result = await repository.updateSchedule(token, schedule);
    result.fold(
      (error) {
        if (error == "401") {
          emit(TechScheduleUnauthorized());
        } else {
          emit(TechScheduleError(error));
          emit(TechScheduleLoaded(currentSchedule));
        }
      },
      (successMessage) {
        emit(TechScheduleUpdateSuccess(successMessage));
        fetchSchedule(token);
      },
    );
  }
}
