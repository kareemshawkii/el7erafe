import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/pending_requests_repo.dart';
import 'pending_requests_state.dart';

class PendingRequestsCubit extends Cubit<PendingRequestsState> {
  final PendingRequestsRepo repository;

  PendingRequestsCubit({required this.repository}) : super(PendingRequestsInitial());

  void fetchPendingRequests() async {
    emit(PendingRequestsLoading());
    try {
      await repository.connectAndListen((data) {
        if (!isClosed) {
          emit(PendingRequestsLoaded(data));
        }
      });
    } catch (e) {
      if (!isClosed) {
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('401') || errorString.contains('unauthorized')) {
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