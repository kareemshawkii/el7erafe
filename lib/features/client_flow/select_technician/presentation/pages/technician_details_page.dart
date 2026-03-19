// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:el7erafe/features/client_flow/select_technician/data/models/technicians_model.dart';
import 'package:el7erafe/features/client_flow/select_technician/presentation/pages/technician_reservation_success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/client_flow/select_technician/presentation/cubit/technician_request_cubit.dart';
import 'package:el7erafe/features/client_flow/select_technician/presentation/cubit/technician_request_state.dart';

class TechnicianDetailsPage extends StatelessWidget {
  final TechniciansModel technician;
  final VoidCallback onReserveTap;

  const TechnicianDetailsPage({
    super.key,
    required this.technician,
    required this.onReserveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.r),
            onPressed: () => Navigator.pop(context),
          ),
          toolbarHeight: 50.h,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.blueAccent,
          surfaceTintColor: Colors.blueAccent,
          centerTitle: true,
        ),
        backgroundColor: const Color(0xFF3775FA),
        bottomNavigationBar: _buildBottomButtons(context),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 200 * (1 - value)),
                          child: child,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 50.h),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: ListView(
                          padding: EdgeInsets.only(
                              top: 60.h, left: 16.w, right: 16.w, bottom: 24.h),
                          children: [
                            Text(
                              technician.name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildStatItem(Icons.handyman_outlined,
                                    technician.serviceName),
                                SizedBox(width: 20.w),
                                _buildStatItem(Icons.star,
                                    technician.rating.toStringAsFixed(1),
                                    iconColor: const Color(0xFFFFC107)),
                                SizedBox(width: 20.w),
                                _buildStatItem(Icons.location_on_outlined,
                                    technician.city),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            _buildAboutSection(),
                            SizedBox(height: 16.h),
                            _buildPortfolioSection(context),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF3775FA),
                                    width: 2.w)),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: technician.profilePicture.isNotEmpty
                                    ? technician.profilePicture
                                    : 'https://i.pinimg.com/736x/62/09/cc/6209cc7f4a9201b74b3a85ef329d3996.jpg',
                                width: 90.w,
                                height: 90.h,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.person,
                                      color: Colors.grey, size: 40.r),
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text,
      {Color iconColor = const Color(0xFF3775FA)}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20.r),
        SizedBox(width: 4.w),
        Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    final String aboutText = technician.about.isNotEmpty
        ? technician.about
        : "أنا ${technician.name}، فني ${technician.serviceName} متخصص ومحترف. أحرص دائماً على تقديم أفضل خدمة بأعلى جودة وفي أسرع وقت. أهم حاجة عندي إن العميل يبقى مبسوط وشغلي يطلع مظبوط من أول مرة.";

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: const Color(0xFF3775FA).withOpacity(0.5), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline,
                  color: const Color(0xFF3775FA), size: 24.r),
              SizedBox(width: 8.w),
              Text(
                "عن الفني",
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            aboutText,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              height: 1.6,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection(BuildContext context) {
    final List<String> images = technician.portfolioImages.isNotEmpty
        ? technician.portfolioImages
        : [
            'https://i.pinimg.com/736x/3b/a6/5f/3ba65fc5db6e2f664519763be5938ae0.jpg',
            'https://i.pinimg.com/1200x/50/09/e2/5009e263c5fd7e808d33955fcacdfb24.jpg',
            'https://i.pinimg.com/736x/e8/a5/60/e8a560c4098566ceac168f5d0349b7fe.jpg',
            'https://i.pinimg.com/736x/88/2c/fb/882cfb5f896c6f6f4d1243c5de88baf6.jpg',
            'https://i.pinimg.com/736x/62/50/7d/62507de3939c078a7834747a705962ba.jpg',
          ];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: const Color(0xFF3775FA).withOpacity(0.5), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library_outlined,
                  color: const Color(0xFF3775FA), size: 24.r),
              SizedBox(width: 8.w),
              Text(
                "صور من شغلي",
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => _showImageGallery(context, images),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                images.length > 3 ? 3 : images.length,
                (index) {
                  bool isLastWithMore = index == 2 && images.length > 3;
                  return Expanded(
                    child: Container(
                      height: 90.h,
                      margin: EdgeInsets.only(
                          left: index == 0 ? 8.w : (index == 2 ? 0 : 8.w)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: images[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey.shade200),
                              errorWidget: (context, url, error) =>
                                  Container(color: Colors.grey.shade200),
                            ),
                            if (isLastWithMore)
                              Container(
                                color: Colors.black.withOpacity(0.5),
                                alignment: Alignment.center,
                                child: Text(
                                  "+${images.length - 2}",
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(BuildContext context, List<String> images) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            insetPadding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "معرض الأعمال",
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: Colors.black54, size: 20.r),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: GridView.builder(
                    padding:
                        EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFF3775FA).withOpacity(0.5),
                            width: 1.w,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.w),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey, size: 40.r),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 16.w, right: 16.w, bottom: 32.h, top: 16.h),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: BlocConsumer<TechnicianRequestCubit, TechnicianRequestState>(
        listener: (context, state) {
          if (state is SubmitReservationError) {
            showDialog(
              context: context,
              builder: (context) => Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                  title: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.red, size: 28.r),
                      SizedBox(width: 8.w),
                      Text("تنبيه",
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold, fontSize: 18.sp)),
                    ],
                  ),
                  content: Text(state.message,
                      style: GoogleFonts.cairo(
                          fontSize: 14.sp, color: Colors.black87)),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (state.message ==
                            "لقد قمت بالفعل بتقديم طلب لهذه الخدمة مسبقاً، يرجى انتظار عروض الفنيين للرد على طلبك") {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            SlideRightRouteWithBuild(
                                builder: (_) => const ClientHomePage()),
                            (route) => false,
                          );
                        }
                      },
                      child: Text("حسناً",
                          style: GoogleFonts.cairo(
                              color: const Color(0xFF3775FA),
                              fontWeight: FontWeight.bold)),
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
                      borderRadius: BorderRadius.circular(16.r)),
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
                          SlideRightRouteWithBuild(
                            builder: (context) => ClientHomePage(),
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
                content: Text(state.message, textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                builder: (context) => BlocProvider(
                  create: (context) =>
                      LoginCubit(authRepository: AuthRepository()),
                  child: const LoginPage(),
                ),
              ),
              (route) => false,
            );
          } else if (state is SubmitReservationSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                  builder: (_) => const SelectTechnicianSuccessPage()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          bool isLoading = state is SubmitReservationLoading;

          return Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            onReserveTap();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3775FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'assets/icon/loading.json',
                                  width: 20.w,
                                  height: 20.h,
                                  repeat: true,
                                  animate: true,
                                ),
                              ],
                            ),
                          )
                        : Text(
                            "احجز دلوقتي",
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
