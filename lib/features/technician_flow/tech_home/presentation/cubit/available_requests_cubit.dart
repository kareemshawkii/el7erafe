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
                currentList.insert(0, singleData);
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

  @override
  Future<void> close() {
    repository.disconnect();
    return super.close();
  }
}
