import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/offers_model.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/repositories/pending_requests_repo.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/pending_requests_cubit.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/pending_requests_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class QuickOffersPage extends StatefulWidget {
  final int requestId;

  const QuickOffersPage({super.key, required this.requestId});

  @override
  State<QuickOffersPage> createState() => _QuickOffersPageState();
}

class _QuickOffersPageState extends State<QuickOffersPage>
    with WidgetsBindingObserver {
  late PendingRequestsCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = PendingRequestsCubit(repository: PendingRequestsRepo())
      ..fetchQuickOffers(widget.requestId);
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
      _cubit.reconnectAndRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _cubit.disconnectSignalR();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: OffersView(requestId: widget.requestId),
    );
  }
}

class OffersView extends StatelessWidget {
  final int requestId;

  const OffersView({super.key, required this.requestId});

  String _getValidImageUrl(String? url) {
    if (url == null ||
        url.trim().isEmpty ||
        url.trim().toLowerCase() == 'null') {
      return "";
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    const baseUrl =
        'https://el7rafeapp.azurewebsites.net';
    return url.startsWith('/') ? '$baseUrl$url' : '$baseUrl/$url';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          // ignore: deprecated_member_use
          shadowColor: const Color(0xFF3775FA).withOpacity(0.2),
          surfaceTintColor: const Color(0xFF3775FA),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 24.r),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "العروض المقدمة",
            style: GoogleFonts.cairo(
              color: Colors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocConsumer<PendingRequestsCubit, PendingRequestsState>(
          listener: (context, state) async {
            if (state is PendingRequestsUnauthorized) {
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
            } else if (state is OfferActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green),
              );
            } else if (state is OfferActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is OffersLoading || state is OfferActionLoading) {
              return Center(
                child: Lottie.asset(
                  'assets/icon/loading.json',
                  width: 200.w,
                  height: 200.h,
                  repeat: true,
                  animate: true,
                ),
              );
            } else if (state is PendingRequestsError) {
              return Center(
                child: Text(state.error,
                    style: GoogleFonts.cairo(color: Colors.red)),
              );
            } else if (state is OffersLoaded) {
              if (state.offers.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد عروض حالياً',
                    style:
                        GoogleFonts.cairo(color: Colors.grey, fontSize: 16.sp),
                  ),
                );
              }
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: state.offers.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final offer = state.offers[index];
                    return _buildOfferCard(context, offer);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, OfferModel offer) {
    return _BaseRequestCard(
      header: Row(
        textDirection: TextDirection.rtl,
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: _getValidImageUrl(offer.techImage),
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
              offer.techName,
              style: GoogleFonts.cairo(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textDirection: TextDirection.rtl,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFFFA800)),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: const Color(0xFFFFA800), size: 14.r),
                SizedBox(width: 4.w),
                Text(
                  (offer.rate).toString(),
                  style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFA800)),
                ),
              ],
            ),
          ),
        ],
      ),
      details: [
        _DetailRow(
          rightLabel: offer.serviceType,
          rightIcon: Icons.handyman_outlined,
          leftLabel: '${offer.fees} جنيه مصري',
          leftIcon: Icons.payments_outlined,
        ),
        SizedBox(height: 12.h),
        _DetailRow(
          rightLabel: offer.day,
          rightIcon: Icons.calendar_today_outlined,
          leftLabel: offer.techTimeInterval,
          leftIcon: Icons.access_time,
        ),
        if (offer.numberOfDays != null && offer.numberOfDays! > 1) ...[
          SizedBox(height: 12.h),
          _DetailRow(
            rightLabel: 'مدة التنفيذ : ${offer.numberOfDays} يوم',
            rightIcon: Icons.schedule_outlined,
          ),
        ],
      ],
      primaryButtonText: 'قبول العرض',
      primaryButtonIcon: Iconsax.tick_circle,
      onPrimaryPressed: () {
        Navigator.pop(context);
        context.read<PendingRequestsCubit>().acceptOffer(offer.offerId);
        context.read<PendingRequestsCubit>().fetchPendingRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم قبول العرض بنجاح'),
              backgroundColor: Colors.green),
        );
      },
      secondaryButtonText: 'رفض العرض',
      secondaryButtonIcon: Iconsax.close_circle,
      onSecondaryPressed: () {
        context
            .read<PendingRequestsCubit>()
            .declineOffer(offer.offerId, offer.requestId);
        context.read<PendingRequestsCubit>().fetchQuickOffers(offer.requestId);
      },
    );
  }
}

class _BaseRequestCard extends StatelessWidget {
  final Widget header;
  final List<Widget> details;
  final String primaryButtonText;
  final IconData primaryButtonIcon;
  final VoidCallback onPrimaryPressed;
  final String secondaryButtonText;
  final IconData secondaryButtonIcon;
  final VoidCallback onSecondaryPressed;

  const _BaseRequestCard({
    required this.header,
    required this.details,
    required this.primaryButtonText,
    required this.primaryButtonIcon,
    required this.onPrimaryPressed,
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
                          primaryButtonText,
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
