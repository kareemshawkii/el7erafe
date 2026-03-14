import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'available_request_card.dart';

class AllAvailableRequestsPage extends StatelessWidget {
  const AllAvailableRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        toolbarHeight: 50.h,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.blueAccent,
        surfaceTintColor: Colors.blueAccent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.r),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'الطلبات الجديدة',
          style: GoogleFonts.cairo(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: BlocBuilder<AvailableRequestsCubit, AvailableRequestsState>(
        builder: (context, state) {
          if (state is AvailableRequestsLoaded) {
            final requests = state.requests;
            if (requests.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد طلبات متاحة حالياً',
                  style: GoogleFonts.cairo(
                    color: Colors.grey,
                    fontSize: 16.sp,
                  ),
                ),
              );
            }
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                if (value == 1.0) {
                  return child!;
                }
                return Transform.translate(
                  offset: Offset(0, 100 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return AvailableRequestCard(request: requests[index]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
