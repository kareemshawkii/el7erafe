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
      if (!isClosed) {
        emit(AvailableRequestsLoaded(initialData));
      }

      await repository.connectAndListen(
        onNewRequestReceived: (singleData) {
          if (!isClosed) {
            if (state is AvailableRequestsLoaded) {
              final currentList = List<AvailableRequestModel>.from(
                  (state as AvailableRequestsLoaded).requests);
              final index = currentList.indexWhere(
                  (element) => element.requestId == singleData.requestId);
              if (index != -1) {
                currentList[index] = singleData;
              } else {
                currentList.add(singleData);
              }
              emit(AvailableRequestsLoaded(currentList));
            } else {
              emit(AvailableRequestsLoaded([singleData]));
            }
          }
        },
        onForceDisconnect: () {
          if (!isClosed) {
            emit(AvailableRequestsUnauthorized());
          }
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
              emit(AvailableRequestsLoaded(currentState.requests));
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
            emit(AvailableRequestsLoaded(currentList));
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

  @override
  Future<void> close() {
    repository.disconnect();
    return super.close();
  }
}
