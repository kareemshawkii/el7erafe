import 'package:el7erafe/features/authentication_module/client_regestration/data/repositories/client_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/email_input_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/otp_forget_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/reset_password_repo.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/otp_page/data/Repository/otp_repository.dart';
import 'package:el7erafe/features/authentication_module/splash/splash_control.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/client_flow/client_home/data/repositories/home_repository.dart';
import 'package:el7erafe/features/client_flow/client_profile/data/repositories/client_profile_repo.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/data/repositories/quick_reserve_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
   Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => AuthRepository(),
          ),
          RepositoryProvider(
            create: (context) => ClientRegRepository(),
          ),
          RepositoryProvider(
            create: (context) => OtpRepository(),
          ),
          RepositoryProvider(
            create: (context) => TechnicianRegRepository(),
          ),
          RepositoryProvider(
            create: (context) => EmailInputRepository(),
          ),
          RepositoryProvider(
            create: (context) => OtpForgetRepository(),
          ),
          RepositoryProvider(
            create: (context) => ResetPasswordRepository(),
          ),
          RepositoryProvider(
            create: (context) => HomeRepository(),
          ),
          RepositoryProvider(
            create: (context) => ServiceRequestRepository(),
          ),
          RepositoryProvider(
            create: (context) => ProfileRepository(),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          debugShowCheckedModeBanner: false,
          title: 'El7erafe',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3775FA),
            ),
            textTheme: GoogleFonts.cairoTextTheme(),
            useMaterial3: true,
          ),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final textScaler = mediaQueryData.textScaler;
            final clampedTextScaler = textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.0,
            );

            return Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                data: mediaQueryData.copyWith(
                  textScaler: clampedTextScaler,
                ),
                child: child!,
              ),
            );
          },
          home: const SplashController(),
          routes: {},
        ));
  }
}
