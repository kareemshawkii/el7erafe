import 'package:flutter_bloc/flutter_bloc.dart';

enum UserType { technician, user }

class SelectTypeCubit extends Cubit<UserType> {
  SelectTypeCubit() : super(UserType.user);

  void selectType(UserType type) {
    emit(type); 
  }
}