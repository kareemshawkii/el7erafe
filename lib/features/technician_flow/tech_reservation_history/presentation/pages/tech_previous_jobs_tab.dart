// ignore_for_file: deprecated_member_use
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/previous_jobs_model.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/repositories/previous_jobs_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/cubit/previous_jobs_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/cubit/previous_jobs_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class TechPreviousJobsTab extends StatefulWidget {
  const TechPreviousJobsTab({super.key});

  @override
  State<TechPreviousJobsTab> createState() => _TechPreviousJobsTabState();
}

class _TechPreviousJobsTabState extends State<TechPreviousJobsTab>
    with WidgetsBindingObserver {
  late PreviousJobsCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = PreviousJobsCubit(repository: PreviousJobsRepo())..fetchJobs();
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
      _cubit.fetchJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<PreviousJobsCubit, PreviousJobsState>(
        listener: (context, state) {
          if (state is PreviousJobsUnauth) {
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
          if (state is PreviousJobsLoading) {
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
          } else if (state is PreviousJobsError) {
            return Center(
                child: Text(state.message,
                    style: GoogleFonts.cairo(color: Colors.red)));
          } else if (state is PreviousJobsLoaded) {
            if (state.jobs.isEmpty) {
              return Center(
                  child: Text('لا توجد طلبات سابقة حالياً',
                      style: GoogleFonts.cairo(
                          color: Colors.grey, fontSize: 16.sp)));
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: state.jobs.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final item = state.jobs[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration:
                      Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildReservationCard(item),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReservationCard(PreviousJobsModel item) {
    final bool isCancelled = item.isCancelled ?? false;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
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
                        item.clientImage != null && item.clientImage!.isNotEmpty
                            ? NetworkImage(item.clientImage!)
                            : null,
                    backgroundColor: Colors.grey.shade300,
                    child: item.clientImage == null || item.clientImage!.isEmpty
                        ? Icon(Icons.person, color: Colors.white, size: 24.sp)
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    item.clientName ?? 'بدون اسم',
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
                      color: Colors.black),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildIconText(
                  icon: Icons.kitchen_outlined,
                  text: item.serviceType ?? 'غير محدد',
                ),
              ),
              Expanded(
                child: _buildIconText(
                  icon: Icons.payments_outlined,
                  text: '${item.fees ?? 0} جنيه مصري',
                ),
              )
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildIconText(
                  icon: Icons.access_time_rounded,
                  text: item.techTimeInterval ?? 'غير محدد',
                ),
              ),
              Expanded(
                child: _buildIconText(
                  icon: Icons.calendar_today_outlined,
                  text: item.day ?? 'غير محدد',
                ),
              )
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
