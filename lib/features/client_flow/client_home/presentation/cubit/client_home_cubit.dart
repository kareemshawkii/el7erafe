import 'package:el7erafe/features/client_flow/client_home/presentation/cubit/client_home_state.dart';
import 'package:el7erafe/features/client_flow/client_home/data/repositories/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super(HomeInitial());

  void fetchServices() async {
    emit(HomeLoading());
    final result = await _repository.getServices();

    result.fold(
      (errorMessage) {
        if (errorMessage.contains("401")) {
          emit(HomeUnauthorized("جلسة المستخدم انتهت، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          emit(HomeError(errorMessage));
        }
      },
      (servicesList) {
        emit(HomeLoaded(servicesList));
      },
    );
  }
}
