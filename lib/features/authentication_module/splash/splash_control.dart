import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/authentication_module/on_boarding/presentation/cubit/onboarding_cubit.dart';
import 'package:el7erafe/features/authentication_module/on_boarding/presentation/pages/onboarding_page.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_waiting_page_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/pages/technician_waiting_page.dart';
import 'package:el7erafe/technician.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends StatefulWidget {
  const SplashController({super.key});

  @override
  State<SplashController> createState() => _SplashControllerState();
}

class _SplashControllerState extends State<SplashController> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startFlow();
    });
  }

  Future<void> _startFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    final authStorage = AuthLocalStorage();
    final String? token = await authStorage.getToken();
    final String? tempToken = await authStorage.getTempToken();
    final String? userType = await authStorage.getUserType();

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      return _goToOnboarding();
    }

    if (token != null && token.isNotEmpty) {
      if (userType == "C") {
        return _goToClientHome();
      } else if (userType == "T") {
        return _goToTechnicianHome();
      }
    }

    if (tempToken != null && tempToken.isNotEmpty) {
      return _goToTechnicianWaiting();
    }

    return _goToLogin();
  }

  void _goToOnboarding() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      SlideRightRouteWithBuild(
        builder: (_) => BlocProvider(
          create: (_) => OnboardingCubit(),
          child: OnBoardingPage(),
        ),
      ),
      (route) => false,
    );
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      SlideRightRouteWithBuild(
        builder: (_) => BlocProvider(
          create: (_) => LoginCubit(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
          child: const LoginPage(),
        ),
      ),
      (route) => false,
    );
  }

  void _goToClientHome() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      SlideRightRouteWithBuild(builder: (_) => const ClientHomePage()),
      (route) => false,
    );
  }

  void _goToTechnicianHome() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      SlideRightRouteWithBuild(builder: (_) => const TechnicianPage()),
      (route) => false,
    );
  }

  void _goToTechnicianWaiting() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      SlideRightRouteWithBuild(
        builder: (_) => BlocProvider(
          create: (_) => TechnicianStatusCubit(
            statusRepository:
                RepositoryProvider.of<TechnicianRegRepository>(context),
          ),
          child: TechnicianWaitingPage(),
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
