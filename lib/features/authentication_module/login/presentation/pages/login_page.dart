import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/authentication_module/otp_page/data/Repository/otp_repository.dart';
import 'package:el7erafe/features/authentication_module/otp_page/presentation/cubit/otp_cubit.dart';
import 'package:el7erafe/features/authentication_module/otp_page/presentation/cubit/technician_otp_cubit.dart';
import 'package:el7erafe/features/authentication_module/otp_page/presentation/page/otp_page.dart';
import 'package:el7erafe/features/authentication_module/otp_page/presentation/page/technician_otp_page.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_resubmit_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_waiting_page_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/pages/technician_resubmit_page.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/pages/technician_waiting_page.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/pages/tech_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginView();
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state is AuthFailure) {
            ModernSnackbar.showError(context: context, message: state.error);
          }
          if (state is AuthSuccess) {
            String? type = await AuthLocalStorage().getUserType();
            if (type == 'C') {
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                SlideRightRouteWithBuild(
                    builder: (_) => const ClientHomePage()),
                (route) => false,
              );
            } else if (type == 'T') {
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                SlideRightRouteWithBuild(builder: (_) => const TechHomePage()),
                (route) => false,
              );
            } else {
              if (!context.mounted) return;
              ModernSnackbar.showError(
                  context: context,
                  message: 'حصلت مشكله غير متوقعه جرب تسجل تاني');
            }
            if (!context.mounted) return;
            ModernSnackbar.showSuccess(
                context: context, message: 'تم تسجيل الدخول بنجاح');
          }
          if (state is OtpSent) {
            AuthLocalStorage authLocalStorage = AuthLocalStorage();
            String? storedEmail = await authLocalStorage.getEmail();
            if (storedEmail != null && storedEmail.isNotEmpty) {
              if (!context.mounted) return;
              ModernSnackbar.showSuccess(
                  context: context,
                  message: 'تم إرسال رمز التحقق إلى البريد الإلكتروني');
              Navigator.push(
                context,
                SlideRightRouteWithBuild(
                  builder: (context) => BlocProvider(
                    create: (context) => OtpCubit(
                        otpRepository:
                            RepositoryProvider.of<OtpRepository>(context)),
                    child: OtpPage(email: storedEmail),
                  ),
                ),
              );
            } else {
              if (!context.mounted) return;
              ModernSnackbar.showError(
                  context: context,
                  message: 'حدث خطأ ما، يرجى المحاولة مرة أخرى');
            }
          }
          if (state is TechnicianOtpSent) {
            AuthLocalStorage authLocalStorage = AuthLocalStorage();
            String? storedEmail = await authLocalStorage.getTechnicianEmail();
            if (storedEmail != null && storedEmail.isNotEmpty) {
              if (!context.mounted) return;
              ModernSnackbar.showSuccess(
                  context: context,
                  message: 'تم إرسال رمز التحقق إلى البريد الإلكتروني');
              Navigator.push(
                context,
                SlideRightRouteWithBuild(
                  builder: (context) => BlocProvider(
                    create: (context) => TechnicianOtpCubit(
                        otpRepository:
                            RepositoryProvider.of<OtpRepository>(context)),
                    child: TechnicianOtpPage(email: storedEmail),
                  ),
                ),
              );
            } else {
              if (!context.mounted) return;
              ModernSnackbar.showError(
                  context: context,
                  message: 'حدث خطأ ما، يرجى المحاولة مرة أخرى');
            }
          }
          if (state is AuthPending) {
            if (!context.mounted) return;
            ModernSnackbar.show(
                context: context,
                title: 'الطلب معلق',
                message:
                    'لم يتم قبول الطلب بعد سيتم إعلامك عند القبول قريبا...',
                color: Colors.blue,
                icon: Iconsax.clock);
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                builder: (context) => BlocProvider(
                  create: (context) => TechnicianStatusCubit(
                    statusRepository:
                        RepositoryProvider.of<TechnicianRegRepository>(context),
                  ),
                  child: TechnicianWaitingPage(),
                ),
              ),
              (route) => false,
            );
          }
          if (state is AuthRejected) {
            if (!context.mounted) return;
            ModernSnackbar.showError(
                context: context,
                message:
                    "تم رفض طلبك، يرجى إعادة تقديم الطلب مع معلومات صحيحة");
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                builder: (context) => BlocProvider(
                  create: (context) => TechnicianResubmitCubit(
                    technicianRegRepository:
                        RepositoryProvider.of<TechnicianRegRepository>(context),
                  ),
                  child: TechnicianResubmitPage(),
                ),
              ),
              (route) => false,
            );
          }
          if (state is AuthBlocked) {
            if (!context.mounted) return;
            ModernSnackbar.showError(
                context: context,
                message: 'تم حظر حسابك دائما، يرجى التواصل مع الدعم الفني');
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF3775FA),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 250.h,
                child: Center(
                  child: SizedBox(
                    height: 150.h,
                    width: 150.w,
                    child: Image.asset('images/Logo.png', fit: BoxFit.fill),
                  ),
                ),
              ),
              Positioned(
                top: 230.h,
                bottom: 0,
                left: 0,
                right: 0,
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
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFDFD),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(44.r),
                          topRight: Radius.circular(44.r),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                            16.w, 44.h, 16.w, 44.h + keyboardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('تسجيل الدخول',
                                style: GoogleFonts.cairo(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                            SizedBox(height: 24.h),
                            const LoginForm(),
                          ],
                        ),
                      ),
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
