// ignore_for_file: deprecated_member_use

import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/models/current_reservation_model.dart';
import 'package:el7erafe/features/client_flow/reservation_history/data/repositories/current_reservations_repo.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/current_reservations_cubit.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/cubit/current_reservations_state.dart';
import 'package:el7erafe/features/client_flow/reservation_history/presentation/presentation/submit_rating_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class CurrentReservationsTab extends StatefulWidget {
  const CurrentReservationsTab({super.key});

  @override
  State<CurrentReservationsTab> createState() => _CurrentReservationsTabState();
}

class _CurrentReservationsTabState extends State<CurrentReservationsTab>
    with WidgetsBindingObserver {
  late CurrentReservationsCubit _cubit;
  bool _isLoadingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = CurrentReservationsCubit(repository: CurrentReservationsRepo())
      ..initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.disconnect();
    _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.fetchReservations();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _cubit.disconnect();
    }
  }

  void _closeDialog() {
    if (_isLoadingDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isLoadingDialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<CurrentReservationsCubit, CurrentReservationsState>(
        buildWhen: (previous, current) =>
            current is CurrentLoaded ||
            current is CurrentLoading ||
            current is CurrentError,
        listener: (context, state) {
          if (state is CurrentActionLoading) {
            _isLoadingDialogOpen = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: Lottie.asset('assets/icon/loading.json',
                    width: 200.w, height: 200.h),
              ),
            ).then((_) => _isLoadingDialogOpen = false);
          } else if (state is CurrentUnauth) {
            _closeDialog();
            ModernSnackbar.showError(
                context: context,
                message: "انتهت صلاحية الجلسة، يرجى تسجيل الدخول");
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                builder: (_) => BlocProvider(
                  create: (_) => LoginCubit(
                      authRepository:
                          RepositoryProvider.of<AuthRepository>(context)),
                  child: const LoginPage(),
                ),
              ),
              (route) => false,
            );
          } else if (state is CurrentActionSuccess) {
            _closeDialog();
            ModernSnackbar.showSuccess(
                context: context, message: state.message);
          } else if (state is CurrentActionError) {
            _closeDialog();
            ModernSnackbar.showError(context: context, message: state.message);
          } else if (state is CurrentActionLoading || state is PaymentLoading) {
            _isLoadingDialogOpen = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(
                child: Lottie.asset('assets/icon/loading.json',
                    width: 200.w, height: 200.h),
              ),
            ).then((_) => _isLoadingDialogOpen = false);
          } else if (state is PaymentSuccess) {
            _closeDialog();
            Navigator.push(
              context,
              SlideRightRouteWithBuild(
                builder: (_) => BlocProvider.value(
                  value: _cubit,
                  child: SubmitRatingPage(reservationId: state.reservationId),
                ),
              ),
            );
          } else if (state is PaymentError) {
            _closeDialog();
            ModernSnackbar.showError(context: context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is CurrentLoading) {
            return Center(
              child: Lottie.asset('assets/icon/loading.json',
                  width: 200.w, height: 200.h),
            );
          } else if (state is CurrentError) {
            return Center(
                child: Text(state.message,
                    style: GoogleFonts.cairo(color: Colors.red)));
          } else if (state is CurrentLoaded) {
            if (state.reservations.isEmpty) {
              return Center(
                  child: Text('لا توجد حجوزات حالية',
                      style: GoogleFonts.cairo(
                          color: Colors.grey, fontSize: 16.sp)));
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: state.reservations.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration:
                      Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child:
                      _buildCurrentReservationCard(state.reservations[index]),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCurrentReservationCard(CurrentReservationModel item) {
    Color badgeColor;
    Color badgeBorderColor;

    if (item.type == "تم التأكيد") {
      badgeColor = const Color(0xFFE5F8ED);
      badgeBorderColor = const Color.fromARGB(255, 40, 128, 61);
    } else if (item.type == "قيد التنفيذ") {
      badgeColor = const Color(0xFFFFF3CD);
      badgeBorderColor = const Color.fromARGB(255, 104, 79, 6);
    } else {
      badgeColor = const Color(0xFFE2EAFB);
      badgeBorderColor = const Color.fromARGB(255, 37, 71, 145);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: const Color(0xFF3775FA).withOpacity(0.3), width: 1.w),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundImage:
                        item.techImage != null && item.techImage!.isNotEmpty
                            ? NetworkImage(item.techImage!)
                            : null,
                    backgroundColor: Colors.grey.shade300,
                    child: item.techImage == null || item.techImage!.isEmpty
                        ? Icon(Icons.person, color: Colors.white, size: 24.sp)
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    item.techName ?? 'فني الصيانة',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: badgeBorderColor,
                    width: 1.w,
                  ),
                ),
                child: Text(
                  item.type,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildIconText(
                    Icons.kitchen_outlined, item.serviceType ?? 'غير محدد'),
              ),
              Expanded(
                child: _buildIconText(
                    Icons.payments_outlined, '${item.fees ?? 0} جنيه مصري'),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildIconText(Icons.access_time_rounded,
                    item.techTimeInterval ?? 'غير محدد'),
              ),
              Expanded(
                child: _buildIconText(
                    Icons.calendar_today_outlined, item.day ?? 'غير محدد'),
              ),
            ],
          ),
          if (item.type == "تم التأكيد") ...[
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Iconsax.send, size: 16.sp, color: Colors.white),
                    label: Text('تواصل مع الفني',
                        style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3775FA),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => showCancelConfirmationDialog(
                      context,
                      onConfirm: () {
                        _cubit.cancelReservation(item.reservationId);
                      },
                    ),
                    icon: Icon(Icons.close, size: 18.sp, color: Colors.black87),
                    label: Text('الغاء الطلب',
                        style: GoogleFonts.cairo(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(
                          color: const Color(0xFF3775FA).withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (item.type == "انتظار الدفع") ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _cubit.payForReservation(item.reservationId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3775FA),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('دفع الان',
                    style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: Colors.black),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

Future<void> showCancelConfirmationDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF3775FA)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child:
                        Icon(Icons.close, size: 20.sp, color: Colors.black87),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 1.5),
                    ),
                    child: Icon(
                      Icons.priority_high_rounded,
                      color: Colors.black87,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'هل أنت متأكد إنك عايز تلغي الطلب ده؟',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'لو لغيت هنبلغ الفني والطلب هيتم إلغاؤه',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3775FA),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.done,
                                  size: 18.sp, color: Colors.white),
                              SizedBox(width: 6.w),
                              Text(
                                'الغي الطلب',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ])),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(
                              color: const Color(0xFF3775FA), width: 1.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close,
                                  size: 18.sp, color: Colors.black87),
                              SizedBox(width: 6.w),
                              Text(
                                'رجوع',
                                style: GoogleFonts.cairo(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ])),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve =
          CurvedAnimation(parent: animation, curve: Curves.easeOutQuart);
      return Transform.scale(
        scale: 0.8 + (0.2 * curve.value),
        child: Opacity(
          opacity: animation.value,
          child: child,
        ),
      );
    },
  );
}
