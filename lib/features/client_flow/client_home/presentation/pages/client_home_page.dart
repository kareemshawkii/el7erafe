// ignore_for_file: deprecated_member_use

import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/chat_system/presentation/pages/inbox_page.dart';
import 'package:el7erafe/features/client_flow/client_home/data/repositories/home_repository.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/cubit/client_home_state.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/service_items.dart';
import 'package:el7erafe/features/client_flow/client_profile/presentation/pages/client_profile_page.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/presentation/reservation_history_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClientHomePageView();
  }
}

class ClientHomePageView extends StatefulWidget {
  const ClientHomePageView({super.key});

  @override
  State<ClientHomePageView> createState() => _ClientHomePageViewState();
}

class _ClientHomePageViewState extends State<ClientHomePageView> {
  String userName = "";
  String token = "";
  String currentUserID = "";
  late final HomeCubit _homeCubit;
  int _selectedIndex = 0;
  int unreadMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    _homeCubit = HomeCubit(HomeRepository())..fetchServices();
    _loadUserData();
    _homeCubit.fetchTotalUnreadCount();
  }

  Future<void> _loadUserData() async {
    final name = await AuthLocalStorage().getUserName();
    final token = await AuthLocalStorage().getToken();
    if (mounted) {
      setState(() {
        userName = name!;
        this.token = token ?? "";
      });
    }
  }

  Future<void> _refreshHomeData() async {
    String? updatedName = await AuthLocalStorage().getUserName();
    if (updatedName != null && updatedName.isNotEmpty && mounted) {
      setState(() {
        userName = updatedName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget homeContent = SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            SizedBox(height: 50.h),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.only(left: 8.w, right: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.cairo(
                          fontSize: 23.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                            text: "أهلا.. ",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: userName,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        SizedBox(width: 16.w),
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3775FA),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Iconsax.notification,
                                color: Colors.white,
                                size: 18,
                              )),
                        ),
                        SizedBox(width: 16.w),
                        Container(
                          alignment: Alignment.center,
                          width: 40.w,
                          height: 40.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3775FA),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    SlideRightRouteWithBuild(
                                      builder: (context) => const InboxPage(),
                                    ),
                                  ).then((_) {
                                    _homeCubit.fetchTotalUnreadCount();
                                  });
                                },
                                icon: const Icon(
                                  Iconsax.message5,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              if (unreadMessagesCount > 0)
                                Positioned(
                                  top: 8.h,
                                  right: 6.w,
                                  child: Container(
                                    padding: EdgeInsets.all(3.r),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: const Color(0xFF3775FA),
                                          width: 1.5),
                                    ),
                                    child: Text(
                                      unreadMessagesCount > 9
                                          ? '+9'
                                          : unreadMessagesCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                  padding: EdgeInsets.only(
                    top: 12.h,
                    left: 16.w,
                    right: 16.w,
                    bottom: 12.h,
                  ),
                  child: SvgPicture.asset("images/home_image.svg")),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Iconsax.user_search,
                      color: Color(0xFF3775FA), size: 24),
                  SizedBox(width: 8.w),
                  Text(
                    "اختر خدمتك",
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            BlocConsumer<HomeCubit, HomeState>(
              listener: (context, state) {
                if (state is HomeUnreadCountUpdated) {
                  setState(() {
                    unreadMessagesCount = state.count;
                  });
                } else if (state is HomeUnauthorized) {
                  ModernSnackbar.showError(
                      context: context, message: state.message);
                  Navigator.pushAndRemoveUntil(
                    context,
                    SlideRightRouteWithBuild(
                      builder: (context) => BlocProvider(
                        create: (context) =>
                            LoginCubit(authRepository: AuthRepository()),
                        child: const LoginPage(),
                      ),
                    ),
                    (route) => false,
                  );
                }
              },
              builder: (context, state) {
                if (state is HomeLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/icon/loading.json',
                          width: 200.w,
                          height: 200.h,
                          repeat: true,
                          animate: true,
                        ),
                      ],
                    ),
                  );
                } else if (state is HomeError) {
                  return Center(child: Text(state.message));
                } else if (state is HomeLoaded) {
                  if (state.services.isEmpty) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) =>
                          Opacity(opacity: value, child: child),
                      child: Image.asset("images/noservices.png"),
                    );
                  }
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: GridView.builder(
                        padding: EdgeInsets.all(16.r),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: state.services.length,
                        itemBuilder: (context, index) {
                          return TweenAnimationBuilder<double>(
                            key: ValueKey(state.services[index].id),
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration:
                                Duration(milliseconds: 400 + (index * 75)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child:
                                ServiceItemCard(service: state.services[index]),
                          );
                        },
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );

    final List<Widget> pages = [
      homeContent,
      ReservationHistoryPage(),
      ClientProfilePage(name: userName, token: token),
    ];

    return BlocProvider.value(
      value: _homeCubit,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: pages[_selectedIndex],
          bottomNavigationBar: SafeArea(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF6796FA)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: const Color(0xFF3775FA).withOpacity(0.1),
                    highlightColor: const Color(0xFF3775FA).withOpacity(0.1),
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: const Color(0xFF3775FA),
                    unselectedItemColor: Colors.black,
                    showUnselectedLabels: true,
                    showSelectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                    iconSize: 20.r,
                    selectedFontSize: 14.sp,
                    unselectedFontSize: 14.sp,
                    currentIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                      if (index == 0 || index == 2) {
                        _refreshHomeData();
                      }
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.home_outlined),
                        activeIcon: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 6.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3775FA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Icon(Icons.home),
                        ),
                        label: 'الرئيسيه',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.history_outlined),
                        activeIcon: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 6.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3775FA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Icon(Icons.history),
                        ),
                        label: 'سجل الحجوزات ',
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.person_2_outlined),
                        activeIcon: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 6.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3775FA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Icon(Icons.person),
                        ),
                        label: 'الاعدادات',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
