// ignore_for_file: deprecated_member_use

import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
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
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              SlideRightRouteWithBuild(
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
                    padding: EdgeInsets.only(top: 68.h, bottom: 68.h),
                    color: const Color(0xFF3775FA),
                    width: double.infinity,
                    height: double.infinity,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: 131.h,
                        width: 131.w,
                        child: Image.asset('images/Logo.png', fit: BoxFit.fill),
                      ),
                    )),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(44.r),
                      topRight: Radius.circular(44.r),
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 200 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        height: 629.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFFDFDFD),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(44.r),
                            topRight: Radius.circular(44.r),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                              16.w, 44.h, 16.w, 44.h + keyboardPadding),
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  style: GoogleFonts.cairo(
                                    fontSize: 20.sp,
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
                              SizedBox(height: 24.h),
                              const ClientRegistrationForm(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
