import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/pending_request_model.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/repositories/pending_requests_repo.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/pending_requests_cubit.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/pending_requests_state.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/presentation/quick_offers_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class PendingRequestsTab extends StatelessWidget {
  const PendingRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PendingRequestsCubit(repository: PendingRequestsRepo())
            ..fetchPendingRequests(),
      child: const PendingRequestsView(),
    );
  }
}

class PendingRequestsView extends StatelessWidget {
  const PendingRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PendingRequestsCubit, PendingRequestsState>(
      listener: (context, state) async {
        if (state is PendingRequestsUnauthorized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى',
                  textDirection: TextDirection.rtl),
              backgroundColor: Colors.red,
            ),
          );
          await AuthLocalStorage().deleteToken();
          if (!context.mounted) return;
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
        if (state is PendingRequestsLoading) {
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
        } else if (state is PendingRequestsError) {
          return Center(
              child: Text(state.error,
                  style: GoogleFonts.cairo(color: Colors.red)));
        } else if (state is PendingRequestsLoaded) {
          if (state.requests.isEmpty) {
            return Center(
                child: Text('لا توجد طلبات قيد الانتظار حالياً',
                    style: GoogleFonts.cairo(
                        color: Colors.grey, fontSize: 16.sp)));
          }
          final reversedRequests = state.requests.reversed.toList();
          return TweenAnimationBuilder<double>(
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
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: reversedRequests.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final request = reversedRequests[index];
                return request.isQuickReserve
                    ? _buildQuickReserveCard(context, request)
                    : _buildSpecificTechCard(context, request);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuickReserveCard(
      BuildContext context, PendingRequestModel request) {
    bool hasOffer = (request.numberOfOffers ?? 0) > 0;

    return _BaseRequestCard(
      header: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.flash_on,
                color: const Color(0xFF3775FA), size: 24.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'حجز فني ',
                style: GoogleFonts.cairo(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: [
                  TextSpan(
                      text: request.serviceType,
                      style: const TextStyle(color: Color(0xFF3775FA))),
                  const TextSpan(text: ' سريع'),
                ],
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
      details: [
        _DetailRow(
          rightLabel: 'عدد العروض :  ${request.numberOfOffers ?? 0}',
          rightIcon: Iconsax.category_2,
          leftLabel: '--',
          leftIcon: Icons.payments_outlined,
        ),
        SizedBox(height: 12.h),
        _DetailRow(
          rightLabel: request.day,
          rightIcon: Icons.calendar_today_outlined,
          leftLabel: request.clientTimeInterval ?? '--',
          leftIcon: Icons.access_time,
        ),
      ],
      primaryButtonText: hasOffer ? 'كل العروض' : null,
      primaryButtonIcon: hasOffer ? Icons.list : null,
      onPrimaryPressed: hasOffer
          ? () {
              Navigator.push(
                context,
                SlideRightRouteWithBuild(
                  builder: (context) =>
                      QuickOffersPage(requestId: request.requestId),
                ),
              );
            }
          : null,
      secondaryButtonText: 'إلغاء الطلب',
      secondaryButtonIcon: Iconsax.close_circle,
      onSecondaryPressed: () {
        _showCancelDialog(context, request.requestId);
      },
    );
  }

  Widget _buildSpecificTechCard(
      BuildContext context, PendingRequestModel request) {
    bool hasOffer = request.offerId != null && request.fees != null;

    return _BaseRequestCard(
      header: Row(
        textDirection: TextDirection.rtl,
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: request.techImage ??
                  'https://i.pinimg.com/736x/23/d1/3a/23d13a1dbad6a60319413ec2512aed29.jpg',
              width: 32.w,
              height: 32.h,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey.shade200),
              errorWidget: (_, __, ___) => Container(
                  color: Colors.grey.shade200, child: const Icon(Icons.person)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              request.techName ?? 'فني محدد',
              style: GoogleFonts.cairo(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textDirection: TextDirection.rtl,
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
      details: [
        _DetailRow(
          rightLabel: request.serviceType,
          rightIcon: Icons.handyman_outlined,
          leftLabel: hasOffer ? '${request.fees} جنيه مصري' : '--',
          leftIcon: Icons.payments_outlined,
        ),
        SizedBox(height: 12.h),
        _DetailRow(
          rightLabel: request.day,
          rightIcon: Icons.calendar_today_outlined,
          leftLabel: hasOffer ? request.techTimeInterval! : '--',
          leftIcon: Icons.access_time,
        ),
        if (request.numberOfDays != null && request.numberOfDays != 1) ...[
          SizedBox(height: 12.h),
          _DetailRow(
            rightLabel: 'مدة التنفيذ : ${request.numberOfDays} يوم',
            rightIcon: Icons.schedule_outlined,
          ),
        ],
      ],
      primaryButtonText: hasOffer ? 'قبول العرض' : null,
      primaryButtonIcon: hasOffer ? Iconsax.tick_circle : null,
      onPrimaryPressed: hasOffer
          ? () {
              context
                  .read<PendingRequestsCubit>()
                  .acceptOffer(request.offerId!);
              context.read<PendingRequestsCubit>().fetchPendingRequests();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم قبول العرض بنجاح',
                      textDirection: TextDirection.rtl),
                  backgroundColor: Colors.green,
                ),
              );
            }
          : null,
      secondaryButtonText: hasOffer ? 'رفض العرض' : 'إلغاء الطلب',
      secondaryButtonIcon: Iconsax.close_circle,
      onSecondaryPressed: () {
        if (hasOffer) {
          context
              .read<PendingRequestsCubit>()
              .declineOffer(request.offerId!, request.requestId);
          context.read<PendingRequestsCubit>().fetchPendingRequests();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('تم رفض العرض بنجاح', textDirection: TextDirection.rtl),
              backgroundColor: Colors.grey,
            ),
          );
        } else {
          _showCancelDialog(context, request.requestId);
        }
      },
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFFA800)),
      ),
      child: Center(
        child: Text(
          'قيد الانتظار',
          style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFA800)),
        ),
      ),
    );
  }
}

class _BaseRequestCard extends StatelessWidget {
  final Widget header;
  final List<Widget> details;
  final String? primaryButtonText;
  final IconData? primaryButtonIcon;
  final VoidCallback? onPrimaryPressed;
  final String secondaryButtonText;
  final IconData secondaryButtonIcon;
  final VoidCallback onSecondaryPressed;

  const _BaseRequestCard({
    required this.header,
    required this.details,
    this.primaryButtonText,
    this.primaryButtonIcon,
    this.onPrimaryPressed,
    required this.secondaryButtonText,
    required this.secondaryButtonIcon,
    required this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2DFDF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          header,
          SizedBox(height: 8.h),
          Divider(color: const Color(0xFFE2DFDF), thickness: 1.h),
          SizedBox(height: 8.h),
          ...details,
          SizedBox(height: 20.h),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              if (primaryButtonText != null &&
                  primaryButtonIcon != null &&
                  onPrimaryPressed != null) ...[
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: ElevatedButton(
                      onPressed: onPrimaryPressed,
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
                          Icon(primaryButtonIcon,
                              color: Colors.white, size: 15.sp),
                          SizedBox(width: 4.w),
                          Text(
                            primaryButtonText!,
                            style: GoogleFonts.cairo(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: OutlinedButton(
                    onPressed: onSecondaryPressed,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black, width: 1.w),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(secondaryButtonIcon,
                            color: Colors.black, size: 15.sp),
                        SizedBox(width: 4.w),
                        Text(
                          secondaryButtonText,
                          style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String rightLabel;
  final IconData rightIcon;
  final String? leftLabel;
  final IconData? leftIcon;

  const _DetailRow({
    required this.rightLabel,
    required this.rightIcon,
    this.leftLabel,
    this.leftIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(rightIcon, size: 16.r, color: Colors.black),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  rightLabel,
                  style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: leftLabel != null && leftLabel!.isNotEmpty && leftIcon != null
              ? Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(leftIcon, size: 16.r, color: Colors.black),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        leftLabel!,
                        style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

void _showCancelDialog(BuildContext context, int requestId) {
  final cubit = context.read<PendingRequestsCubit>();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'CancelDialog',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: const Color(0xFF3775FA), width: 1.5.w),
          ),
          shadowColor: Colors.black45,
          surfaceTintColor: const Color(0xFFE2DFDF),
          title: Text(
            "إلغاء الطلب",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "هل أنت متأكد من إلغاء هذا الطلب؟",
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "تراجع",
                style: GoogleFonts.cairo(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.cancelRequest(requestId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إلغاء الطلب بنجاح',
                        textDirection: TextDirection.rtl),
                    backgroundColor: Colors.grey,
                  ),
                );
              },
              child: Text(
                "تأكيد الإلغاء",
                style: GoogleFonts.cairo(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
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
  );
}
