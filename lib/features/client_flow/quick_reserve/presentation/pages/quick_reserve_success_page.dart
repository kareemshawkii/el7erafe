import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                            SizedBox(
                              height: 250.h,
                              width: 250.w,
                              child: Image.asset("images/success.png"),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "طلبك استلمناه بنجاح",
                              style: GoogleFonts.cairo(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF3775FA),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "دلوقتي فريقنا بيشوف أقرب فني متاح علشان يخدمك في أسرع وقت.هيوصلك إشعار أول ما نأكد الحجز",
                              style: GoogleFonts.cairo(
                                  fontSize: 15.sp,
                                  color: Colors.black,
                                  height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24.h),
                            Container(
                              width: double.infinity,
                              height: 40.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFF3775FA),
                                  width: 1.w,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    SlideRightRouteWithBuild(
                                        builder: (_) => const ClientHomePage()),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3775FA),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      const Color.fromARGB(158, 55, 117, 250),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      side: const BorderSide(
                                          color: Colors.white, width: 1.0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "الصفحة الرئيسية",
                                      style: GoogleFonts.cairo(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(Icons.home,
                                        color: Colors.white, size: 16.r),
                                  ],
                                ),
                              ),
                            )
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
    );
  }
}
