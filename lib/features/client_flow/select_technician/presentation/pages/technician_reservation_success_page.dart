import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectTechnicianSuccessPage extends StatelessWidget {
  const SelectTechnicianSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                            child: Image.asset("images/successtech.png"),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "تم إرسال طلبك للفني",
                            style: GoogleFonts.cairo(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3775FA),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "إحنا دلوقتي مستنيين رد الفني، وهيوصلك إشعار أول ما يؤكد الحجز أو يعتذر.",
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
                                color: Color(0xFF3775FA),
                                width: 1.w,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
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
      ],
    );
  }
}
