import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/chat_system/data/repositories/chat_repository.dart';
import 'package:el7erafe/features/chat_system/presentation/pages/chat_room_page.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/pages/tech_home_page.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/technician_calender_model.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/repositories/tech_calender_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/cubit/tech_calender_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_reservation_history/presentation/cubit/tech_calender_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class TechCurrentReservationsTab extends StatefulWidget {
  const TechCurrentReservationsTab({super.key});

  @override
  State<TechCurrentReservationsTab> createState() =>
      _TechCurrentReservationsTabState();
}

class _TechCurrentReservationsTabState extends State<TechCurrentReservationsTab>
    with AutomaticKeepAliveClientMixin {
  late TechCalendarCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  final List<DateTime> _calendarDays = [];
  late DateTime _today;
  late DateTime _selectedDate = _today;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cubit = TechCalendarCubit(repository: TechCalendarRepo());
    _generateCalendarDays();
    _cubit.fetchReservationsForDate(_today);
  }

  void _generateCalendarDays() {
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 30; i++) {
      _calendarDays.add(_today.add(Duration(days: i)));
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  String _getValidImageUrl(String? url) {
    if (url == null ||
        url.trim().isEmpty ||
        url.trim().toLowerCase() == 'null') {
      return "";
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    const baseUrl = 'https://el7rafeapp.azurewebsites.net';
    return url.startsWith('/') ? '$baseUrl$url' : '$baseUrl/$url';
  }

  String _getArabicDayName(int weekday) {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الاربعاء',
      'الخميس',
      'الجمعه',
      'السبت',
      'الاحد'
    ];
    return days[weekday - 1];
  }

  String _getArabicMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildCalendarHeader(),
            Expanded(
              child: BlocConsumer<TechCalendarCubit, TechCalendarState>(
                listener: (context, state) async {
                  if (state is TechCalendarUnauthorized) {
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
                  } else if (state is ActionSuccess) {
                    ModernSnackbar.showSuccess(
                        context: context, message: state.message);
                    Navigator.pushAndRemoveUntil(
                      context,
                      SlideRightRouteWithBuild(
                        builder: (context) => const TechHomePage(),
                      ),
                      (route) => false,
                    );
                  } else if (state is ActionError) {
                    ModernSnackbar.showError(
                        context: context, message: state.error);
                  }
                },
                builder: (context, state) {
                  if (state is TechCalendarLoading || state is ActionLoading) {
                    return Center(
                      child: Lottie.asset(
                        'assets/icon/loading.json',
                        width: 200.w,
                        height: 200.h,
                        repeat: true,
                        animate: true,
                      ),
                    );
                  } else if (state is TechCalendarError) {
                    return Center(
                      child: Text(state.error,
                          style: GoogleFonts.cairo(color: Colors.red)),
                    );
                  } else if (state is TechCalendarLoaded) {
                    if (state.reservations.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد حجوزات في هذا اليوم',
                          style: GoogleFonts.cairo(
                              color: Colors.grey, fontSize: 16.sp),
                        ),
                      );
                    }
                    return TweenAnimationBuilder<double>(
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
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        itemCount: state.reservations.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          return _buildReservationCard(
                              context, state.reservations[index]);
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return BlocBuilder<TechCalendarCubit, TechCalendarState>(
      builder: (context, state) {
        if (state is TechCalendarLoaded) {
          _selectedDate = state.selectedDate;
        }
        double screenWidth = MediaQuery.of(context).size.width;
        double itemWidth = (screenWidth - 32.w - (4 * 10.w)) / 5;

        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 65.h,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const PageScrollPhysics(),
                  itemCount: _calendarDays.length,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemBuilder: (context, index) {
                    final dayDate = _calendarDays[index];
                    final isSelected = dayDate.isAtSameMomentAs(_selectedDate);
                    bool isFirstDayOfMonth = dayDate.day == 1 || index == 0;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = dayDate;
                        });
                        context
                            .read<TechCalendarCubit>()
                            .fetchReservationsForDate(dayDate);
                      },
                      child: Container(
                        width: itemWidth,
                        margin: EdgeInsets.only(
                            left: index != _calendarDays.length - 1 ? 10.w : 0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3775FA)
                              : const Color(0xFFF4F6FF),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF3775FA)
                                  : Colors.transparent),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getArabicDayName(dayDate.weekday),
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('dd').format(dayDate),
                                  style: GoogleFonts.cairo(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                if (isFirstDayOfMonth) ...[
                                  SizedBox(width: 2.w),
                                  Text(
                                    _getArabicMonthName(dayDate.month),
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white70
                                          : const Color(0xFF3775FA),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReservationCard(
      BuildContext context, TechReservationModel reservation) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF3775FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: _getValidImageUrl(reservation.clientImage),
                      width: 36.w,
                      height: 36.h,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.person, color: Colors.grey)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    reservation.clientName ?? 'عميل',
                    style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    int chatId = await getChatId(reservation.reservationId);
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      SlideRightRouteWithBuild(
                        builder: (context) => ChatRoomPage(
                          chatId: chatId,
                          receiverName: reservation.clientName ?? 'فني الصيانة',
                          receiverImage: reservation.clientImage ?? '',
                        ),
                      ),
                    );
                  } catch (e) {
                    ModernSnackbar.showError(
                        // ignore: use_build_context_synchronously
                        context: context,
                        message: 'فشل إنشاء المحادثة. حاول مرة أخرى.');
                  }
                },
                icon: Icon(Iconsax.send_2, color: Colors.black87, size: 16.r),
                label: Text(
                  "تواصل مع المستخدم",
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      // ignore: deprecated_member_use
                      color: const Color(0xFF3775FA).withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  minimumSize: Size(0, 32.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.handyman_outlined,
                  color: const Color(0xFF3775FA), size: 20.r),
              SizedBox(width: 8.w),
              Text(
                reservation.serviceType ?? 'خدمة صيانة',
                style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              if (reservation.description != null &&
                  reservation.description!.isNotEmpty) ...[
                Text("  |  ",
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: Colors.grey.shade400,
                    )),
                Expanded(
                  child: Text(
                    reservation.description!,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: Colors.black87, size: 16.r),
                  SizedBox(width: 6.w),
                  Text(
                    reservation.day ?? '',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (reservation.techTimeInterval != null)
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.black87, size: 16.r),
                    SizedBox(width: 6.w),
                    Text(
                      reservation.techTimeInterval!,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
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
                  height: 44.h,
                  child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<TechCalendarCubit>()
                            .startJob(reservation.reservationId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3775FA),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 18.r),
                          SizedBox(width: 4.w),
                          Text(
                            'بدأ الطلب',
                            style: GoogleFonts.cairo(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      )),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 44.h,
                  child: OutlinedButton(
                    onPressed: () {
                      showCancelConfirmationDialog(
                        context,
                        onConfirm: () {
                          context
                              .read<TechCalendarCubit>()
                              .cancelReservation(reservation.reservationId);
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400, width: 1.w),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, color: Colors.black87, size: 18.r),
                        SizedBox(width: 4.w),
                        Text(
                          'الغاء',
                          style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
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
                  // ignore: deprecated_member_use
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
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
                'لو لغيت هنبلغ العميل والطلب هيتم إلغاؤه',
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

Future<int> getChatId(int reservationId) async {
  final int chatId = (await ChatRepository().initChat(reservationId));
  return chatId;
}
