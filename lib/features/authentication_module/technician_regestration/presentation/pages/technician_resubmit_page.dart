import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_resubmit_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_resubmit_state.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_waiting_page_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/pages/technician_waiting_page.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/widgets/technician_resubmit_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TechnicianResubmitPage extends StatelessWidget {
  const TechnicianResubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TechnicianResubmitCubit(
        technicianRegRepository:
            RepositoryProvider.of<TechnicianRegRepository>(context),
      ),
      child: const TechnicianResubmitView(),
    );
  }
}

class TechnicianResubmitView extends StatelessWidget {
  const TechnicianResubmitView({super.key});

  @override
  Widget build(BuildContext context) {
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<TechnicianResubmitCubit, TechnicianResubmitState>(
        listener: (context, state) {
          if (state is TechnicianResubmitFailure) {
            ModernSnackbar.showError(context: context, message: state.error);
          } else if (state is TechnicianResubmitSuccess) {
            ModernSnackbar.showSuccess(
                context: context,
                message: "تم ارسال البيانات بنجاح وفي انتظار التحقق");
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                builder: (context) => BlocProvider(
                  create: (context) => TechnicianStatusCubit(
                    statusRepository:
                        RepositoryProvider.of<TechnicianRegRepository>(context),
                  ),
                  child: const TechnicianWaitingPage(),
                ),
              ),
              (route) => false,
            );
          } else if (state is TechnicianResubmitBlocked) {
            ModernSnackbar.showError(context: context, message: state.message);
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                builder: (_) => BlocProvider(
                  create: (_) => LoginCubit(
                    authRepository:
                        RepositoryProvider.of<AuthRepository>(context),
                  ),
                  child: const LoginPage(),
                ),
              ),
              (route) => false,
            );
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
                                children: const <TextSpan>[
                                  TextSpan(text: "اعاده ارسال البيانات "),
                                  TextSpan(
                                    text: "المرفوضة",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24.h),
                            const TechnicianResubmitForm(),
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
