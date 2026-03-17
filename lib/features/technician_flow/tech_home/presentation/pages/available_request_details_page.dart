import 'package:el7erafe/features/technician_flow/tech_home/data/models/available_request_model.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/repositories/available_requests_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/pages/make_offer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer_ai/shimmer_ai.dart';

class AvailableRequestDetailsPage extends StatelessWidget {
  final AvailableRequestModel request;

  const AvailableRequestDetailsPage({super.key, required this.request});

  void _showImagesSheet(BuildContext context, List<String> images) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
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
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: PageController(initialPage: images.length - 1),
                    reverse: true,
                    itemCount: images.length,
                    itemBuilder: (context, idx) {
                      return InteractiveViewer(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 16.h),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.network(
                              images[idx],
                              width: double.infinity,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.white,
                                ).withShimmerAi(
                                  loading: true,
                                  width: double.infinity,
                                  height: double.infinity,
                                  borderRadius: 16,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (images.length > 1)
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Text(
                      'اسحب لليمين واليسار لرؤية باقي الصور',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: const Color(0xFF3775FA),
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final validImages = request.serviceImages
        .where((img) =>
            img.trim().isNotEmpty && img.trim().toLowerCase() != "string")
        .toList();
    final reversedImages = validImages.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 24.r),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'تفاصيل الطلب',
          style: GoogleFonts.cairo(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(color: const Color(0xFF3775FA), height: 1.h),
        ),
      ),
      body: TweenAnimationBuilder<double>(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FF),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFF3775FA)),
                  ),
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipOval(
                            child: Image.network(
                              request.clientImage ??
                                  'https://i.pinimg.com/736x/23/d1/3a/23d13a1dbad6a60319413ec2512aed29.jpg',
                              width: 40.w,
                              height: 40.h,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 40.w,
                                  height: 40.h,
                                  color: Colors.white,
                                ).withShimmerAi(
                                  loading: true,
                                  width: 40,
                                  height: 40,
                                  borderRadius: 20,
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            request.clientName ?? 'عميل',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Icon(Icons.calendar_today_outlined,
                                        size: 18.r,
                                        color: const Color(0xFF3775FA)),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'تاريخ الحجز : ',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF3775FA),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  request.day ?? '--/--/----',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: const _DashedLine(),
                            ),
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 18.r,
                                        color: const Color(0xFF3775FA)),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'الوقت : ',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF3775FA),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  request.clientTimeInterval ??
                                      'متاح طول اليوم',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.description_outlined,
                                    size: 18.r, color: const Color(0xFF3775FA)),
                                SizedBox(width: 8.w),
                                Text(
                                  'تفاصيل الطلب :',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15.sp,
                                    color: const Color(0xFF3775FA),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              request.description ?? 'لا يوجد وصف متاح',
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                      if (validImages.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.image_outlined,
                                      size: 18.r,
                                      color: const Color(0xFF3775FA)),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'صور المشكلة :',
                                    style: GoogleFonts.cairo(
                                      fontSize: 15.sp,
                                      color: const Color(0xFF3775FA),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              SizedBox(
                                height: 80.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: validImages.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(width: 8.w),
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () => _showImagesSheet(
                                          context, validImages),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: Image.network(
                                          reversedImages[index],
                                          width: 80.w,
                                          height: 80.h,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              width: 80.w,
                                              height: 80.h,
                                              color: Colors.white,
                                            ).withShimmerAi(
                                              loading: true,
                                              width: 80,
                                              height: 80,
                                              borderRadius: 8,
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 18.r, color: const Color(0xFF3775FA)),
                                SizedBox(width: 8.w),
                                Text(
                                  'تفاصيل العنوان :',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15.sp,
                                    color: const Color(0xFF3775FA),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildAddressRow(
                                'المحافظة : ', request.governorate),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: const _DashedLine(),
                            ),
                            _buildAddressRow('المدينة : ', request.city),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: const _DashedLine(),
                            ),
                            _buildAddressRow('الشارع : ', request.street),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: const _DashedLine(),
                            ),
                            _buildAddressRow(
                                'علامة مميزة : ', request.specialSign),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 45.h,
                      child: ElevatedButton(
                        onPressed: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: 'MakeOfferDialog',
                            barrierColor: Colors.black54,
                            transitionDuration:
                                const Duration(milliseconds: 400),
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return BlocProvider(
                                create: (_) => AvailableRequestsCubit(
                                    repository: AvailableRequestsRepo()),
                                child: MakeOfferDialog(
                                  requestId: request.requestId,
                                  clientTimeInterval:
                                      request.clientTimeInterval,
                                ),
                              );
                            },
                            transitionBuilder: (context, animation,
                                secondaryAnimation, child) {
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
                      height: 45.h,
                      child: OutlinedButton(
                        onPressed: () {
                          context
                              .read<AvailableRequestsCubit>()
                              .declineRequest(request.requestId);
                          Navigator.pop(context);
                          context
                              .read<AvailableRequestsCubit>()
                              .fetchAvailableRequests();
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value ?? '--',
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.grey.shade300),
              ),
            );
          }),
        );
      },
    );
  }
}
