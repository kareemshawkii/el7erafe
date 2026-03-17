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
      if (!isClosed) emit(PendingRequestsLoaded(initialData));

      await repository.connectAndListen(
        onListDataReceived: (data) {
          if (!isClosed) emit(PendingRequestsLoaded(data));
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
        onSignalRRefreshNeeded: () async {
          // Triggered by Offer Received or Request Rejected
          if (!isClosed) {
            try {
              final updatedData = await repository.getInitialPendingRequests();
              if (!isClosed) emit(PendingRequestsLoaded(updatedData));
            } catch (_) {}
          }
        },
        onForceDisconnect: () {
          if (!isClosed) emit(PendingRequestsUnauthorized());
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

  void fetchQuickOffers(int requestId) async {
    emit(OffersLoading());
    final result = await repository.getQuickOffers(requestId);
    if (isClosed) return;
    result.fold(
      (error) => emit(error == "401"
          ? PendingRequestsUnauthorized()
          : PendingRequestsError(error)),
      (offersList) => emit(OffersLoaded(offersList)),
    );
  }

  void cancelRequest(int requestId) async {
    emit(OfferActionLoading());
    final result = await repository.cancelRequest(requestId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (error == "401") {
          emit(PendingRequestsUnauthorized());
        } else {
          emit(OfferActionError(error));
          fetchPendingRequests();
        }
      },
      (successMessage) {
        emit(OfferActionSuccess(successMessage));
        fetchPendingRequests();
      },
    );
  }

  void acceptOffer(int offerId) async {
    emit(OfferActionLoading());
    final result = await repository.acceptOffer(offerId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (error == "401") {
          emit(PendingRequestsUnauthorized());
        } else {
          emit(OfferActionError(error));
          fetchPendingRequests();
        }
      },
      (successMessage) {
        emit(OfferActionSuccess(successMessage));
        fetchPendingRequests();
      },
    );
  }

  void declineOffer(int offerId, int requestId) async {
    emit(OfferActionLoading());
    final result = await repository.declineOffer(offerId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (error == "401") {
          emit(PendingRequestsUnauthorized());
        } else {
          emit(OfferActionError(error));
          fetchQuickOffers(requestId);
        }
      },
      (successMessage) {
        emit(OfferActionSuccess(successMessage));
        fetchQuickOffers(requestId);
      },
    );
  }

  void disconnectSignalR() {
    repository.disconnect();
  }

  void reconnectAndRefresh() {
    fetchPendingRequests();
  }

  @override
  Future<void> close() {
    repository.disconnect();
    return super.close();
  }
}
