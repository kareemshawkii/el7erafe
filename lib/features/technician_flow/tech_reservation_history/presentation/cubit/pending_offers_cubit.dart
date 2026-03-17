import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/repositories/pending_offers_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/cubit/pending_offers_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingOffersCubit extends Cubit<PendingOffersState> {
  final PendingOffersRepo repository;

  PendingOffersCubit({required this.repository})
      : super(PendingOffersInitial());

  void fetchPendingOffers() async {
    emit(PendingOffersLoading());
    final result = await repository.getPendingOffers();

    if (isClosed) return;

    result.fold(
      (error) {
        if (error == "401") {
          emit(PendingOffersUnauthorized());
        } else {
          emit(PendingOffersError(error));
        }
      },
      (offersList) {
        emit(PendingOffersLoaded(offersList));
      },
    );
  }

  void initializeSignalR() async {
    await repository.connectAndListen(
      onOfferRejected: (data) {
        if (!isClosed) {
          fetchPendingOffers();
        }
      },
      onForceDisconnect: () {
        if (!isClosed) {
          emit(PendingOffersUnauthorized());
        }
      },
    );
  }

  @override
  Future<void> close() {
    repository.disconnect();
    return super.close();
  }
}
