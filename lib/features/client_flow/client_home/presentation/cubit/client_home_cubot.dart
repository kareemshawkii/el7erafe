import 'package:el7erafe/features/client_flow/client_home/presentation/cubit/client_home_state.dart';
import 'package:el7erafe/features/client_flow/client_home/data/repositories/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super(HomeInitial());

  void fetchServices() async {
    emit(HomeLoading());
    try {
      final services = await _repository.getServices();
      emit(HomeLoaded(services));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}