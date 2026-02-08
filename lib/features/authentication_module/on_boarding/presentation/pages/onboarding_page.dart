import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../cubit/onboarding_cubit.dart';

class OnBoardingPage extends StatelessWidget {
  OnBoardingPage({super.key});

  final int totalPages = 3;
  final List<String> images = [
    'images/introOne.png',
    'images/introTwo.png',
    'images/introThree.png',
  ];
  final List<String> titleOne = [
    'مش لاقي ',
    'جالك طلب جديد ؟ مع ',
    'خلص الشغل ؟ سيب كل الباقي علينا  الدفع مضمون، المتابعة سهلة، وكل خطوة متأكدة ',
  ];
  final List<String> titleTwo = [
    'فني ',
    'الحرفي ',
    'ومتأمنة ',
  ];
  final List<String> titleThree = [
    'شاطر وأمين؟ سيبها علينا! شوف أفضل الحرفيين، احجز بسهولة، وكل حاجة مرتبة ومظبوطة',
    'تقدر تشوف كل التفاصيل، تتواصل مع العميل مباشرة، وتتابع شغلك بكل سهولة',
    '',
  ];
  final List<double> progresses = [0.33, 0.9, 1.5];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<OnboardingCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  images[currentIndex],
                  width: screenWidth,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: (342.0 / 852.0) * screenHeight,
                  width: screenWidth,
                  padding: EdgeInsets.only(
                      top: (32.0 / 852.0) * screenHeight,
                      left: (16.0 / 393.0) * screenWidth,
                      right: (16.0 / 393.0) * screenWidth),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(totalPages, (index) {
                          bool isActive = index == currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: isActive ? 19 : 8,
                            height: isActive ? 4 : 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF3F68EC)
                                  : const Color(0xFFD9D9D9),
                              borderRadius:
                                  BorderRadius.circular(isActive ? 4 : 8),
                            ),
                          );
                        }),
                      ),
                      Container(
                        height: (182.0 / 852.0) * screenHeight,
                        margin:
                            EdgeInsets.only(top: (44.0 / 852.0) * screenHeight),
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF232222),
                              height: 1.5,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: titleOne[currentIndex]),
                              TextSpan(
                                text: titleTwo[currentIndex],
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: titleThree[currentIndex]),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (context) => LoginCubit(
                                        authRepository: RepositoryProvider.of<
                                            AuthRepository>(context),
                                      ),
                                      child: const LoginPage(),
                                    ),
                                  ),
                                  (route) => false);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                              ),
                            ),
                            child: Text(
                              'تخطي',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3F68EC),
                              ),
                            ),
                          ),
                          CustomProgressButton(
                            progress: progresses[currentIndex],
                            onPressed: () {
                              if (currentIndex < totalPages - 1) {
                                context
                                    .read<OnboardingCubit>()
                                    .nextPage(totalPages);
                              } else {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                        create: (context) => LoginCubit(
                                          authRepository: RepositoryProvider.of<
                                              AuthRepository>(context),
                                        ),
                                        child: const LoginPage(),
                                      ),
                                    ),
                                    (route) => false);
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomProgressButton extends StatelessWidget {
  final double progress;
  final VoidCallback onPressed;

  const CustomProgressButton({
    super.key,
    required this.progress,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: (52 / 393) * screenWidth,
      height: (52 / 852) * screenHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size((44 / 393) * screenWidth, (44 / 852) * screenHeight),
            painter: ProgressArcPainter(
              progress: progress,
              progressColor: const Color.fromARGB(255, 34, 159, 190),
              strokeWidth: 2,
            ),
          ),
          SizedBox(
            width: (40 / 393) * screenWidth,
            height: (40 / 852) * screenHeight,
            child: FloatingActionButton(
              onPressed: onPressed,
              backgroundColor: const Color(0xFF3F68EC),
              elevation: 0,
              shape: const CircleBorder(),
              child: const Icon(Icons.arrow_forward,
                  size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressArcPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final double strokeWidth;

  ProgressArcPainter({
    required this.progress,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = pi * 0.5;
    final sweepAngle = (pi * 1.5) * progress;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant ProgressArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
