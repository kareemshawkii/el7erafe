import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/previous_reservation_model.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/repositories/previous_reservations_repo.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/previous_reservations_cubit.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/previous_reservations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class PreviousReservationsTab extends StatefulWidget {
  const PreviousReservationsTab({super.key});

  @override
  State<PreviousReservationsTab> createState() =>
      _PreviousReservationsTabState();
}

class _PreviousReservationsTabState extends State<PreviousReservationsTab>
    with WidgetsBindingObserver {
  late PreviousReservationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = PreviousReservationsCubit(repository: PreviousReservationsRepo())
      ..fetchReservations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.fetchReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<PreviousReservationsCubit, PreviousReservationsState>(
        listener: (context, state) {
          if (state is PreviousReservationsUnauth) {
            ModernSnackbar.showError(
                context: context,
                message: "انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى");
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
        builder: (context, state) {
          if (state is PreviousReservationsLoading) {
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
          } else if (state is PreviousReservationsError) {
            return Center(
                child: Text(state.message,
                    style: GoogleFonts.cairo(color: Colors.red)));
          } else if (state is PreviousReservationsLoaded) {
            if (state.reservations.isEmpty) {
              return Center(
                  child: Text('لا توجد طلبات سابقة حالياً',
                      style: GoogleFonts.cairo(
                          color: Colors.grey, fontSize: 16.sp)));
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: state.reservations.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final item = state.reservations[index];
                return _buildReservationCard(item);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReservationCard(PreviousReservationModel item) {
    final bool isCancelled = item.isCancelled ?? false;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          // ignore: deprecated_member_use
          color: const Color(0xFF3775FA).withOpacity(0.4),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage:
                        item.techImage != null && item.techImage!.isNotEmpty
                            ? NetworkImage(item.techImage!)
                            : null,
                    backgroundColor: Colors.grey.shade300,
                    child: item.techImage == null || item.techImage!.isEmpty
                        ? Icon(Icons.person, color: Colors.white, size: 24.sp)
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    item.techName ?? 'بدون اسم',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? Colors.grey.shade300
                      // ignore: deprecated_member_use
                      : const Color(0xFF1A4BC7).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isCancelled
                        ? Colors.grey.shade400
                        : const Color(0xFF1A4BC7),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  isCancelled ? 'ملغي' : 'تم الانتهاء',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconText(
                icon: Icons.kitchen_outlined,
                text: item.serviceType ?? 'غير محدد',
              ),
              _buildIconText(
                icon: Icons.payments_outlined,
                text: '${item.fees ?? 0} جنيه مصري',
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconText(
                icon: Icons.access_time_rounded,
                text: item.techTimeInterval ?? 'غير محدد',
              ),
              _buildIconText(
                icon: Icons.calendar_today_outlined,
                text: item.day ?? 'غير محدد',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconText({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: Colors.black),
        SizedBox(width: 8.w),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
