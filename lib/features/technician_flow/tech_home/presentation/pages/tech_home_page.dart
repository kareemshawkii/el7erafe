// ignore_for_file: deprecated_member_use
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/chat_system/presentation/pages/inbox_page.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/repositories/available_requests_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_state.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/tech_home_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/pages/tech_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'tech_home_requests_widget.dart';

class TechHomePage extends StatelessWidget {
  const TechHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AvailableRequestsCubit(
            repository: AvailableRequestsRepo(),
          )..fetchAvailableRequests(),
        ),
      ],
      child: const TechHomePageView(),
    );
  }
}

class TechHomePageView extends StatefulWidget {
  const TechHomePageView({super.key});

  @override
  State<TechHomePageView> createState() => _TechHomePageViewState();
}

class _TechHomePageViewState extends State<TechHomePageView> {
  String userName = "";
  String token = "";
  String currentUserID = "";
  late final TechHomeCubit _techHomeCubit;
  int _selectedIndex = 0;
  int unreadMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    _techHomeCubit = TechHomeCubit();
    _loadUserData();
    _techHomeCubit.fetchTotalUnreadCount();
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
    Widget homeContent =
        BlocListener<AvailableRequestsCubit, AvailableRequestsState>(
      listener: (context, state) async {
        if (state is AvailableRequestsUnauthorized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى',
                  textDirection: TextDirection.rtl),
              backgroundColor: Colors.red,
            ),
          );
          await AuthLocalStorage().deleteToken();
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            SlideRightRouteWithBuild(
              builder: (_) => BlocProvider(
                create: (_) => LoginCubit(
                  authRepository:
                      RepositoryProvider.of<AuthRepository>(context),
                ),
                child: const LoginPage(),
              ),
            ),
            (route) => false,
          );
        }
      },
      child: SingleChildScrollView(
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
                                      _techHomeCubit.fetchTotalUnreadCount();
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
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: const TechHomeRequestsWidget(),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );

    final List<Widget> pages = [
      homeContent,
      const Center(child: Text("schedule History")),
      TechProfilePage(name: userName, token: token),
    ];

    return BlocProvider.value(
      value: _techHomeCubit,
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
                        icon: const Icon(Icons.calendar_month),
                        activeIcon: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 6.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3775FA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Icon(Icons.calendar_month),
                        ),
                        label: 'المواعيد',
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
