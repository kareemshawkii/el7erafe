import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_state.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/pages/all_available_requests_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'available_request_card.dart';

class TechHomeRequestsWidget extends StatelessWidget {
  const TechHomeRequestsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailableRequestsCubit, AvailableRequestsState>(
      builder: (context, state) {
        if (state is AvailableRequestsLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3775FA)));
        } else if (state is AvailableRequestsError) {
          return Center(
            child: Text(
              state.error,
              style: GoogleFonts.cairo(color: Colors.red),
            ),
          );
        } else if (state is AvailableRequestsLoaded) {
          final requests = state.requests;
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
                  padding: EdgeInsets.only(top: 24.h),
                  child: Center(
                    child: Text(
                      'لا توجد طلبات متاحة حالياً',
                      style: GoogleFonts.cairo(
                        color: Colors.grey,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                )
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
                SizedBox(height: 12.h),
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
