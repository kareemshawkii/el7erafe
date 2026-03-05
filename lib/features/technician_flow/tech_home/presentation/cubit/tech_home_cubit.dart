import 'package:el7erafe/features/chat_system/data/repositories/inbox_repository.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/tech_home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechHomeCubit extends Cubit<TechHomeState> {

  TechHomeCubit() : super(TechHomeInitial());

  Future<void> fetchTotalUnreadCount() async {
    final result = await InboxRepository().getInbox();

    result.fold((conversations) {
      int total = 0;
      for (var chat in conversations) {
        total += chat.unreadCount;
      }
      if (!isClosed) {
        emit(TechHomeUnreadCountUpdated(total));
      }
    }, (error) {
      if (!isClosed) {
        emit(TechHomeError("فشل في جلب عدد الرسائل غير المقروءه"));
      }
    });
  }
}
