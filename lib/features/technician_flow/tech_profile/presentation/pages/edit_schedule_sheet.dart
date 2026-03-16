// ignore_for_file: deprecated_member_use

import 'package:el7erafe/features/client_flow/quick_reserve/presentation/pages/time_picker.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/data/models/day_config.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/data/models/tech_schedule_model.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/cubit/tech_schedule_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/cubit/tech_schedule_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class EditScheduleBottomSheet extends StatefulWidget {
  final String token;
  final List<TechScheduleModel> initialSchedule;

  const EditScheduleBottomSheet({
    super.key,
    required this.token,
    required this.initialSchedule,
  });

  @override
  State<EditScheduleBottomSheet> createState() =>
      _EditScheduleBottomSheetState();
}

class _EditScheduleBottomSheetState extends State<EditScheduleBottomSheet> {
  bool _isAllWeek = true;
  TimeOfDay? _allWeekFrom;
  TimeOfDay? _allWeekTo;

  final List<DayScheduleConfig> _days = [
    DayScheduleConfig(name: "السبت", backendId: 1),
    DayScheduleConfig(name: "الاحد", backendId: 2),
    DayScheduleConfig(name: "الاثنين", backendId: 3),
    DayScheduleConfig(name: "الثلاثاء", backendId: 4),
    DayScheduleConfig(name: "الاربعاء", backendId: 5),
    DayScheduleConfig(name: "الخميس", backendId: 6),
    DayScheduleConfig(name: "الجمعه", backendId: 7),
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  TimeOfDay _parseApiTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: 0);
  }

  String _formatTimeForApi(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:00:00";
  }

  void _initData() {
    final fetched = widget.initialSchedule;
    if (fetched.isNotEmpty && fetched.first.dayOfWeek == null) {
      _isAllWeek = true;
      _allWeekFrom = _parseApiTime(fetched.first.fromTime);
      _allWeekTo = _parseApiTime(fetched.first.toTime);
    } else if (fetched.isNotEmpty) {
      _isAllWeek = false;
      for (var day in _days) {
        day.isSelected = false;
        day.fromTime = null;
        day.toTime = null;
      }
      for (var item in fetched) {
        final targetDay = _days.firstWhere(
            (element) => element.backendId == item.dayOfWeek,
            orElse: () => _days[0]);
        targetDay.isSelected = true;
        targetDay.fromTime = _parseApiTime(item.fromTime);
        targetDay.toTime = _parseApiTime(item.toTime);
      }
    }
  }

  void _onSave() {
    FocusScope.of(context).unfocus();
    List<TechScheduleModel> scheduleToSave = [];

    if (_isAllWeek) {
      if (_allWeekFrom == null || _allWeekTo == null) {
        _showError("يرجى تحديد وقت البداية والنهاية");
        return;
      }
      if (_allWeekFrom!.hour >= _allWeekTo!.hour) {
        _showError("وقت البداية يجب أن يكون قبل وقت النهاية");
        return;
      }
      scheduleToSave.add(TechScheduleModel(
        dayOfWeek: null,
        fromTime: _formatTimeForApi(_allWeekFrom!),
        toTime: _formatTimeForApi(_allWeekTo!),
      ));
    } else {
      bool hasSelectedDay = false;
      for (var day in _days) {
        if (day.isSelected) {
          hasSelectedDay = true;
          if (day.fromTime == null || day.toTime == null) {
            _showError("يرجى تحديد الأوقات لجميع الأيام المختارة");
            return;
          }
          if (day.fromTime!.hour >= day.toTime!.hour) {
            _showError(
                "وقت البداية يجب أن يكون قبل وقت النهاية في يوم ${day.name}");
            return;
          }
          scheduleToSave.add(TechScheduleModel(
            dayOfWeek: day.backendId,
            fromTime: _formatTimeForApi(day.fromTime!),
            toTime: _formatTimeForApi(day.toTime!),
          ));
        }
      }
      if (!hasSelectedDay) {
        _showError("يرجى اختيار يوم واحد على الأقل");
        return;
      }
    }

    context
        .read<TechScheduleCubit>()
        .updateSchedule(widget.token, scheduleToSave);
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
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
      ),
    );
  }

  Widget _buildTimePickerField(BuildContext context, String label,
      TimeOfDay? currentValue, Function(TimeOfDay) onSave) {
    String displayTime = currentValue != null
        ? '${currentValue.hourOfPeriod == 0 ? 12 : currentValue.hourOfPeriod.toString().padLeft(2, '0')} ${currentValue.period == DayPeriod.am ? 'صباحا' : 'مساء'}'
        : '--';
    return InkWell(
      onTap: () async {
        FocusScope.of(context).unfocus();
        TimeOfDay? t = await showTimePickerModified(
          context: context,
          initialTime:
              currentValue ?? TimeOfDay(hour: TimeOfDay.now().hour, minute: 0),
          helpText: "اختار الوقت",
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
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: false),
                  child: child!,
                ),
              ),
            );
          },
        );
        if (t != null) {
          onSave(TimeOfDay(hour: t.hour, minute: 0));
        }
      },
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$label : $displayTime",
                style: GoogleFonts.cairo(
                    color: currentValue == null ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp)),
            Icon(Icons.access_time, size: 16.r, color: const Color(0xFF3775FA)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TechScheduleCubit, TechScheduleState>(
      listener: (context, state) {
        if (state is TechScheduleUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, textDirection: TextDirection.rtl),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is TechScheduleError) {
          _showError(state.error);
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    left: 12.w, right: 12.w, top: 12.h, bottom: 24.h),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "أوقات توفّرك",
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: () => setState(() => _isAllWeek = true),
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                                color: _isAllWeek
                                    ? const Color(0xFF3775FA)
                                    : Colors.grey.shade200,
                                width: 1.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Radio<bool>(
                                    value: true,
                                    groupValue: _isAllWeek,
                                    activeColor: const Color(0xFF3775FA),
                                    onChanged: (val) =>
                                        setState(() => _isAllWeek = val!),
                                  ),
                                  Text(
                                    "متاح كل ايام الاسبوع",
                                    style: GoogleFonts.cairo(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: _isAllWeek
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            top: 12.h, right: 12.w, left: 12.w),
                                        padding: EdgeInsets.all(12.r),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "ضبط نفس الميعاد لكل أيام الأسبوع",
                                              style: GoogleFonts.cairo(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87),
                                            ),
                                            SizedBox(height: 16.h),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _buildTimePickerField(
                                                    context,
                                                    "من",
                                                    _allWeekFrom,
                                                    (t) => setState(
                                                        () => _allWeekFrom = t),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: _buildTimePickerField(
                                                    context,
                                                    "الي",
                                                    _allWeekTo,
                                                    (t) => setState(
                                                        () => _allWeekTo = t),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: () => setState(() => _isAllWeek = false),
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                                color: !_isAllWeek
                                    ? const Color(0xFF3775FA)
                                    : Colors.grey.shade200,
                                width: 1.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Radio<bool>(
                                    value: false,
                                    groupValue: _isAllWeek,
                                    activeColor: const Color(0xFF3775FA),
                                    onChanged: (val) =>
                                        setState(() => _isAllWeek = val!),
                                  ),
                                  Text(
                                    "اختار كل يوم وحدد مواعيده",
                                    style: GoogleFonts.cairo(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: !_isAllWeek
                                    ? Container(
                                        margin: EdgeInsets.only(
                                            top: 12.h, right: 12.w, left: 12.w),
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _days.length,
                                          separatorBuilder: (_, __) =>
                                              SizedBox(height: 12.h),
                                          itemBuilder: (context, index) {
                                            final day = _days[index];
                                            return Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                color: Colors.white,
                                              ),
                                              child: Theme(
                                                data: Theme.of(context)
                                                    .copyWith(
                                                        dividerColor:
                                                            Colors.transparent),
                                                child: ExpansionTile(
                                                  controller:
                                                      day.tileController,
                                                  initiallyExpanded:
                                                      day.isSelected,
                                                  onExpansionChanged:
                                                      (expanded) {
                                                    setState(() => day
                                                        .isSelected = expanded);
                                                  },
                                                  iconColor:
                                                      const Color(0xFF3775FA),
                                                  collapsedIconColor:
                                                      Colors.grey,
                                                  title: Row(
                                                    children: [
                                                      Checkbox(
                                                        value: day.isSelected,
                                                        activeColor:
                                                            const Color(
                                                                0xFF3775FA),
                                                        onChanged: (val) {
                                                          setState(() {
                                                            day.isSelected =
                                                                val!;
                                                          });
                                                          if (val!) {
                                                            day.tileController
                                                                .expand();
                                                          } else {
                                                            day.tileController
                                                                .collapse();
                                                          }
                                                        },
                                                      ),
                                                      Text(
                                                        day.name,
                                                        style:
                                                            GoogleFonts.cairo(
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                      ),
                                                    ],
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 16.h,
                                                          left: 16.w,
                                                          right: 16.w),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                _buildTimePickerField(
                                                              context,
                                                              "من",
                                                              day.fromTime,
                                                              (t) => setState(() =>
                                                                  day.fromTime =
                                                                      t),
                                                            ),
                                                          ),
                                                          SizedBox(width: 12.w),
                                                          Expanded(
                                                            child:
                                                                _buildTimePickerField(
                                                              context,
                                                              "الي",
                                                              day.toTime,
                                                              (t) => setState(
                                                                  () =>
                                                                      day.toTime =
                                                                          t),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BlocBuilder<TechScheduleCubit, TechScheduleState>(
                builder: (context, state) {
                  return state is TechScheduleUpdateLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: const Color(0xFF3775FA), strokeWidth: 3.w),
                        )
                      : SizedBox(
                          height: 45.h,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onSave,
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
                                Icon(Iconsax.save_2,
                                    color: Colors.white, size: 20.r),
                                SizedBox(width: 8.w),
                                Text(
                                  'حفظ المواعيد',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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
      ),
    );
  }
}
