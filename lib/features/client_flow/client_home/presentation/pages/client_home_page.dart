import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
//import 'package:el7erafe/features/client_flow/client_home/data/models/quick_reservation_request.dart';
import 'package:el7erafe/features/client_flow/client_home/data/models/service_item.dart';
import 'package:el7erafe/features/client_flow/client_home/data/repositories/home_repository.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/cubit/client_home_state.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/pages/quick_reserve_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClientHomePageView();
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await AuthLocalStorage().getUserName();
    final token = await AuthLocalStorage().getToken();
    setState(() {
      userName = name ?? "كريم";
      this.token = token ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double height = mediaQuery.size.height;
    double width = mediaQuery.size.width;

    return BlocProvider(
        create: (context) => HomeCubit(HomeRepository())..fetchServices(),
        child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: Container(
                padding: EdgeInsets.only(
                    left: (24 / 852) * width, right: (24 / 852) * width),
                height: (80 / 852) * height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  border: Border.all(color: Color(0xFF6796FA)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Color(0x333775FA),
                    highlightColor: Color(0x333775FA),
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        label: 'الرئيسيه',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.history_outlined),
                        label: 'سجل الحجوزات ',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_2_outlined),
                        label: 'الاعدادات',
                      ),
                    ],
                    selectedItemColor: const Color(0xFF3775FA),
                    unselectedItemColor: Colors.black,
                    showUnselectedLabels: true,
                    showSelectedLabels: true,
                    type: BottomNavigationBarType.fixed,
                    iconSize: 20,
                    selectedFontSize: 14,
                    unselectedFontSize: 14,
                  ),
                )),
            body: SingleChildScrollView(
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
                                TextSpan(
                                  text: "أهلا.. ",
                                  style: const TextStyle(
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
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3775FA),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Iconsax.message5,
                                      color: Colors.white,
                                      size: 18,
                                    )),
                              ),
                              SizedBox(width: (16 / 393) * width),
                              Container(
                                width: (40 / 393) * width,
                                height: (40 / 852) * height,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3775FA),
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
                      )),
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
                            Icon(Iconsax.user_search,
                                color: const Color(0xFF3775FA), size: 24),
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
                          ])),
                  SizedBox(height: (16 / 852) * height),
                  BlocConsumer<HomeCubit, HomeState>(
                    listener: (context, state) {
                      if (state is HomeUnauthorized) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message,
                                textDirection: TextDirection.rtl),
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
                        return Center(child: CircularProgressIndicator());
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
                                    return _buildServiceCard(
                                        context, state.services[index]);
                                  },
                                )));
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ))));
  }
}

Widget _buildServiceCard(BuildContext context, ServiceItem service) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ServiceRequestPage(
                serviceId: service.id, serviceName: service.name)),
      );
    },
    child: Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFF6796FA), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(service.imageUrl,
              width: 60,
              height: 60,
              errorBuilder: (_, __, ___) => Icon(Icons.error)),
          SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(service.name,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
          )
        ],
      ),
    ),
  );
}
