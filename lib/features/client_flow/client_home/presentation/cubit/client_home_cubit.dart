import 'package:el7erafe/features/chat_system/data/repositories/inbox_repository.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/cubit/client_home_state.dart';
import 'package:el7erafe/features/client_flow/client_home/data/repositories/home_repository.dart';
import 'package:el7erafe/features/client_flow/client_home/data/models/service_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  List<ServiceItem> _cachedServices = [];

  HomeCubit(this._repository) : super(HomeInitial());

  void fetchServices() async {
    emit(HomeLoading());
    final result = await _repository.getServices();

    result.fold(
      (errorMessage) {
        if (errorMessage.contains("401")) {
          emit(HomeUnauthorized(
              "جلسة المستخدم انتهت، الرجاء تسجيل الدخول مرة أخرى."));
        } else {
          emit(HomeError(errorMessage));
        }
      },
      (servicesList) {
        _cachedServices = servicesList;
        emit(HomeLoaded(servicesList));
      },
    );
  }

  Future<void> fetchTotalUnreadCount() async {
    final result = await InboxRepository().getInbox();

    result.fold((conversations) {
      int total = 0;
      for (var chat in conversations) {
        total += chat.unreadCount;
      }
      if (!isClosed) {
        emit(HomeUnreadCountUpdated(total));
        if (_cachedServices.isNotEmpty) {
          emit(HomeLoaded(_cachedServices));
        }
      }
    }, (error) {
      if (!isClosed) {
        emit(HomeError("فشل في جلب عدد الرسائل غير المقروءه"));
        if (_cachedServices.isNotEmpty) {
          emit(HomeLoaded(_cachedServices));
        }
      }
    });
  }
}
