import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/widgets/location_picker.dart';
import 'package:el7erafe/features/client_flow/client_home/data/models/quick_reservation_request.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/cubit/quick_reserve_cubit.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/cubit/quick_reserve_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

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
  // --- STATE VARIABLES FOR TIME DISPLAY ---
  String? selectedStartTime;
  String? selectedEndTime;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Create the model once
    final requestModel = ReservationRequest(
      serviceId: widget.serviceId,
      serviceName: widget.serviceName,
      day: DateTime.now(),
    );

    return BlocProvider(
      create: (context) => ServiceRequestCubit(requestModel),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: (50 / 852) * screenHeight,
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.blueAccent,
            surfaceTintColor: Colors.blueAccent,
            centerTitle: true,
            title: Text.rich(
              TextSpan(
                style: GoogleFonts.cairo(
                  fontSize: 20,
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
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is ServiceRequestSuccess) {
                // Navigate to Success Page
              }
            },
            builder: (context, state) {
              var cubit = context.read<ServiceRequestCubit>();
              var model = cubit.requestModel;

              if (state is ServiceRequestLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                        SizedBox(height: (16 / 852) * screenHeight),
                        _buildLabel("صور للمشكله ان وجد"),
                        Container(
                          height: 120,
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFE),
                            borderRadius: BorderRadius.circular(12),
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
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFF3775FA),
                                          width: 1),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Iconsax.gallery_add,
                                            color: Color(0xFF3775FA), size: 28),
                                        SizedBox(height: 4),
                                        Text("أضف صورة",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF3775FA),
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        model.images![index],
                                        height: 104,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: InkWell(
                                        onTap: () => cubit.removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 2)
                                            ],
                                          ),
                                          child: const Icon(Icons.close,
                                              color: Colors.red, size: 16),
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
                    SizedBox(height: (16 / 852) * screenHeight),
                    _buildSectionCard(
                      title: "تفاصيل العنوان",
                      icon: Iconsax.location,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("المحافظة",
                                style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                            SizedBox(width: (105 / 393) * screenWidth),
                            Text("المدينة",
                                style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                          ],
                        ),
                        SizedBox(height: (8 / 852) * screenHeight),
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
                        SizedBox(height: (12 / 852) * screenHeight),
                        _buildLabel("الشارع"),
                        TextField(
                          onChanged: (val) => model.street = val,
                          decoration: _inputDecoration(
                              "اكتب اسم الشارع ورقم البيت أو العمارة"),
                        ),
                        SizedBox(height: (12 / 852) * screenHeight),
                        _buildLabel("علامة مميزة"),
                        TextField(
                          onChanged: (val) => model.specialSign = val,
                          decoration: _inputDecoration(
                              "مثلا: جنب مسجد النور - أو أمام السوبر ماركت الكبير"),
                        ),
                      ],
                    ),
                    SizedBox(height: (16 / 852) * screenHeight),
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
                                  fontSize: 16,
                                  color: const Color(0xFF3775FA),
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        SizedBox(height: (8 / 852) * screenHeight),
                        SizedBox(
                            height: 300,
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: CalendarDatePicker2(
                                config: CalendarDatePicker2Config(
                                  calendarType: CalendarDatePicker2Type.single,
                                  selectedDayHighlightColor:
                                      const Color(0xFF3775FA),
                                  selectedDayTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                fontSize: 16,
                                color: const Color(0xFF3775FA),
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: (8 / 852) * screenHeight),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(20),
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
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: _buildTimePickerField(context, "من", selectedStartTime,
                                        (t) {
                                  setState(() => selectedStartTime = t);
                                  model.availableFrom = t;
                                })),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: _buildTimePickerField(context, "إلى", selectedEndTime,
                                        (t) {
                                  setState(() => selectedEndTime = t);
                                  model.availableTo = t;
                                })),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: (24 / 852) * screenHeight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: (170 / 393) * screenWidth,
                            height: (40 / 852) * screenHeight,
                            child: ElevatedButton(
                              onPressed: () {
                                cubit.submitQuickRequest();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3775FA),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "طلب فني سريع",
                                    style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Iconsax.clock,
                                      color: Colors.white),
                                ],
                              ),
                            )),
                        const SizedBox(width: 10),
                        SizedBox(
                            width: (170 / 393) * screenWidth,
                            height: (40 / 852) * screenHeight,
                            child: OutlinedButton(
                              onPressed: () {
                                // Navigate to technician selection page
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                side: const BorderSide(
                                    color: Color(0xFF3775FA)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "اختيار الفني المناسب",
                                    style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Iconsax.search_normal,
                                      color: Colors.black),
                                ],
                              ),
                            )),
                      ],
                    ),
                    SizedBox(height: (16 / 852) * screenHeight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: (170 / 393) * screenWidth,
                          height: (150 / 852) * screenHeight,
                          child: SvgPicture.asset("images/quick_reserve.svg"),
                        ),
                        SizedBox(
                          width: (170 / 393) * screenWidth,
                          height: (150 / 852) * screenHeight,
                          child: SvgPicture.asset(
                              "images/select_technician.svg"),
                        )
                      ],
                    ),
                    SizedBox(height: (24 / 852) * screenHeight),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3775FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF3775FA)))),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF3775FA), size: 16),
                const SizedBox(width: 8),
                Text(title,
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: GoogleFonts.cairo(
              fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3775FA))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3775FA) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // --- FIXED TIME PICKER FIELD ---
  Widget _buildTimePickerField(
      BuildContext context, String label, String? currentValue, Function(String) onSave) {
    return InkWell(
      onTap: () async {
        TimeOfDay? t = await showTimePicker(
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
                  hourMinuteColor: WidgetStateColor.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          // ignore: deprecated_member_use
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
          // Force 12-hour format display text
          if(!context.mounted) return;
          final localizations = MaterialLocalizations.of(context);
          final String formattedTime =
              localizations.formatTimeOfDay(t, alwaysUse24HourFormat: false);
          onSave(formattedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Display current value or placeholder
            Text("$label : ${currentValue ?? '--:--'}", 
              style: GoogleFonts.cairo(
                  color: currentValue == null ? Colors.grey : Colors.black,
                  fontWeight: FontWeight.bold
              )
            ),
            const Icon(Icons.access_time, size: 16, color: Color(0xFF3775FA)),
          ],
        ),
      ),
    );
  }
}

// Global helper method
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
              leading: const Icon(Icons.photo_camera, color: Colors.black),
              title: const Text('الكاميرا ',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                cubit.pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.black),
              title:
                  const Text('المعرض ', style: TextStyle(color: Colors.black)),
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