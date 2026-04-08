import 'package:el7erafe/core/utils/animated_navigation.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingSuccessPage extends StatelessWidget {
  const RatingSuccessPage({super.key});

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
    return Scaffold(
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
                                child: SvgPicture.asset(
                                  'images/rating.svg',
                                  height: 250.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 32.h),
                              _buildAnimatedWidget(
                                delayIndex: 1,
                                child: Text(
                                  'شكرا لتقييمك !',
                                  style: GoogleFonts.cairo(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(height: 48.h),
                              _buildAnimatedWidget(
                                delayIndex: 2,
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
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        SlideRightRoute(page: const ClientHomePage()),
                                        (route) => false,
                                      );
                                    },
                                    icon: Icon(Icons.home_outlined,
                                        color: Colors.white, size: 20.sp),
                                    label: Text(
                                      'الصفحه الرئيسيه',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3775FA),
                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r), 
                                      ),
                                      elevation: 0,
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
    );
  }
}