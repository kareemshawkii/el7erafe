import 'package:el7erafe/features/authentication_module/client_regestration/data/repositories/client_registration_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'client_registration_state.dart';

class ClientRegistrationCubit extends Cubit<ClientRegistrationState> {
  final ClientRegRepository clientRegRepository;

  ClientRegistrationCubit({required this.clientRegRepository})
      : super(ClientRegInitial());

  Future<void> register(
      String name, String phone, String email, String password) async {
    emit(ClientRegLoading());
    final result = await clientRegRepository.registerClient(
      name: name,
      phoneNumber: phone,
      email: email,
      password: password,
    );

    result.fold(
     (failure) => emit(ClientRegFailure(error: failure.message)),
     (message) => emit(ClientRegSuccess(message: message)),
    );
  }
}