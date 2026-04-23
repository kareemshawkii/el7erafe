// ignore_for_file: deprecated_member_use

import 'package:el7erafe/core/services/notifications/notification_api_service.dart';
import 'package:el7erafe/core/services/notifications/notification_router.dart';
import 'package:el7erafe/core/services/signal_r/signal_r_service.dart';
import 'package:el7erafe/core/utils/app_event_bus.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/repositories/current_reservations_repo.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/repositories/pending_requests_repo.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/repositories/previous_reservations_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/repositories/available_requests_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/pages/tech_home_page.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/data/repositories/tech_schedule_repository.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/repositories/previous_jobs_repo.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

enum InitialRoute {
  onboarding,
  clientHome,
  technicianHome,
  technicianWaiting,
  login
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final Future<FirebaseApp> firebaseInitFuture = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final Future<InitialRoute> routeInitFuture = _determineInitialRoute();

  await firebaseInitFuture;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  _initializeNotificationsAsync();

  final InitialRoute initialRoute = await routeInitFuture;

  runApp(MyApp(initialRoute: initialRoute));
}

Future<void> _initializeNotificationsAsync() async {
  try {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await NotificationApiService.saveFcmToken(token);
      }
    }
  } catch (_) {}
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
    SignalRService.instance.initAndConnect();
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FlutterNativeSplash.remove();
    _setupNotificationListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      SignalRService.instance.disconnect();
    }
  }

  void _setupNotificationListeners() {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          NotificationRouter.processAndRoute(message);
        });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationRouter.processAndRoute(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final context = globalNavigatorKey.currentContext;
      if (context == null) return;

      final title = message.notification?.title ?? 'إشعار جديد';
      final body =
          message.notification?.body ?? 'لديك تحديث جديد، اضغط للتفاصيل.';

      final action = message.data['Action'] ?? message.data['action'] ?? '';
      if (action.isNotEmpty) {
        AppEventBus().emit(action);
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          duration: const Duration(seconds: 5),
          content: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              NotificationRouter.processAndRoute(message);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF3775FA).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3775FA).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFF3775FA),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.cairo(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: GoogleFonts.cairo(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
        return const TechHomePage();
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
        RepositoryProvider(create: (context) => AvailableRequestsRepo()),
        RepositoryProvider(create: (context) => TechScheduleRepository()),
        RepositoryProvider(create: (context) => PreviousReservationsRepo()),
        RepositoryProvider(create: (context) => PendingRequestsRepo()),
        RepositoryProvider(create: (context) => CurrentReservationsRepo()),
        RepositoryProvider(create: (context) => PreviousJobsRepo()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: globalNavigatorKey,
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
            navigatorObservers: [UnfocusNavigatorObserver()],
            builder: (context, child) {
              final mediaQueryData = MediaQuery.of(context);
              final textScaler = mediaQueryData.textScaler;
              final clampedTextScaler = textScaler.clamp(
                minScaleFactor: 0.9,
                maxScaleFactor: 1.0,
              );
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                behavior: HitTestBehavior.opaque,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: MediaQuery(
                    data: mediaQueryData.copyWith(
                      textScaler: clampedTextScaler,
                    ),
                    child: SafeArea(
                      top: false,
                      bottom: true,
                      left: false,
                      right: false,
                      child: child!,
                    ),
                  ),
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

class UnfocusNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
