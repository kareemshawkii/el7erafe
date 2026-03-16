import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/models/available_request_model.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/repositories/available_requests_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/pages/available_request_details_page.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/pages/make_offer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

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
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.home_repair_service_outlined,
                    size: 20.r, color: const Color(0xFF3775FA)),
                SizedBox(width: 8.w),
                Flexible(
                  flex: 1,
                  child: Text(
                    request.serviceType ?? 'خدمة غير محددة',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 1.w,
                  height: 14.h,
                  color: Colors.grey.shade400,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 2,
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
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: request.clientImage ??
                              'https://i.pinimg.com/736x/23/d1/3a/23d13a1dbad6a60319413ec2512aed29.jpg',
                          width: 32.w,
                          height: 32.h,
                          fit: BoxFit.cover,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              width: 32.w,
                              height: 32.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: const Icon(Icons.person, size: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
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
                ),
                SizedBox(width: 8.w),
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16.r, color: Colors.black),
                    SizedBox(width: 4.w),
                    Container(
                      constraints: BoxConstraints(maxWidth: 100.w),
                      child: Text(
                        request.city ?? 'عنوان غير محدد',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
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
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40.h,
                    child: ElevatedButton(
                      onPressed: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: 'MakeOfferDialog',
                          barrierColor: Colors.black54,
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return BlocProvider(
                              create: (_) => AvailableRequestsCubit(
                                  repository: AvailableRequestsRepo()),
                              child: MakeOfferDialog(
                                requestId: request.requestId,
                                clientTimeInterval: request.clientTimeInterval,
                              ),
                            );
                          },
                          transitionBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return ScaleTransition(
                              scale:
                                  Tween<double>(begin: 0.8, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutBack,
                                ),
                              ),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                        ).then((result) {
                          if (result == true) {
                            if (!context.mounted) return;
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
                                      Icon(Icons.check_circle,
                                          color: Colors.green, size: 28.r),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "مهمة ناجحة",
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    "تم تقديم العرض بنجاح!",
                                    style: GoogleFonts.cairo(
                                      fontSize: 15.sp,
                                      color: Colors.black87,
                                    ),
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
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            context
                                .read<AvailableRequestsCubit>()
                                .fetchAvailableRequests();
                          }
                        });
                      },
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
                    height: 40.h,
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
