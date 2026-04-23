import 'package:el7erafe/features/client_flow/reservation_history/data/repositories/previous_reservations_repo.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/previous_reservations_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PreviousReservationsCubit extends Cubit<PreviousReservationsState> {
  final PreviousReservationsRepo repository;

  PreviousReservationsCubit({required this.repository})
      : super(PreviousReservationsInitial());

  Future<void> fetchReservations() async {
    emit(PreviousReservationsLoading());
    try {
      final reservations = await repository.getPreviousReservations();
      emit(PreviousReservationsLoaded(reservations));
    } catch (e) {
      if (e.toString().contains('UNAUTH')) {
        emit(PreviousReservationsUnauth());
      } else {
        emit(PreviousReservationsError(
            e.toString().replaceAll("Exception: ", "")));
      }
    }
  }
}
