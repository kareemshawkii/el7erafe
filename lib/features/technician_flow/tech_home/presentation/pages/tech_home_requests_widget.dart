import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_state.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/pages/all_available_requests_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:lottie/lottie.dart';
import 'available_request_card.dart';

class TechHomeRequestsWidget extends StatefulWidget {
  const TechHomeRequestsWidget({super.key});

  @override
  State<TechHomeRequestsWidget> createState() => _TechHomeRequestsWidgetState();
}

class _TechHomeRequestsWidgetState extends State<TechHomeRequestsWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AvailableRequestsCubit>().reconnectAndRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      context.read<AvailableRequestsCubit>().disconnectSignalR();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailableRequestsCubit, AvailableRequestsState>(
      builder: (context, state) {
        if (state is AvailableRequestsLoading ||
            state is MakeOfferLoading ||
            state is DeclineRequestLoading ||
            state is CompleteJobLoading) {
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
        } else if (state is AvailableRequestsError) {
          return Center(
            child: Text(
              state.error,
              style: GoogleFonts.cairo(color: Colors.red),
            ),
          );
        } else if (state is AvailableRequestsLoaded) {
          final requests = state.requests.reversed.toList();
          final displayRequests = requests.take(2).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(Iconsax.task_square,
                          color: const Color(0xFF3775FA), size: 24.r),
                      SizedBox(width: 8.w),
                      Text(
                        'الطلبات الجديدة',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '(${requests.length})',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3775FA),
                        ),
                      ),
                    ],
                  ),
                  if (requests.length > 2)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideRightRouteWithBuild(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AvailableRequestsCubit>(),
                              child: const AllAvailableRequestsPage(),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'مشاهده الكل',
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3775FA),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF3775FA),
                        ),
                      ),
                    ),
                ],
              ),
              if (requests.isEmpty)
                Padding(
                    padding: EdgeInsets.only(top: 24.h, bottom: 24.h),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFF),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                              color:
                                  // ignore: deprecated_member_use
                                  const Color(0xFF3775FA).withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 48.r, color: const Color(0xFF3775FA)),
                            SizedBox(height: 12.h),
                            Text(
                              "لا يوجد طلبات جديدة حاليا",
                              style: GoogleFonts.cairo(
                                fontSize: 16.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
              else
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 100 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayRequests.length,
                    itemBuilder: (context, index) {
                      return AvailableRequestCard(
                          request: displayRequests[index]);
                    },
                  ),
                ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1.h,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
