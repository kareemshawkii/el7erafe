import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/client_flow/client_home/data/models/quick_reservation_request.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:el7erafe/features/client_flow/select_technician/data/models/request_model.dart';
import 'package:el7erafe/features/client_flow/select_technician/data/repositories/select_technician_repo.dart';
import 'package:el7erafe/features/client_flow/select_technician/presentation/cubit/technician_request_cubit.dart';
import 'package:el7erafe/features/client_flow/select_technician/presentation/cubit/technician_request_state.dart';
import 'package:el7erafe/features/client_flow/select_technician/presentation/pages/technician_details_page.dart';
import 'package:el7erafe/features/client_flow/select_technician/presentation/pages/technician_items.dart';
import 'package:el7erafe/features/client_flow/select_technician/presentation/pages/technician_reservation_success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class TechnicianReservePage extends StatelessWidget {
  final ReservationRequest requestModel;

  const TechnicianReservePage({super.key, required this.requestModel});

  @override
  Widget build(BuildContext context) {
    return TechnicianRequestPage(requestModel: requestModel);
  }
}

class TechnicianRequestPage extends StatefulWidget {
  final ReservationRequest requestModel;

  const TechnicianRequestPage({super.key, required this.requestModel});

  @override
  State<TechnicianRequestPage> createState() => _TechnicianRequestPageState();
}

class _TechnicianRequestPageState extends State<TechnicianRequestPage> {
  String _searchQuery = "";
  bool _isSortedByRate = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TechnicianRequestCubit(TechnicianRequestRepository())
        ..fetchTechnicians(
          service: widget.requestModel.serviceName!,
          city: widget.requestModel.city ?? "",
          sort: _isSortedByRate,
        ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.r),
              onPressed: () => Navigator.pop(context),
            ),
            toolbarHeight: 50.h,
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.blueAccent,
            surfaceTintColor: Colors.blueAccent,
            centerTitle: true,
            title: Text.rich(
              TextSpan(
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.5,
                ),
                children: <TextSpan>[
                  const TextSpan(text: "اختر الحرفي المناسب لطلب "),
                  TextSpan(
                    text: widget.requestModel.serviceName,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: Builder(builder: (context) {
            return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 0),
                                ),
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: "ابحث عن اسم حرفي",
                                    hintStyle: GoogleFonts.cairo(
                                        color: Colors.grey, fontSize: 18.sp),
                                    border: InputBorder.none,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.w,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide(
                                        color: Color(0xFF3775FA),
                                        width: 1.w,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 10.h),
                                    prefixIcon: Icon(Icons.search,
                                        color: Colors.grey, size: 20.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3775FA),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: PopupMenuButton<bool>(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                icon: Icon(Icons.filter_list,
                                    color: Colors.white, size: 20.r),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: const BorderSide(
                                    color: Color(0xFF3775FA),
                                    width: 1,
                                  ),
                                ),
                                offset: Offset(0, 50.h),
                                onSelected: (bool isRate) {
                                  if (_isSortedByRate != isRate) {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _isSortedByRate = isRate;
                                    });
                                    context
                                        .read<TechnicianRequestCubit>()
                                        .fetchTechnicians(
                                          service:
                                              widget.requestModel.serviceName!,
                                          city: widget.requestModel.city ?? "",
                                          sort: isRate,
                                        );
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: false,
                                    child: Text("حسب المنطقه",
                                        style: GoogleFonts.cairo(
                                            fontWeight: !_isSortedByRate
                                                ? FontWeight.bold
                                                : FontWeight.normal)),
                                  ),
                                  PopupMenuDivider(
                                    thickness: 1,
                                    height: 4.h,
                                    indent: 16.w,
                                    endIndent: 16.w,
                                    color: Colors.grey.shade300,
                                  ),
                                  PopupMenuItem(
                                    value: true,
                                    child: Text("حسب التقييم",
                                        style: GoogleFonts.cairo(
                                            fontWeight: _isSortedByRate
                                                ? FontWeight.bold
                                                : FontWeight.normal)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocConsumer<TechnicianRequestCubit,
                          TechnicianRequestState>(
                        listener: (context, state) {
                          if (state is FetchTechniciansError ||
                              state is SubmitReservationError) {
                            final String errorMessage =
                                state is FetchTechniciansError
                                    ? state.message
                                    : (state as SubmitReservationError).message;
                            showDialog(
                              context: context,
                              builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16.r)),
                                  title: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.red, size: 28.r),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "تنبيه",
                                        style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.sp),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    errorMessage,
                                    style: GoogleFonts.cairo(
                                        fontSize: 14.sp, color: Colors.black87),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "حسناً",
                                        style: GoogleFonts.cairo(
                                            color: const Color(0xFF3775FA),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is ServiceRequestConflict) {
                            showDialog(
                              context: context,
                              builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16.r)),
                                  title: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.red, size: 28.r),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "تنبيه",
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    state.message,
                                    style: GoogleFonts.cairo(
                                      fontSize: 15.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ClientHomePage(),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      child: Text(
                                        "حسناً",
                                        style: GoogleFonts.cairo(
                                          color: const Color(0xFF3775FA),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (state is TechnicianRequestUnauth) {
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
                                  create: (context) => LoginCubit(
                                      authRepository: AuthRepository()),
                                  child: const LoginPage(),
                                ),
                              ),
                              (route) => false,
                            );
                          } else if (state is SubmitReservationSuccess) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const SelectTechnicianSuccessPage()),
                              (route) => false,
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is FetchTechniciansLoading ||
                              state is SubmitReservationLoading) {
                            return Center(
                              child: Lottie.asset(
                                'assets/icon/loading.json',
                                width: 200.w,
                                height: 200.h,
                                repeat: true,
                                animate: true,
                              ),
                            );
                          }
                          if (state is FetchTechniciansSuccess) {
                            final techniciansList = state.data.where((tech) {
                              return tech.name
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase());
                            }).toList();
                            if (techniciansList.isEmpty) {
                              return Center(
                                child: Image.asset(
                                  _searchQuery.isEmpty
                                      ? "images/notech.png"
                                      : "images/notechfound.png",
                                  width: 200.w,
                                  height: 200.h,
                                ),
                              );
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.only(
                                  left: 16.w,
                                  right: 16.w,
                                  top: 0,
                                  bottom: 50.h),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 250.h,
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 10.h,
                              ),
                              itemCount: techniciansList.length,
                              itemBuilder: (context, index) {
                                final technician = techniciansList[index];

                                final requestCubit =
                                    context.read<TechnicianRequestCubit>();

                                return TechnicianCard(
                                  technician: technician,
                                  onCardTap: () {
                                    Navigator.push(
                                      context,
                                      SlideRightRouteWithBuild(
                                        builder: (newContext) =>
                                            BlocProvider.value(
                                          value: requestCubit,
                                          child: TechnicianDetailsPage(
                                            technician: technician,
                                            onReserveTap: () {
                                              final fullRequest =
                                                  TechnicianReservationRequest(
                                                serviceId: widget
                                                    .requestModel.serviceId,
                                                description: widget
                                                    .requestModel.description,
                                                city: widget.requestModel.city,
                                                street:
                                                    widget.requestModel.street,
                                                specialSign: widget
                                                    .requestModel.specialSign,
                                                day: widget.requestModel.day,
                                                allDayAvailability: widget
                                                    .requestModel
                                                    .allDayAvailability,
                                                availableFrom: widget
                                                    .requestModel.availableFrom,
                                                availableTo: widget
                                                    .requestModel.availableTo,
                                                images:
                                                    widget.requestModel.images,
                                                technicianId:
                                                    technician.id.toString(),
                                              );

                                              requestCubit.submitReservation(
                                                  fullRequest);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  onReserveTap: () {
                                    final fullRequest =
                                        TechnicianReservationRequest(
                                      serviceId: widget.requestModel.serviceId,
                                      description:
                                          widget.requestModel.description,
                                      city: widget.requestModel.city,
                                      street: widget.requestModel.street,
                                      specialSign:
                                          widget.requestModel.specialSign,
                                      day: widget.requestModel.day,
                                      allDayAvailability: widget
                                          .requestModel.allDayAvailability,
                                      availableFrom:
                                          widget.requestModel.availableFrom,
                                      availableTo:
                                          widget.requestModel.availableTo,
                                      images: widget.requestModel.images,
                                      technicianId: technician.id.toString(),
                                    );

                                    requestCubit.submitReservation(fullRequest);
                                  },
                                );
                              },
                            );
                          }
                          if (state is FetchTechniciansError) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.r),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red, size: 60.r),
                                    SizedBox(height: 16.h),
                                    Text(
                                      state.message,
                                      style: GoogleFonts.cairo(
                                          fontSize: 16.sp,
                                          color: Colors.black87),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 24.h),
                                    ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<TechnicianRequestCubit>()
                                            .fetchTechnicians(
                                              service: widget
                                                  .requestModel.serviceName!,
                                              city: widget.requestModel.city ??
                                                  "",
                                              sort: _isSortedByRate,
                                            );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF3775FA),
                                      ),
                                      child: Text(
                                        "إعادة المحاولة",
                                        style: GoogleFonts.cairo(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ));
          }),
        ),
      ),
    );
  }
}
