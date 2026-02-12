import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/widgets/location_picker.dart';
import 'package:el7erafe/features/client_flow/client_home/data/models/quick_reservation_request.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/cubit/quick_reserve_cubit.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/cubit/quick_reserve_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  Widget build(BuildContext context) {
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
            toolbarHeight: 50,
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.blueAccent,
            surfaceTintColor: Colors.blueAccent,
            centerTitle: true,
            title: Text.rich(
              TextSpan(
                style: GoogleFonts.cairo(
                  fontSize: 22,
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
                          decoration: InputDecoration(
                            hintText:
                                "اكتب تفاصيل المشكلة اللي محتاج الفني يجي يصلحها",
                            hintStyle: GoogleFonts.cairo(
                                fontSize: 13, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3775FA),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: "تفاصيل العنوان",
                      icon: Iconsax.location,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("المحافظة",
                                style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black)),
                            const SizedBox(width: 130),
                            Text("المدينة",
                                style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 12),
                        _buildLabel("الشارع"),
                        TextField(
                          onChanged: (val) => model.street = val,
                          decoration: _inputDecoration(
                              "اكتب اسم الشارع ورقم البيت أو العمارة"),
                        ),
                        const SizedBox(height: 12),
                        _buildLabel("علامة مميزة"),
                        TextField(
                          onChanged: (val) => model.specialSign = val,
                          decoration: _inputDecoration(
                              "مثلا: جنب مسجد النور - أو أمام السوبر ماركت الكبير"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                                  color: Color(0xFF3775FA),
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 10),
                        Text("اختار الوقت :",
                            style: GoogleFonts.cairo(
                                color: Color(0xFF3775FA),
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
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
                                    child: _buildTimePickerField(context, "من",
                                        (t) => model.availableFrom = t)),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: _buildTimePickerField(context, "إلى",
                                        (t) => model.availableTo = t)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              cubit.submitQuickRequest();
                            },
                            icon:
                                const Icon(Iconsax.clock, color: Colors.white),
                            label: Text("طلب فني سريع",
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3775FA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Iconsax.search_normal,
                                color: Colors.black),
                            label: Text("اختيار الفني المناسب",
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3775FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            padding: const EdgeInsets.all(16.0),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField(
    BuildContext context, String label, Function(String) onSave) {
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
                hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        // ignore: deprecated_member_use
                        ? const Color(0xFF3775FA).withOpacity(0.1)
                        : Colors.grey.shade100),

                // AM/PM Indicator Styles
                dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.white
                        : const Color(0xFF3775FA)),
                dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? const Color(0xFF3775FA)
                        : Colors.transparent),
                dayPeriodBorderSide: const BorderSide(color: Color(0xFF3775FA)),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                child: child!,
              ),
            ),
          );
        },
      );
      if (t != null) {
        onSave("${t.hour}:${t.minute.toString().padLeft(2, '0')}"); 
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
          Text("$label      : --:--", style: GoogleFonts.cairo()),
          const Icon(Icons.access_time, size: 16, color: Color(0xFF3775FA)),
        ],
      ),
    ),
  );
}
}

// Global helper method (can remain outside)
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
