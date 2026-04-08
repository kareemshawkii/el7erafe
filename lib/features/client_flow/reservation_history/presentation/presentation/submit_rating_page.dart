import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/current_reservations_cubit.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/current_reservations_state.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/presentation/rating_success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class SubmitRatingPage extends StatefulWidget {
  const SubmitRatingPage({super.key});

  @override
  State<SubmitRatingPage> createState() => _SubmitRatingPageState();
}

class _SubmitRatingPageState extends State<SubmitRatingPage> {
  int _selectedStars = 0;
  bool _isLoadingDialogOpen = false;

  void _closeDialog() {
    if (_isLoadingDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isLoadingDialogOpen = false;
    }
  }

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
    return BlocListener<CurrentReservationsCubit, CurrentReservationsState>(
      listener: (context, state) {
        if (state is RatingLoading) {
          _isLoadingDialogOpen = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: Lottie.asset('assets/icon/loading.json',
                  width: 200.w, height: 200.h),
            ),
          ).then((_) => _isLoadingDialogOpen = false);
        } else {
          _closeDialog();
          if (state is RatingSuccess) {
            Navigator.pushReplacement(
              context,
              SlideRightRouteWithBuild(
                  builder: (_) => const RatingSuccessPage()),
            );
          } else if (state is RatingError) {
            ModernSnackbar.showError(context: context, message: state.message);
          } else if (state is CurrentUnauth) {
            ModernSnackbar.showError(
                context: context,
                message: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى');
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                builder: (_) => BlocProvider(
                  create: (_) => LoginCubit(
                      authRepository:
                          RepositoryProvider.of<AuthRepository>(context)),
                  child: const LoginPage(),
                ),
              ),
              (route) => false,
            );
          }
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
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Scaffold(
                        backgroundColor: Colors.white,
                        body: Container(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 16.w,
                            bottom: 24.h,
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                SizedBox(height: 24.h),
                                _buildAnimatedWidget(
                                  delayIndex: 0,
                                  child: SizedBox(
                                    height: 250.h,
                                    width: 250.w,
                                    child: Image.asset('images/rating.png'),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                _buildAnimatedWidget(
                                  delayIndex: 1,
                                  child: Text(
                                    'قيم مدي كفائه الفني',
                                    style: GoogleFonts.cairo(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                _buildAnimatedWidget(
                                  delayIndex: 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12.h, horizontal: 24.w),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.w,
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(5, (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedStars = index + 1;
                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.w),
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              transitionBuilder:
                                                  (child, animation) {
                                                return ScaleTransition(
                                                  scale: animation,
                                                  child: child,
                                                );
                                              },
                                              child: Icon(
                                                index < _selectedStars
                                                    ? Icons.star_rounded
                                                    : Icons
                                                        .star_outline_rounded,
                                                key: ValueKey<bool>(
                                                    index < _selectedStars),
                                                color: index < _selectedStars
                                                    ? const Color(0xFFFFC107)
                                                    : Colors.black54,
                                                size: 40.sp,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                _buildAnimatedWidget(
                                  delayIndex: 3,
                                  child: Container(
                                    height: 45.h,
                                    width: double.infinity,
                                    padding: EdgeInsets.all(2.r),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14.r),
                                      border: Border.all(
                                        color: const Color(0xFF3775FA),
                                        width: 1.w,
                                      ),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _selectedStars == 0
                                          ? null
                                          : () {
                                              context
                                                  .read<
                                                      CurrentReservationsCubit>()
                                                  .submitRating(
                                                    rate: _selectedStars,
                                                  );
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF3775FA),
                                        disabledBackgroundColor:
                                            Colors.grey.shade300,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Iconsax.send,
                                            color: Colors.white,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 10.w),
                                          Text(
                                            'إرسال التقييم',
                                            style: GoogleFonts.cairo(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
