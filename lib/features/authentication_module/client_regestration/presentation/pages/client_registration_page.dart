import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/data/repositories/client_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/client_registration_cubit.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/client_registration_state.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/password_strength_cubit.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/widgets/client_registration_form.dart';
import 'package:el7erafe/features/authentication_module/otp_page/data/Repository/otp_repository.dart';
import 'package:el7erafe/features/authentication_module/otp_page/presentation/cubit/otp_cubit.dart';
import 'package:el7erafe/features/authentication_module/otp_page/presentation/page/otp_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientRegistrationPage extends StatelessWidget {
  const ClientRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ClientRegistrationCubit(
            clientRegRepository:
                RepositoryProvider.of<ClientRegRepository>(context),
          ),
        ),
        BlocProvider(
          create: (context) => PasswordStrengthCubit(),
        ),
      ],
      child: const ClientRegistrationView(),
    );
  }
}

class ClientRegistrationView extends StatelessWidget {
  const ClientRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<ClientRegistrationCubit, ClientRegistrationState>(
        listener: (context, state) async {
          if (state is ClientRegFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is ClientRegSuccess) {
            AuthLocalStorage authLocalStorage = AuthLocalStorage();
            String? email = await authLocalStorage.getEmail();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم ارسال كود التحقق بنجاح',
                    textDirection: TextDirection.rtl),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => OtpCubit(
                      otpRepository:
                          RepositoryProvider.of<OtpRepository>(context)),
                  child: OtpPage(email: email!),
                ),
              ),
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                    padding: EdgeInsets.only(
                        top: (68 / 852) * screenHeight,
                        bottom: (68 / 852) * screenHeight),
                    color: const Color(0xFF3775FA),
                    width: screenWidth,
                    height: (267 / 852) * screenHeight,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: (131 / 852) * screenHeight,
                        width: (131 / 393) * screenWidth,
                        child: Image.asset('images/Logo.png', fit: BoxFit.fill),
                      ),
                    )),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: (629 / 852) * screenHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDFDFD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(44),
                      topRight: Radius.circular(44),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        (16 / 393) * screenWidth,
                        (44 / 852) * screenHeight,
                        (16 / 393) * screenWidth,
                        (44 / 852) * screenHeight + keyboardPadding),
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF232222),
                              height: 1.5,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: "خلينا نعمل حساب"),
                              TextSpan(
                                text: " مستخدم جديد",
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: (24 / 852) * screenHeight),
                        const ClientRegistrationForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
