import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/pending_request_model.dart';
import '../../data/repositories/pending_requests_repo.dart';
import 'pending_requests_state.dart';

class PendingRequestsCubit extends Cubit<PendingRequestsState> {
  final PendingRequestsRepo repository;

  PendingRequestsCubit({required this.repository})
      : super(PendingRequestsInitial());

  void fetchPendingRequests() async {
    emit(PendingRequestsLoading());
    try {
      final initialData = await repository.getInitialPendingRequests();
      if (!isClosed) {
        emit(PendingRequestsLoaded(initialData));
      }

      await repository.connectAndListen(
        onListDataReceived: (data) {
          if (!isClosed) {
            emit(PendingRequestsLoaded(data));
          }
        },
        onSingleDataReceived: (singleData) {
          if (!isClosed) {
            if (state is PendingRequestsLoaded) {
              final currentList = List<PendingRequestModel>.from(
                  (state as PendingRequestsLoaded).requests);
              final index = currentList.indexWhere(
                  (element) => element.requestId == singleData.requestId);
              if (index != -1) {
                currentList[index] = singleData;
              } else {
                currentList.insert(0, singleData);
              }
              emit(PendingRequestsLoaded(currentList));
            } else {
              emit(PendingRequestsLoaded([singleData]));
            }
          }
        },
        onForceDisconnect: () {
          if (!isClosed) {
            emit(PendingRequestsUnauthorized());
          }
        },
      );
    } catch (e) {
      if (!isClosed) {
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('401') ||
            errorString.contains('unauthorized')) {
          emit(PendingRequestsUnauthorized());
        } else {
          emit(PendingRequestsError(e.toString()));
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
