import 'package:el7erafe/features/technician_flow/tech_home/data/models/available_request_model.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/repositories/available_requests_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'available_requests_state.dart';

class AvailableRequestsCubit extends Cubit<AvailableRequestsState> {
  final AvailableRequestsRepo repository;

  AvailableRequestsCubit({required this.repository})
      : super(AvailableRequestsInitial());

  void fetchAvailableRequests() async {
    emit(AvailableRequestsLoading());
    try {
      final initialData = await repository.getInitialAvailableRequests();
      final inProgressData = await repository.getInProgressReservation();

      if (!isClosed) {
        emit(AvailableRequestsLoaded(initialData, inProgress: inProgressData));
      }

      await repository.connectAndListen(
        onNewRequestReceived: (singleData) {
          if (!isClosed) {
            if (state is AvailableRequestsLoaded) {
              final currentState = state as AvailableRequestsLoaded;
              final currentList =
                  List<AvailableRequestModel>.from(currentState.requests);
              final index = currentList.indexWhere(
                  (element) => element.requestId == singleData.requestId);
              if (index != -1) {
                currentList[index] = singleData;
              } else {
                currentList.add(singleData);
              }
              emit(AvailableRequestsLoaded(currentList,
                  inProgress: currentState.inProgress));
            } else {
              emit(AvailableRequestsLoaded([singleData]));
            }
          }
        },
        onSignalRRefreshNeeded: () async {
          if (!isClosed) {
            try {
              final updatedData =
                  await repository.getInitialAvailableRequests();
              final inProgressData =
                  await repository.getInProgressReservation();
              if (!isClosed) {
                emit(AvailableRequestsLoaded(updatedData,
                    inProgress: inProgressData));
              }
            } catch (_) {}
          }
        },
        onPaymentReceived: () {
          emit(PaymentReceivedSuccess());
        },
        onForceDisconnect: () {
          if (!isClosed) emit(AvailableRequestsUnauthorized());
        },
      );
    } catch (e) {
      if (!isClosed) {
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('401') ||
            errorString.contains('unauthorized')) {
          emit(AvailableRequestsUnauthorized());
        } else {
          emit(AvailableRequestsError(e.toString()));
        }
      }
    }
  }

  void submitOffer({
    required int requestId,
    required int fees,
    required String fromTime,
    required String toTime,
    int? numberOfDays,
  }) async {
    final currentState = state;
    emit(AvailableRequestsLoading());

    final result = await repository.submitOffer(
      requestId: requestId,
      fees: fees,
      fromTime: fromTime,
      toTime: toTime,
      numberOfDays: numberOfDays,
    );

    result.fold(
      (error) {
        if (!isClosed) {
          if (error == "401") {
            emit(AvailableRequestsUnauthorized());
          } else {
            emit(MakeOfferError(error));
            if (currentState is AvailableRequestsLoaded) {
              emit(AvailableRequestsLoaded(currentState.requests,
                  inProgress: currentState.inProgress));
            }
          }
        }
      },
      (successMessage) {
        if (!isClosed) {
          emit(MakeOfferSuccess(successMessage));
          if (currentState is AvailableRequestsLoaded) {
            final currentList =
                List<AvailableRequestModel>.from(currentState.requests);
            currentList
                .removeWhere((element) => element.requestId == requestId);
            emit(AvailableRequestsLoaded(currentList,
                inProgress: currentState.inProgress));
          }
        }
      },
    );
  }

  void declineRequest(int requestId) async {
    emit(DeclineRequestLoading());
    final result = await repository.declineRequest(requestId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (error == "401") {
          emit(AvailableRequestsUnauthorized());
        } else {
          emit(DeclineRequestError(error));
          fetchAvailableRequests();
        }
      },
      (successMessage) {
        emit(DeclineRequestSuccess(successMessage));
        fetchAvailableRequests();
      },
    );
  }

  void completeJob(int reservationId) async {
    emit(CompleteJobLoading());
    final result = await repository.completeJob(reservationId);
    if (isClosed) return;

    result.fold(
      (error) {
        if (error == "401") {
          emit(AvailableRequestsUnauthorized());
        } else {
          emit(CompleteJobError(error));
          fetchAvailableRequests();
        }
      },
      (successMessage) {
        emit(CompleteJobSuccess(successMessage, reservationId));
      },
    );
  }

  void disconnectSignalR() {
    repository.disconnect();
  }

  void reconnectAndRefresh() {
    fetchAvailableRequests();
  }

  @override
  Future<void> close() {
    repository.disconnect();
    return super.close();
  }
}
