import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/data/repositories/client_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/email_input_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/otp_forget_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/reset_password_repo.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/authentication_module/on_boarding/presentation/cubit/onboarding_cubit.dart';
import 'package:el7erafe/features/authentication_module/on_boarding/presentation/pages/onboarding_page.dart';
import 'package:el7erafe/features/authentication_module/otp_page/data/Repository/otp_repository.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_waiting_page_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/pages/technician_waiting_page.dart';
import 'package:el7erafe/features/client_flow/client_home/data/repositories/home_repository.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:el7erafe/features/client_flow/client_profile/data/repositories/client_profile_repo.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/data/repositories/quick_reserve_repo.dart';
import 'package:el7erafe/features/client_flow/select_technician/data/repositories/select_technician_repo.dart';
import 'package:el7erafe/technician.dart';

enum InitialRoute {
  onboarding,
  clientHome,
  technicianHome,
  technicianWaiting,
  login
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final InitialRoute initialRoute = await _determineInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
}

Future<InitialRoute> _determineInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  if (isFirstLaunch) {
    prefs.setBool('isFirstLaunch', false);
    return InitialRoute.onboarding;
  }

  final authStorage = AuthLocalStorage();

  final results = await Future.wait([
    authStorage.getToken(),
    authStorage.getTempToken(),
    authStorage.getUserType(),
  ]);

  final String? token = results[0];
  final String? tempToken = results[1];
  final String? userType = results[2];

  if (token != null && token.isNotEmpty) {
    if (userType == "C") return InitialRoute.clientHome;
    if (userType == "T") return InitialRoute.technicianHome;
  }

  if (tempToken != null && tempToken.isNotEmpty) {
    return InitialRoute.technicianWaiting;
  }

  return InitialRoute.login;
}

class MyApp extends StatefulWidget {
  final InitialRoute initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  Widget _getInitialPage(BuildContext context) {
    switch (widget.initialRoute) {
      case InitialRoute.onboarding:
        return BlocProvider(
          create: (_) => OnboardingCubit(),
          child: OnBoardingPage(),
        );
      case InitialRoute.clientHome:
        return const ClientHomePage();
      case InitialRoute.technicianHome:
        return const TechnicianPage();
      case InitialRoute.technicianWaiting:
        return BlocProvider(
          create: (context) => TechnicianStatusCubit(
            statusRepository:
                RepositoryProvider.of<TechnicianRegRepository>(context),
          ),
          child: const TechnicianWaitingPage(),
        );
      case InitialRoute.login:
        return BlocProvider(
          create: (context) => LoginCubit(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
          child: const LoginPage(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ClientRegRepository()),
        RepositoryProvider(create: (context) => OtpRepository()),
        RepositoryProvider(create: (context) => TechnicianRegRepository()),
        RepositoryProvider(create: (context) => EmailInputRepository()),
        RepositoryProvider(create: (context) => OtpForgetRepository()),
        RepositoryProvider(create: (context) => ResetPasswordRepository()),
        RepositoryProvider(create: (context) => HomeRepository()),
        RepositoryProvider(create: (context) => ServiceRequestRepository()),
        RepositoryProvider(create: (context) => ProfileRepository()),
        RepositoryProvider(create: (context) => TechnicianRequestRepository()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
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
            home: Builder(builder: (context) => _getInitialPage(context)),
          );
        },
      ),
    );
  }
}
