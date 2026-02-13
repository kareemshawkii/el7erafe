import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.only(
            top: (10 / 852) * screenHeight,
            left: (16 / 393) * screenWidth,
            right: (16 / 393) * screenWidth,
            bottom: (24 / 852) * screenHeight,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: (300 / 852) * screenHeight,
                  width: (300 / 393) * screenWidth,
                  child: Image.asset("images/success.png"),
                ),
                SizedBox(height: (12 / 852) * screenHeight),
                Text(
                  "طلبك استلمناه بنجاح",
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3775FA),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: (12 / 852) * screenHeight),
                Text(
                  "دلوقتي فريقنا بيشوف أقرب فني متاح علشان يخدمك في أسرع وقت.هيوصلك إشعار أول ما نأكد الحجز",
                  style: GoogleFonts.cairo(
                      fontSize: 17, color: Colors.black, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: (24 / 852) * screenHeight),
                SizedBox(
                  width: double.infinity,
                  height: (40 / 852) * screenHeight,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "الصفحة الرئيسية",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                            width: 8), 
                        const Icon(Icons.home, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
