import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_state.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/pages/tech_payment_success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class WaitingForPaymentPage extends StatelessWidget {
  final int reservationId;

  const WaitingForPaymentPage({super.key, required this.reservationId});

  Widget _buildAnimatedWidget(
      {required Widget child, required int delayIndex}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (delayIndex * 150)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AvailableRequestsCubit, AvailableRequestsState>(
      listener: (context, state) {
        if (state is PaymentReceivedSuccess &&
            state.reservationId == reservationId) {
          Navigator.pushAndRemoveUntil(
            context,
            SlideRightRouteWithBuild(
              builder: (_) => const TechPaymentSuccessPage(),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
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
                      child: child,
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
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAnimatedWidget(
                            delayIndex: 0,
                            child: SizedBox(
                              height: 280.h,
                              child: Image.asset('images/waiting_payment.png',
                                  fit: BoxFit.contain),
                            ),
                          ),
                          SizedBox(height: 32.h),
                          _buildAnimatedWidget(
                            delayIndex: 1,
                            child: Text(
                              'فى انتظار الدفع',
                              style: GoogleFonts.cairo(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildAnimatedWidget(
                            delayIndex: 2,
                            child: Lottie.asset(
                              'assets/icon/loading.json',
                              width: 80.w,
                              height: 80.h,
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
    );
  }
}
