import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/technician_calender_model.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/repositories/tech_calender_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/cubit/tech_calender_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TechCalendarCubit extends Cubit<TechCalendarState> {
  final TechCalendarRepo repository;
  DateTime _selectedDate = DateTime.now();

  TechCalendarCubit({required this.repository}) : super(TechCalendarInitial());

  void fetchReservationsForDate(DateTime date) async {
    _selectedDate = date;
    emit(TechCalendarLoading());

    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final result = await repository.getCalendarReservations(formattedDate);

    if (isClosed) return;

    result.fold(
      (error) {
        if (error == "401") {
          emit(TechCalendarUnauthorized());
        } else {
          emit(TechCalendarError(error));
        }
      },
      (reservations) {
        final sortedList = List<TechReservationModel>.from(reservations);
        sortedList.sort((a, b) =>
            (a.techTimeInterval ?? '').compareTo(b.techTimeInterval ?? ''));
        emit(TechCalendarLoaded(sortedList, _selectedDate));
      },
    );
  }

  void startJob(int reservationId) async {
    emit(ActionLoading());

    final result = await repository.startJob(reservationId);

    if (isClosed) return;

    result.fold(
      (error) {
        if (error == "401") {
          emit(TechCalendarUnauthorized());
        } else {
          emit(ActionError(error));
          fetchReservationsForDate(_selectedDate);
        }
      },
      (successMessage) {
        emit(ActionSuccess(successMessage));
        fetchReservationsForDate(_selectedDate);
      },
    );
  }
}
