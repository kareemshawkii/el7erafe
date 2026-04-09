import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/repositories/previous_jobs_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'previous_jobs_state.dart';

class PreviousJobsCubit extends Cubit<PreviousJobsState> {
  final PreviousJobsRepo repository;

  PreviousJobsCubit({required this.repository}) : super(PreviousJobsInitial());

  void fetchJobs() async {
    if (isClosed) return;
    emit(PreviousJobsLoading());

    final result = await repository.getPreviousJobs();

    if (isClosed) return;

    result.fold(
      (error) {
        if (error == "401") {
          emit(PreviousJobsUnauth());
        } else {
          emit(PreviousJobsError(error));
        }
      },
      (jobs) {
        emit(PreviousJobsLoaded(jobs));
      },
    );
  }
}
