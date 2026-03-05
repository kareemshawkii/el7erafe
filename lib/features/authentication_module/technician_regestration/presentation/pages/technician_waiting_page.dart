import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/techincian_registration_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_resubmit_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_waiting_page_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_waititng_page_state.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/pages/technician_resubmit_page.dart';
import 'package:el7erafe/technician.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TechnicianWaitingPage extends StatelessWidget {
  const TechnicianWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TechnicianRegistrationCubit(
            technicianRegRepository:
                RepositoryProvider.of<TechnicianRegRepository>(context),
          ),
        ),
      ],
      child: const TechnicianWaitingView(),
    );
  }
}

class TechnicianWaitingView extends StatefulWidget {
  const TechnicianWaitingView({super.key});

  @override
  State<TechnicianWaitingView> createState() => _TechnicianWaitingViewState();
}

class _TechnicianWaitingViewState extends State<TechnicianWaitingView> {
  @override
  void initState() {
    super.initState();
    context.read<TechnicianStatusCubit>().checkApprovalStatus();
  }

  void _onReloadPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<TechnicianStatusCubit>().checkApprovalStatus();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<TechnicianStatusCubit, TechnicianStatusState>(
        listener: (context, state) async {
          if (state is TechnicianStatusDenied) {
            if (state.status == "تحت المراجعة") {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(state.message, textDirection: TextDirection.rtl),
                  backgroundColor: Colors.blue,
                ),
              );
            } else if (state.status == "مرفوض") {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(state.message, textDirection: TextDirection.rtl),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pushAndRemoveUntil(
                context,
                SlideRightRouteWithBuild(
                  builder: (_) => BlocProvider(
                    create: (_) => TechnicianResubmitCubit(
                      technicianRegRepository:
                          RepositoryProvider.of<TechnicianRegRepository>(
                              context),
                    ),
                    child: const TechnicianResubmitPage(),
                  ),
                ),
                (route) => false,
              );
              AuthLocalStorage authStorage = AuthLocalStorage();
              await authStorage.deleteTempToken();
            }
          } else if (state is TechnicianStatusBlocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
              ),
            );
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
            AuthLocalStorage authStorage = AuthLocalStorage();
            await authStorage.deleteTempToken();
          } else if (state is TechnicianStatusApproved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'تم قبول حسابك كحرفي متحمسين نشوف نجاحك بالتوفيق.',
                    textDirection: TextDirection.rtl),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                builder: (_) => const TechnicianPage(),
              ),
              (route) => false,
            );
            AuthLocalStorage authStorage = AuthLocalStorage();
            await authStorage.deleteTempToken();
          } else if (state is TechnicianStatusError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
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
                    height: 267.h,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('images/technician_waiting.png',
                                width: 241.w, height: 361.h),
                            SizedBox(height: 24.h),
                            Directionality(
                                textDirection: TextDirection.rtl,
                                child: Center(
                                  child: Text(
                                    'شكراً لتسجيلك كحرفي! طلبك بيتراجع دلوقتي ، وهنرد عليك خلال 24 ساعة.',
                                    style: GoogleFonts.cairo(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF000000),
                                    ),
                                  ),
                                )),
                            SizedBox(height: 18.h),
                            SizedBox(
                              height: 40.h,
                              width: 264.w,
                              child: BlocBuilder<TechnicianStatusCubit,
                                  TechnicianStatusState>(
                                builder: (context, state) {
                                  final isLoading =
                                      state is TechnicianStatusLoading;
                                  return Container(
                                      width: double.infinity,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: Color(0xFF3775FA),
                                          width: 1.w,
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => _onReloadPressed(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF3775FA),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              const Color.fromARGB(
                                                  158, 55, 117, 250),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              side: const BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0)),
                                        ),
                                        child: isLoading
                                            ? SizedBox(
                                                height: 24.r,
                                                width: 24.r,
                                                child:
                                                    const CircularProgressIndicator(
                                                        color:
                                                            Color(0xFF3775FA),
                                                        strokeWidth: 3),
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text('اعاده تحميل الصفحه',
                                                      style: GoogleFonts.cairo(
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  SizedBox(width: 8.w),
                                                  Icon(Icons.refresh,
                                                      color: Colors.white,
                                                      size: 24.w),
                                                ],
                                              ),
                                      ));
                                },
                              ),
                            ),
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
