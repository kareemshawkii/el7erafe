import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
              padding: EdgeInsets.only(
                  top: (68 / 852) * screenHeight,
                  bottom: (68 / 852) * screenHeight),
              color: const Color(0xFF3775FA),
              width: screenWidth,
              height: (267 / 852) * screenHeight,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: (131 / 852) * screenHeight,
                  width: (131 / 393) * screenWidth,
                  child: Image.asset('images/Logo.png', fit: BoxFit.fill),
                ),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular((44)),
              topRight: Radius.circular((44)),
            ),
            child: Container(
              height: (629 / 852) * screenHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFDFDFD),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular((44 / 852) * screenHeight),
                  topRight: Radius.circular((44 / 852) * screenHeight),
                ),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Container(
                    padding: EdgeInsets.only(
                      left: (16 / 393) * screenWidth,
                      right: (16 / 393) * screenWidth,
                      bottom: (24 / 852) * screenHeight,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: (24 / 852) * screenHeight),
                          SizedBox(
                            height: (250 / 852) * screenHeight,
                            width: (250 / 393) * screenWidth,
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
                                fontSize: 15, color: Colors.black, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: (24 / 852) * screenHeight),
                          Container(
                            width: double.infinity,
                            height: (40 / 852) * screenHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Color(0xFF3775FA),
                                width: 1.0,
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
                                    borderRadius: BorderRadius.circular(12.0),
                                    side: const BorderSide(
                                        color: Colors.white, width: 1.0)),
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
                                  const SizedBox(width: 8),
                                  const Icon(Icons.home,
                                      color: Colors.white, size: 16),
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
