// ignore_for_file: deprecated_member_use

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:el7erafe/core/utils/animated_navigation.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/widgets/location_picker.dart';
import 'package:el7erafe/features/client_flow/client_home/data/models/quick_reservation_request.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/cubit/quick_reserve_cubit.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/cubit/quick_reserve_state.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/pages/quick_reserve_success_page.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/pages/time_picker.dart';
import 'package:el7erafe/features/client_flow/select_technician/presentation/pages/selecet_technician_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class QuickReservePage extends StatelessWidget {
  final int serviceId;
  final String serviceName;

  const QuickReservePage(
      {super.key, required this.serviceId, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return ServiceRequestPage(serviceId: serviceId, serviceName: serviceName);
  }
}

class ServiceRequestPage extends StatefulWidget {
  final int serviceId;
  final String serviceName;

  const ServiceRequestPage(
      {super.key, required this.serviceId, required this.serviceName});

  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  String? selectedStartTime;
  String? selectedEndTime;
  late ReservationRequest requestModel;

  @override
  void initState() {
    super.initState();
    requestModel = ReservationRequest(
      serviceId: widget.serviceId,
      serviceName: widget.serviceName,
      day: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return BlocProvider(
      create: (context) => ServiceRequestCubit(requestModel),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.r),
              onPressed: () => Navigator.pop(context),
            ),
            toolbarHeight: 50.h,
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.blueAccent,
            surfaceTintColor: Colors.blueAccent,
            centerTitle: true,
            title: Text.rich(
              TextSpan(
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.5,
                ),
                children: <TextSpan>[
                  const TextSpan(
                    text: "ادخل البيانات لطلب فني ",
                  ),
                  TextSpan(
                    text: widget.serviceName,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
            listener: (context, state) {
              if (state is ServiceRequestError) {
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
                              MaterialPageRoute(
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
              } else if (state is ServiceRequestUnauthorized) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.unauthMessage,
                        textDirection: TextDirection.rtl),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) =>
                          LoginCubit(authRepository: AuthRepository()),
                      child: const LoginPage(),
                    ),
                  ),
                  (route) => false,
                );
              } else if (state is ServiceRequestSuccess) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SuccessPage()),
                  (route) => false,
                );
              }
            },
            builder: (context, state) {
              var cubit = context.read<ServiceRequestCubit>();
              var model = cubit.requestModel;

              if (state is ServiceRequestLoading) {
                return Container(
                  color: Colors.white,
                  child: Center(
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
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                );
              }
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildSectionCard(
                        title: "تفاصيل الطلب",
                        icon: Iconsax.document_text,
                        children: [
                          _buildLabel("وصف المشكلة"),
                          TextField(
                            maxLines: 4,
                            onChanged: (val) => model.description = val,
                            decoration: _inputDecoration(
                                "اكتب تفاصيل المشكلة اللي محتاج الفني يجي يصلحها"),
                          ),
                          SizedBox(height: 16.h),
                          _buildLabel("صور للمشكله ان وجد"),
                          Container(
                            height: 120.h,
                            width: double.infinity,
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFE),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFF3775FA),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (model.images?.length ?? 0) +
                                  ((model.images?.length ?? 0) < 4 ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == (model.images?.length ?? 0)) {
                                  return GestureDetector(
                                    onTap: () =>
                                        _showImageSourceSheet(context, cubit),
                                    child: Container(
                                      width: 100.w,
                                      margin: EdgeInsets.only(right: 8.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                            color: const Color(0xFF3775FA),
                                            width: 1.w),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Iconsax.gallery_add,
                                              color: const Color(0xFF3775FA),
                                              size: 28.r),
                                          SizedBox(height: 4.h),
                                          Text("أضف صورة",
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color:
                                                      const Color(0xFF3775FA),
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: Image.file(
                                          model.images![index],
                                          height: 104.h,
                                          width: 100.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4.h,
                                        right: 4.w,
                                        child: InkWell(
                                          onTap: () => cubit.removeImage(index),
                                          child: Container(
                                            padding: EdgeInsets.all(4.r),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 2)
                                              ],
                                            ),
                                            child: Icon(Icons.close,
                                                color: Colors.red, size: 16.r),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildSectionCard(
                        title: "تفاصيل العنوان",
                        icon: Iconsax.location,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("المحافظة",
                                  style: GoogleFonts.cairo(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                              SizedBox(width: 120.w),
                              Text("المدينة",
                                  style: GoogleFonts.cairo(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          EgyptGovernoratePicker(
                            language: Language.arabic,
                            layout: Layout.horizontal,
                            showCities: true,
                            governorateDropdownLabel: "المحافظة",
                            cityDropdownLabel: "المدينة",
                            assetDataPath: "assets/data/egypt_data.json",
                            onGovernorateChanged: (String? newGov) {
                              cubit.setGovernorate(newGov);
                            },
                            onCityChanged: (String? newCity) {
                              cubit.setCity(newCity);
                            },
                          ),
                          SizedBox(height: 12.h),
                          _buildLabel("الشارع"),
                          TextField(
                            onChanged: (val) => model.street = val,
                            decoration: _inputDecoration(
                                "اكتب اسم الشارع ورقم البيت أو العمارة"),
                          ),
                          SizedBox(height: 12.h),
                          _buildLabel("علامة مميزة"),
                          TextField(
                            onChanged: (val) => model.specialSign = val,
                            decoration: _inputDecoration(
                                "مثلا: جنب مسجد النور - أو أمام السوبر ماركت الكبير"),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildSectionCard(
                        title: "تحديد الوقت",
                        icon: Iconsax.clock,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "اختار اليوم :",
                                style: GoogleFonts.cairo(
                                    fontSize: 16.sp,
                                    color: const Color(0xFF3775FA),
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                              height: 300.h,
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: CalendarDatePicker2(
                                  config: CalendarDatePicker2Config(
                                    monthTextStyle: GoogleFonts.cairo(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600),
                                    firstDayOfWeek: 6,
                                    weekdayLabelTextStyle:
                                        GoogleFonts.cairo(fontSize: 14.sp),
                                    lastMonthIcon: Icon(Icons.arrow_back_ios,
                                        size: 15.r, color: Colors.black54),
                                    nextMonthIcon: Icon(Icons.arrow_forward_ios,
                                        size: 15.r, color: Colors.black54),
                                    controlsTextStyle: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    yearTextStyle: GoogleFonts.cairo(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600),
                                    firstDate: today,
                                    calendarType:
                                        CalendarDatePicker2Type.single,
                                    selectedDayHighlightColor:
                                        const Color(0xFF3775FA),
                                    selectedDayTextStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                    dayTextStyle: GoogleFonts.cairo(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  value: [model.day],
                                  onValueChanged: (dates) {
                                    model.day =
                                        dates.isNotEmpty ? dates.first : null;
                                  },
                                ),
                              )),
                          Text("اختار الوقت :",
                              style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF3775FA),
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              children: [
                                _buildToggleOption(
                                    text: "طول اليوم",
                                    isSelected: model.allDayAvailability,
                                    onTap: () => cubit.toggleAllDay(true)),
                                _buildToggleOption(
                                    text: "من إلى (وقت محدد)",
                                    isSelected: !model.allDayAvailability,
                                    onTap: () => cubit.toggleAllDay(false)),
                              ],
                            ),
                          ),
                          if (!model.allDayAvailability)
                            Padding(
                              padding: EdgeInsets.only(top: 16.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildTimePickerField(
                                      context,
                                      "من",
                                      selectedStartTime,
                                      (TimeOfDay t) {
                                        final now = DateTime.now();
                                        bool isToday = false;
                                        if (model.day != null) {
                                          isToday = (model.day!.year ==
                                                  now.year &&
                                              model.day!.month == now.month &&
                                              model.day!.day == now.day);
                                        }
                                        if (isToday && t.hour < now.hour) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "لا يمكن اختيار وقت بداية في الماضي",
                                                  textDirection:
                                                      TextDirection.rtl),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        if (isToday && t.hour == now.hour) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "يجب اخيار ساعه تكون بعد الساعه الحالية",
                                                  textDirection:
                                                      TextDirection.rtl),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        if (model.availableTo != null &&
                                            model.availableTo!.isNotEmpty) {
                                          int endHour = int.parse(
                                              model.availableTo!.split(":")[0]);

                                          if (t.hour >= endHour) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "وقت البداية يجب أن يكون قبل وقت النهاية",
                                                    textDirection:
                                                        TextDirection.rtl),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                        }

                                        setState(() {
                                          final localizations =
                                              MaterialLocalizations.of(context);

                                          TimeOfDay timeWithZeroMinutes =
                                              TimeOfDay(
                                                  hour: t.hour, minute: 0);

                                          String formattedTime =
                                              localizations.formatTimeOfDay(
                                            timeWithZeroMinutes,
                                            alwaysUse24HourFormat: false,
                                          );

                                          selectedStartTime = formattedTime
                                              .replaceAll('AM', 'صباحاً')
                                              .replaceAll('am', 'صباحاً')
                                              .replaceAll('PM', 'مساءً')
                                              .replaceAll('pm', 'مساءً');

                                          String hour24 = timeWithZeroMinutes
                                              .hour
                                              .toString()
                                              .padLeft(2, '0');

                                          model.availableFrom = "$hour24:00";
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: _buildTimePickerField(
                                      context,
                                      "إلى",
                                      selectedEndTime,
                                      (TimeOfDay t) {
                                        final now = DateTime.now();

                                        bool isToday = false;
                                        if (model.day != null) {
                                          isToday = (model.day!.year ==
                                                  now.year &&
                                              model.day!.month == now.month &&
                                              model.day!.day == now.day);
                                        }

                                        if (model.availableFrom != null &&
                                            model.availableFrom!.isNotEmpty) {
                                          int startHour = int.parse(model
                                              .availableFrom!
                                              .split(":")[0]);

                                          if (t.hour <= startHour) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "وقت النهاية يجب أن يكون بعد وقت البداية",
                                                    textDirection:
                                                        TextDirection.rtl),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                        }

                                        if (isToday && t.hour < now.hour) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "لا يمكن اختيار وقت نهاية في الماضي",
                                                  textDirection:
                                                      TextDirection.rtl),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        if (isToday && t.hour == now.hour) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "يجب اخيار ساعه تكون بعد الساعه الحالية",
                                                  textDirection:
                                                      TextDirection.rtl),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() {
                                          final localizations =
                                              MaterialLocalizations.of(context);
                                          TimeOfDay timeWithZeroMinutes =
                                              TimeOfDay(
                                                  hour: t.hour, minute: 0);

                                          String formattedTime =
                                              localizations.formatTimeOfDay(
                                            timeWithZeroMinutes,
                                            alwaysUse24HourFormat: false,
                                          );

                                          selectedEndTime = formattedTime
                                              .replaceAll('AM', 'صباحاً')
                                              .replaceAll('am', 'صباحاً')
                                              .replaceAll('PM', 'مساءً')
                                              .replaceAll('pm', 'مساءً');

                                          String hour24 = timeWithZeroMinutes
                                              .hour
                                              .toString()
                                              .padLeft(2, '0');
                                          model.availableTo = "$hour24:00";
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: 170.w,
                              height: 40.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (requestModel.description == null ||
                                      requestModel.description!.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("برجاء كتابه وصف المشكله",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (requestModel.day == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "برجاء اختيار اليوم المطلوب فيه الخدمة",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (requestModel.street == null ||
                                      requestModel.city == null ||
                                      requestModel.governorate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "برجاء تحديد العنوان بالكامل",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (requestModel.street!.length < 10 ||
                                      requestModel.street!.length > 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "برجاء كتابة عنوان أكثر تفصيلاً اسم الشارع لا يقل عن 10 حروف ولا يتجاوز 200 حرف",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (requestModel.description!.length < 10 ||
                                      requestModel.description!.length > 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "برجاء كتابة وصف أكثر تفصيلاً لا يقل عن 10 حروف ولا يتجاوز 200 حرف",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (!requestModel.allDayAvailability &&
                                      (requestModel.availableFrom == null ||
                                          requestModel.availableTo == null)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "برجاء تحديد الوقت المناسب",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  cubit.submitQuickRequest();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3775FA),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "طلب فني سريع",
                                      style: GoogleFonts.cairo(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(Iconsax.clock,
                                        color: Colors.white, size: 20.r),
                                  ],
                                ),
                              )),
                          SizedBox(width: 10.w),
                          SizedBox(
                              width: 170.w,
                              height: 40.h,
                              child: OutlinedButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (requestModel.description == null ||
                                      requestModel.description!.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("برجاء كتابه وصف المشكله",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (requestModel.day == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "برجاء اختيار اليوم المطلوب فيه الخدمة",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (requestModel.street == null ||
                                      requestModel.city == null ||
                                      requestModel.governorate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "برجاء اختيار المحافظه والمدينة وكتابة اسم الشارع بالتفصيل",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (!requestModel.allDayAvailability &&
                                      (requestModel.availableFrom == null ||
                                          requestModel.availableTo == null)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "برجاء تحديد الوقت المناسب",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (requestModel.street!.length < 10 ||
                                      requestModel.street!.length > 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "برجاء كتابة عنوان أكثر تفصيلاً اسم الشارع لا يقل عن 10 حروف ولا يتجاوز 200 حرف",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (requestModel.description!.length < 10 ||
                                      requestModel.description!.length > 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "برجاء كتابة وصف أكثر تفصيلاً لا يقل عن 10 حروف ولا يتجاوز 200 حرف",
                                            textDirection: TextDirection.rtl),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    SlideRightRoute(
                                      page: TechnicianReservePage(
                                        requestModel: requestModel,
                                      ),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  side: const BorderSide(
                                      color: Color(0xFF3775FA)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "اختيار الفني المناسب",
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 13.sp),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(Iconsax.search_normal,
                                        color: Colors.black, size: 20.r),
                                  ],
                                ),
                              )),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 170.w,
                            height: 150.h,
                            child: SvgPicture.asset("images/quick_reserve.svg"),
                          ),
                          SizedBox(
                            width: 170.w,
                            height: 150.h,
                            child: SvgPicture.asset(
                                "images/select_technician.svg"),
                          )
                        ],
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF3775FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF3775FA)))),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF3775FA), size: 16.r),
                SizedBox(width: 8.w),
                Text(title,
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 16.sp)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(text,
          style: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
              color: Colors.black)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF3775FA))),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    );
  }

  Widget _buildToggleOption(
      {required String text,
      required bool isSelected,
      required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3775FA) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField(BuildContext context, String label,
      String? currentValue, Function(TimeOfDay) onSave) {
    return InkWell(
      onTap: () async {
        FocusScope.of(context).unfocus();
        TimeOfDay? t = await showTimePickerModified(
          context: context,
          initialTime: TimeOfDay.now(),
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
          onSave(t);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$label : ${currentValue ?? '--:--'}",
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
}

void _showImageSourceSheet(BuildContext context, ServiceRequestCubit cubit) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading:
                  Icon(Icons.photo_camera, color: Colors.black, size: 24.r),
              title: Text('الكاميرا ',
                  style: TextStyle(color: Colors.black, fontSize: 14.sp)),
              onTap: () {
                cubit.pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            Divider(height: 1.h),
            ListTile(
              leading:
                  Icon(Icons.photo_library, color: Colors.black, size: 24.r),
              title: Text('المعرض ',
                  style: TextStyle(color: Colors.black, fontSize: 14.sp)),
              onTap: () {
                cubit.pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}
