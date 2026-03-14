import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/models/available_request_model.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/pages/available_request_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:iconsax/iconsax.dart';

class AvailableRequestCard extends StatelessWidget {
  final AvailableRequestModel request;

  const AvailableRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SlideRightRouteWithBuild(
            builder: (context) => AvailableRequestDetailsPage(request: request),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF3775FA), width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.home_repair_service_outlined,
                        size: 20.r, color: const Color(0xFF3775FA)),
                    SizedBox(width: 8.w),
                    Text(
                      request.serviceType ?? 'خدمة غير محددة',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text(
                    'وصف الطلب:  ',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(
                    width: 150.w,
                    child: Text(
                      request.description ?? 'لا يوجد وصف',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  )
                ]),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16.r, color: Colors.black),
                    SizedBox(width: 4.w),
                    Text(
                      request.city ?? 'عنوان غير محدد',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: request.clientImage ??
                            'https://i.pinimg.com/736x/23/d1/3a/23d13a1dbad6a60319413ec2512aed29.jpg',
                        width: 32.w,
                        height: 32.h,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.person)),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SizedBox(
                      width: 58.w,
                      child: Text(
                        request.clientName ?? 'عميل',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.access_time, size: 16.r, color: Colors.black),
                    SizedBox(width: 4.w),
                    Text(
                      request.clientTimeInterval ?? 'طول اليوم',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 16.r, color: Colors.black),
                    SizedBox(width: 4.w),
                    Text(
                      request.day ?? '--/--/----',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3775FA),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection: TextDirection.rtl,
                        children: [
                          Icon(Iconsax.send, color: Colors.white, size: 16.r),
                          SizedBox(width: 8.w),
                          Text(
                            'تقديم عرض',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3775FA)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection: TextDirection.rtl,
                        children: [
                          Icon(Icons.close, color: Colors.black, size: 20.r),
                          SizedBox(width: 8.w),
                          Text(
                            'رفض',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
