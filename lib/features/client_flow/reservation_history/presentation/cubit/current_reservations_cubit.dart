import 'package:el7erafe/features/client_flow/reservation_history/data/models/current_reservation_model.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/repositories/current_reservations_repo.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/current_reservations_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentReservationsCubit extends Cubit<CurrentReservationsState> {
  final CurrentReservationsRepo repository;
  List<CurrentReservationModel> _currentList = [];

  CurrentReservationsCubit({required this.repository})
      : super(CurrentInitial());

  Future<void> initialize() async {
    await fetchReservations();
    await _connectSignalR();
  }

  Future<void> fetchReservations() async {
    emit(CurrentLoading());
    try {
      _currentList = await repository.getCurrentReservations();
      if (!isClosed) emit(CurrentLoaded(_currentList));
    } catch (e) {
      if (e.toString().contains('UNAUTH')) {
        if (!isClosed) emit(CurrentUnauth());
      } else {
        if (!isClosed) {
          emit(CurrentError(e.toString().replaceAll('Exception: ', '')));
        }
      }
    }
  }

  Future<void> _connectSignalR() async {
    await repository.connectToHub(
      onJobStarted: (id) => _refreshReservationsSilently(),
      onJobCompleted: (id) => _refreshReservationsSilently(),
      onReservationCancelled: (id) => _refreshReservationsSilently(),
      onHttpFallback: (fallbackList) {
        _currentList = fallbackList;
        if (!isClosed) {
          emit(CurrentLoaded(List.from(_currentList)));
        }
      },
    );
  }

  Future<void> _refreshReservationsSilently() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      _currentList = await repository.getCurrentReservations();
      if (!isClosed) {
        emit(CurrentLoaded(List.from(_currentList)));
      }
    } catch (e) {
      if (e.toString().contains('UNAUTH')) {
        if (!isClosed) emit(CurrentUnauth());
      }
    }
  }

  Future<void> cancelReservation(int id) async {
    emit(CurrentActionLoading());
    try {
      await repository.cancelReservation(id);
      _currentList.removeWhere((r) => r.reservationId == id);

      emit(CurrentActionSuccess("تم إلغاء الحجز بنجاح"));
      if (!isClosed) emit(CurrentLoaded(List.from(_currentList)));
    } catch (e) {
      emit(CurrentActionError(e.toString().replaceAll('Exception: ', '')));
      if (!isClosed) emit(CurrentLoaded(List.from(_currentList)));
    }
  }

  Future<void> payForReservation(int reservationId) async {
    emit(PaymentLoading());
    try {
      await repository.payReservation(reservationId);
      _currentList.removeWhere((r) => r.reservationId == reservationId);

      emit(PaymentSuccess(reservationId));
      if (!isClosed) emit(CurrentLoaded(List.from(_currentList)));
    } catch (e) {
      if (e.toString().contains('UNAUTH')) {
        if (!isClosed) emit(CurrentUnauth());
      } else {
        emit(PaymentError(e.toString().replaceAll('Exception: ', '')));
        if (!isClosed) emit(CurrentLoaded(List.from(_currentList)));
      }
    }
  }

  Future<void> submitRating(
      {required int rate, required int reservationId}) async {
    if (isClosed) return;

    emit(RatingLoading());
    try {
      await repository.rateJob(rate: rate, reservationId: reservationId);
      if (!isClosed) emit(RatingSuccess());
    } catch (e) {
      if (!isClosed) {
        if (e.toString().contains('UNAUTH')) {
          emit(CurrentUnauth());
        } else {
          emit(RatingError(e.toString().replaceAll('Exception: ', '')));
        }
      }
    }
  }

  Future<void> disconnect() async {
    await repository.disconnectHub();
  }
}
