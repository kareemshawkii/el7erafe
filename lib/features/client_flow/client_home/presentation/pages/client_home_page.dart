import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/client_flow/client_home/data/repositories/home_repository.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/cubit/client_home_state.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/service_items.dart';
import 'package:el7erafe/features/client_flow/client_profile/presentation/pages/client_profile_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
  String userName = "كريم";
  String token = "";
  late final HomeCubit _homeCubit;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _homeCubit = HomeCubit(HomeRepository())..fetchServices();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await AuthLocalStorage().getUserName();
    final token = await AuthLocalStorage().getToken();
    if (mounted) {
      setState(() {
        userName = name ?? "كريم";
        this.token = token ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double height = mediaQuery.size.height;
    double width = mediaQuery.size.width;

    Widget homeContent = SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            SizedBox(height: (50 / 852) * height),
            Container(
              padding: EdgeInsets.only(
                  left: (8 / 393) * width, right: (16 / 393) * width),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.cairo(
                        fontSize: 23,
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
                      SizedBox(width: (16 / 852) * width),
                      Container(
                        alignment: Alignment.center,
                        width: (40 / 852) * height,
                        height: (40 / 852) * height,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3775FA),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Iconsax.message5,
                              color: Colors.white,
                              size: 18,
                            )),
                      ),
                      SizedBox(width: (16 / 393) * width),
                      Container(
                        width: (40 / 393) * width,
                        height: (40 / 852) * height,
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
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: (16 / 852) * height),
            Container(
                padding: EdgeInsets.only(
                  top: (12 / 852) * height,
                  left: (16 / 393) * width,
                  right: (16 / 393) * width,
                  bottom: (12 / 852) * height,
                ),
                child: SvgPicture.asset("images/home_image.svg")),
            SizedBox(height: (16 / 852) * height),
            Container(
              padding: EdgeInsets.only(
                left: (16 / 393) * width,
                right: (16 / 393) * width,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Iconsax.user_search,
                      color: Color(0xFF3775FA), size: 24),
                  SizedBox(width: (8 / 393) * width),
                  Text(
                    "اختر خدمتك",
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: (16 / 852) * height),
            BlocConsumer<HomeCubit, HomeState>(
              listener: (context, state) {
                if (state is HomeUnauthorized) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(state.message, textDirection: TextDirection.rtl),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
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
                          width: 200,
                          height: 200,
                          repeat: true,
                          animate: true,
                        ),
                      ],
                    ),
                  );
                } else if (state is HomeError) {
                  return Center(child: Text(state.message));
                } else if (state is HomeLoaded) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
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
                          return ServiceItemCard(
                              service: state.services[index]);
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
      const Center(child: Text("Booking History")),
       ClientProfilePage(name: userName, token: token),
    ];

    return BlocProvider.value(
      value: _homeCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: pages[_selectedIndex],
        bottomNavigationBar: ClipRRect(
          borderRadius:  BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Container(
            height: (90 / 852) * height,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF6796FA)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                // ignore: deprecated_member_use
                splashColor: const Color(0xFF3775FA).withOpacity(0.1),
                // ignore: deprecated_member_use
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
                iconSize: 20,
                selectedFontSize: 14,
                unselectedFontSize: 14,
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    activeIcon: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 20),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: const Color(0xFF3775FA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.home),
                    ),
                    label: 'الرئيسيه',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.history_outlined),
                    activeIcon: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 20),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: const Color(0xFF3775FA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.history),
                    ),
                    label: 'سجل الحجوزات ',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person_2_outlined),
                    activeIcon: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 20),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: const Color(0xFF3775FA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}
