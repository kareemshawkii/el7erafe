import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/pending_offer_model.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/repositories/pending_offers_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/cubit/pending_offers_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/cubit/pending_offers_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class PendingOffersTab extends StatefulWidget {
  const PendingOffersTab({super.key});

  @override
  State<PendingOffersTab> createState() => _PendingOffersTabState();
}

class _PendingOffersTabState extends State<PendingOffersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => PendingOffersCubit(repository: PendingOffersRepo())
        ..fetchPendingOffers()
        ..initializeSignalR(),
      child: const PendingOffersView(),
    );
  }
}

class PendingOffersView extends StatelessWidget {
  const PendingOffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PendingOffersCubit, PendingOffersState>(
      listener: (context, state) async {
        if (state is PendingOffersUnauthorized) {
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
        if (state is PendingOffersLoading) {
          return Center(
            child: Lottie.asset(
              'assets/icon/loading.json',
              width: 200.w,
              height: 200.h,
              repeat: true,
              animate: true,
            ),
          );
        } else if (state is PendingOffersError) {
          return Center(
            child:
                Text(state.error, style: GoogleFonts.cairo(color: Colors.red)),
          );
        } else if (state is PendingOffersLoaded) {
          if (state.offers.isEmpty) {
            return Center(
              child: Text(
                'لا يوجد عروض قيد الانتظار حالياً',
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16.sp),
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: state.offers.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final offer = state.offers[index];
                return _buildPendingOfferCard(offer);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPendingOfferCard(PendingOfferModel offer) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            // ignore: deprecated_member_use
            color: const Color(0xFF3775FA).withOpacity(0.3),
            width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.handyman_outlined,
                color: const Color(0xFF3775FA),
                size: 24.r,
              ),
              SizedBox(width: 8.w),
              Text(
                offer.serviceType ?? 'خدمة',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (offer.description != null &&
                  offer.description!.isNotEmpty) ...[
                Text("  |  ",
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: Colors.grey.shade400,
                    )),
                Expanded(
                  child: Text(
                    offer.description!,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: offer.clientImage ??
                          'https://www.pngall.com/wp-content/uploads/5/Profile-PNG-High-Quality-Image.png',
                      width: 32.w,
                      height: 32.h,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey.shade200),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    offer.clientName ?? 'عميل',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.payments_outlined,
                      color: Colors.black87, size: 18.r),
                  SizedBox(width: 6.w),
                  Text(
                    '${offer.fees} جنيه مصري',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: Colors.black87, size: 18.r),
                  SizedBox(width: 6.w),
                  Text(
                    offer.day,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (offer.techTimeInterval != null &&
                  offer.techTimeInterval!.isNotEmpty)
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.access_time, color: Colors.black87, size: 18.r),
                    SizedBox(width: 6.w),
                    Text(
                      offer.techTimeInterval!,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E2E2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                "تم ارسال العرض",
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
