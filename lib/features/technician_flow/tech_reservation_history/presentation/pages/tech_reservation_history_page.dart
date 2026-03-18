import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/pages/calender_tab.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/pages/pending_offers_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class TechReservationHistoryPage extends StatelessWidget {
  const TechReservationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.history,
                  color: const Color(0xFF3775FA),
                  size: 24.r,
                ),
                SizedBox(width: 8.w),
                Text(
                  'سجل الحجوزات',
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 200 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Column(
            children: [
              Container(color: Colors.white, child: _buildTabBar()),
              const Expanded(
                child: TabBarView(
                  children: [
                    TechCurrentReservationsTab(),
                    PendingOffersTab(),
                    Center(child: Text('الطلبات المكتملة')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFFE2DFDF)),
          ),
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelPadding: EdgeInsets.zero,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              color: const Color(0xFF3775FA),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            labelStyle: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, size: 18.r),
                    SizedBox(width: 6.w),
                    const Text('المقبولة'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.clock, size: 18.r),
                    SizedBox(width: 6.w),
                    const Text('المقدمة'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.tick_circle, size: 18.r),
                    SizedBox(width: 6.w),
                    const Text('المكتملة'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
