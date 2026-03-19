// ignore_for_file: deprecated_member_use
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/cubit/client_home_state.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/pages/time_picker.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_home/presentation/cubit/available_requests_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class MakeOfferDialog extends StatefulWidget {
  final int requestId;
  final String? clientTimeInterval;
  final String? requestDate;

  const MakeOfferDialog({
    super.key,
    required this.requestId,
    this.clientTimeInterval,
    this.requestDate,
  });

  @override
  State<MakeOfferDialog> createState() => _MakeOfferDialogState();
}

class _MakeOfferDialogState extends State<MakeOfferDialog> {
  final TextEditingController _feesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

  TimeOfDay? _clientStartTime;
  TimeOfDay? _clientEndTime;

  bool _needsMultipleDays = false;
  int _selectedDays = 2;

  bool get _isAllDayAvailable =>
      _clientStartTime == null || _clientEndTime == null;

  @override
  void initState() {
    super.initState();
    _parseClientTimeInterval();
  }

  @override
  void dispose() {
    _feesController.dispose();
    super.dispose();
  }

  String _convertArabicToEnglishNumbers(String input) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    String res = input;
    for (int i = 0; i < arabicNumbers.length; i++) {
      res = res.replaceAll(arabicNumbers[i], englishNumbers[i]);
    }
    return res;
  }

  void _parseClientTimeInterval() {
    if (widget.clientTimeInterval == null ||
        widget.clientTimeInterval!.trim().isEmpty ||
        widget.clientTimeInterval!.toLowerCase() == "null") {
      _clientStartTime = null;
      _clientEndTime = null;
      return;
    }

    try {
      String cleanStr =
          _convertArabicToEnglishNumbers(widget.clientTimeInterval!);
      List<String> parts = cleanStr.split('-');
      if (parts.length == 2) {
        _clientStartTime = _parseSingleTime(parts[0]);
        _clientEndTime = _parseSingleTime(parts[1]);
      }
    } catch (_) {
      _clientStartTime = null;
      _clientEndTime = null;
    }
  }

  TimeOfDay? _parseSingleTime(String timeStr) {
    timeStr = timeStr.trim();
    bool isPm = timeStr.contains('م');
    timeStr = timeStr.replaceAll('ص', '').replaceAll('م', '').trim();
    List<String> timeParts = timeStr.split(':');
    if (timeParts.isEmpty) return null;
    int hour = int.tryParse(timeParts[0]) ?? 0;
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: 0);
  }

  String _formatTimeForApi(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:00:00";
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.r),
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
          message,
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
    );
  }

  bool _isDateToday(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final now = DateTime.now();
      String rawDateStr = dateStr;

      List<String> parts = dateStr.split(' ');
      if (parts.length > 1) {
        rawDateStr = parts[1];
      }

      List<String> dateParts = rawDateStr.split('-');
      if (dateParts.length == 3) {
        int day = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int year = int.parse(dateParts[2]);

        return now.year == year && now.month == month && now.day == day;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void _submitOffer() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_fromTime == null || _toTime == null) {
      _showErrorDialog("يرجى تحديد وقت بداية ونهاية العمل.");
      return;
    }

    if (_fromTime!.hour >= _toTime!.hour) {
      _showErrorDialog("وقت النهاية يجب أن يكون بعد وقت البداية.");
      return;
    }

    final now = DateTime.now();
    final isToday = _isDateToday(widget.requestDate);

    if (isToday && _toTime!.hour < now.hour) {
      _showErrorDialog(
          "وقت النهاية يجب أن يكون بعد الوقت الحالي لأن الطلب لليوم.");
      return;
    }

    if (isToday && _fromTime!.hour <= now.hour) {
      _showErrorDialog(
          "يجب اختيار وقت البدايه بعد ساعه علي الاقل من الوقت الحالي");
      return;
    }

    context.read<AvailableRequestsCubit>().submitOffer(
          requestId: widget.requestId,
          fees: int.parse(_feesController.text.trim()),
          fromTime: _formatTimeForApi(_fromTime!),
          toTime: _formatTimeForApi(_toTime!),
          numberOfDays: _needsMultipleDays ? _selectedDays : null,
        );
  }

  Widget _buildTimePickerField(
      String label, TimeOfDay? currentValue, Function(TimeOfDay) onSave) {
    String displayTime = currentValue != null
        ? '${currentValue.hourOfPeriod == 0 ? 12 : currentValue.hourOfPeriod.toString().padLeft(2, '0')}  ${currentValue.period == DayPeriod.am ? 'صباحاً' : 'مساءً'}'
        : '-- ';

    return InkWell(
      onTap: () async {
        FocusScope.of(context).unfocus();
        TimeOfDay? t = await showTimePickerModified(
          context: context,
          initialTime:
              currentValue ?? TimeOfDay(hour: TimeOfDay.now().hour, minute: 0),
          helpText: "اختار الوقت بالساعات",
          cancelText: "إلغاء",
          confirmText: "تأكيد",
          barrierColor: Colors.black45,
          barrierLabel: "اختار الوقت",
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF3775FA),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                timePickerTheme: TimePickerThemeData(
                  dialHandColor: const Color(0xFF3775FA),
                  dialBackgroundColor: Colors.white,
                  hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? const Color(0xFF3775FA)
                          : Colors.black),
                  hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? const Color(0xFF3775FA).withOpacity(0.1)
                          : Colors.grey.shade100),
                  dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? Colors.white
                          : const Color(0xFF3775FA)),
                  dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? const Color(0xFF3775FA)
                          : Colors.transparent),
                  dayPeriodBorderSide:
                      const BorderSide(color: Color(0xFF3775FA)),
                ),
              ),
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: false),
                child: child!,
              ),
            );
          },
        );

        if (t != null) {
          TimeOfDay selected = TimeOfDay(hour: t.hour, minute: 0);

          if (!_isAllDayAvailable) {
            if (selected.hour < _clientStartTime!.hour ||
                selected.hour > _clientEndTime!.hour) {
              _showErrorDialog("الوقت المختار خارج نطاق وقت العميل المسموح.");
              return;
            }
          }
          onSave(selected);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$label : $displayTime",
              style: GoogleFonts.cairo(
                color: currentValue == null ? Colors.grey : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AvailableRequestsCubit, AvailableRequestsState>(
      listener: (context, state) async {
        if (state is MakeOfferSuccess) {
          Navigator.pop(context, true);
        } else if (state is MakeOfferError) {
          _showErrorDialog(state.error);
        } else if (state is HomeUnauthorized) {
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
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3775FA).withOpacity(0.2),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFF3775FA), width: 1.r),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.edit,
                              color: const Color(0xFF3775FA), size: 17.r),
                          SizedBox(width: 8.w),
                          Text(
                            "حدد السعر والمعاد لتقديم العرض",
                            style: GoogleFonts.cairo(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF3775FA)),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.close,
                              color: Colors.black, size: 20.r),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "حدد السعر",
                    style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _feesController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "أدخل السعر المقترح",
                      hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
                      suffixText: "جنيه مصري",
                      suffixStyle:
                          GoogleFonts.cairo(color: Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFF3775FA)),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "السعر مطلوب";
                      }
                      if (double.tryParse(val) == null ||
                          double.parse(val) <= 0) {
                        return "أدخل سعر صحيح";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "حدد المعاد المتاح",
                              style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            if (_clientStartTime != null) ...[
                              SizedBox(height: 4.h),
                              Text("  (مسموح بين ${widget.clientTimeInterval})",
                                  style: GoogleFonts.cairo(
                                      fontSize: 13.sp, color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ] else ...[
                              SizedBox(height: 4.h),
                              Text("  (العميل متاح طوال اليوم)",
                                  style: GoogleFonts.cairo(
                                      fontSize: 13.sp, color: Colors.black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child:
                                  _buildTimePickerField("من", _fromTime, (t) {
                                setState(() => _fromTime = t);
                              }),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildTimePickerField("الي", _toTime, (t) {
                                setState(() => _toTime = t);
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "شغل أكثر من يوم؟",
                              style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            CupertinoSwitch(
                              value: _needsMultipleDays,
                              activeTrackColor: const Color(0xFF3775FA),
                              onChanged: (val) {
                                setState(() {
                                  _needsMultipleDays = val;
                                  if (!val) {
                                    _selectedDays = 2;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _needsMultipleDays
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 16.h),
                                    Text(
                                      "اختر عدد الأيام الإجمالية",
                                      style: GoogleFonts.cairo(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700),
                                    ),
                                    SizedBox(height: 12.h),
                                    SizedBox(
                                      height: 40.h,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 29,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(width: 8.w),
                                        itemBuilder: (context, index) {
                                          int dayValue = index + 2;
                                          bool isSelected =
                                              _selectedDays == dayValue;

                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedDays = dayValue;
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFF3775FA)
                                                    : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFF3775FA)
                                                      : Colors.grey.shade300,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '$dayValue أيام',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  BlocBuilder<AvailableRequestsCubit, AvailableRequestsState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: ElevatedButton(
                            onPressed:
                                state is MakeOfferLoading ? null : _submitOffer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3775FA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: state is MakeOfferLoading
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Iconsax.send,
                                          size: 16.r, color: Colors.white),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "تقديم العرض",
                                        style: GoogleFonts.cairo(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
