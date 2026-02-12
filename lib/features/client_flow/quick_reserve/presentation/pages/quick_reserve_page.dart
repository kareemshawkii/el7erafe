import 'package:el7erafe/features/client_flow/client_home/data/models/quick_reservation_request.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/cubit/quick_reserve_cubit.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/cubit/quick_reserve_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class ServiceRequestPage extends StatelessWidget {
  final int serviceId;
  final String serviceName;

  const ServiceRequestPage(
      {super.key, required this.serviceId, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    final requestModel = ReservationRequest(
      serviceId: serviceId,
      serviceName: serviceName,
      day: DateTime.now(),
    );

    return BlocProvider(
      create: (context) => ServiceRequestCubit(requestModel),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "اختيار الفني المناسب",
            style: GoogleFonts.cairo(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
          listener: (context, state) {
            if (state is ServiceRequestError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ServiceRequestSuccess) {
              // Navigate to Success Page (Next Task)
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("تم إرسال الطلب بنجاح!")));
              Navigator.pop(context); // Or go to Success Page
            }
          },
          builder: (context, state) {
            var cubit = context.read<ServiceRequestCubit>();
            var model = cubit.requestModel;

            if (state is ServiceRequestLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- Section 1: Request Details ---
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
                      SizedBox(height: 16),
                      _buildLabel("صور للمشكله ان وجد"),
                      GestureDetector(
                        onTap: () => cubit.pickImage(),
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                style: BorderStyle
                                    .solid), // Dotted effect can be done with custom packages, solid is safer for now
                          ),
                          child: model.images != null &&
                                  model.images!.isNotEmpty
                              ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: model.images!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Image.file(model.images![index],
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.cover),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: InkWell(
                                              onTap: () =>
                                                  cubit.removeImage(index),
                                              child: Icon(Icons.cancel,
                                                  color: Colors.red),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Iconsax.gallery,
                                        color: Colors.blue, size: 30),
                                    SizedBox(height: 8),
                                    Text("اضغط لرفع الصورة",
                                        style: TextStyle(color: Colors.blue)),
                                    Text("(الحد الاقصى 6 ميجابايت)",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // --- Section 2: Address Details ---
                  _buildSectionCard(
                    title: "تفاصيل العنوان",
                    icon: Iconsax.location,
                    children: [
                      _buildLabel("المحافظة"),
                      _buildDropdown("اختار المحافظة اللي انت مقيم فيها"),
                      SizedBox(height: 12),
                      _buildLabel("المدينة"),
                      _buildDropdown("مصر الجديدة"), // Mock value
                      SizedBox(height: 12),
                      _buildLabel("الشارع"),
                      TextField(
                        onChanged: (val) => model.street = val,
                        decoration: _inputDecoration(
                            "اكتب اسم الشارع ورقم البيت أو العمارة"),
                      ),
                      SizedBox(height: 12),
                      _buildLabel("علامة مميزة"),
                      TextField(
                        onChanged: (val) => model.specialSign = val,
                        decoration: _inputDecoration(
                            "مثلا: جنب مسجد النور - أو أمام السوبر ماركت الكبير"),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // --- Section 3: Time Selection ---
                  _buildSectionCard(
                    title: "تحديد الوقت",
                    icon: Iconsax.clock,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("اختار اليوم :",
                              style: GoogleFonts.cairo(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          Text(DateFormat('yyyy > MMMM').format(model.day!),
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),

                      // Inline Calendar
                      Container(
                        height: 300,
                        child: CalendarDatePicker(
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 30)),
                          onDateChanged: (date) {
                            model.day = date;
                            // Force rebuild to show selected date
                            cubit.emit(ServiceRequestImageUpdated());
                          },
                        ),
                      ),

                      SizedBox(height: 10),
                      Text("اختار الوقت :",
                          style: GoogleFonts.cairo(
                              color: Colors.blue, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),

                      // Time Toggle (All Day vs Specific)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _buildToggleOption(
                                text: "من إلى (وقت محدد)",
                                isSelected: !model.allDayAvailability,
                                onTap: () => cubit.toggleAllDay(false)),
                            _buildToggleOption(
                                text: "طول اليوم",
                                isSelected: model.allDayAvailability,
                                onTap: () => cubit.toggleAllDay(true)),
                          ],
                        ),
                      ),

                      // Specific Time Pickers (Visible only if All Day is FALSE)
                      if (!model.allDayAvailability)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: _buildTimePickerField(context, "من",
                                      (t) => model.availableFrom = t)),
                              SizedBox(width: 10),
                              Expanded(
                                  child: _buildTimePickerField(context, "إلى",
                                      (t) => model.availableTo = t)),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // --- Action Buttons ---
                  Row(
                    children: [
                      // "Quick Reserve" Button (Active)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            cubit.submitQuickRequest();
                          },
                          icon: Icon(Iconsax.clock, color: Colors.white),
                          label: Text("طلب فني سريع",
                              style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3775FA), // Blue
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // "Choose Technician" Button (Inactive/Outlined)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Logic for manual selection (Not implemented yet)
                          },
                          icon:
                              Icon(Iconsax.search_normal, color: Colors.black),
                          label: Text("اختيار الفني المناسب",
                              style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Helper Widgets for Consistency ---

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Color(0xFF3775FA).withOpacity(0.5)), // Blue Border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Blue Line
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: Row(
              children: [
                Icon(icon, color: Color(0xFF3775FA), size: 20),
                SizedBox(width: 8),
                Text(title,
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 14)),
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
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey[700])),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildDropdown(String hint) {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(hint),
      items: [],
      onChanged: (val) {},
      icon: Icon(Icons.keyboard_arrow_down),
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
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF3775FA) : Colors.transparent,
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
            context: context, initialTime: TimeOfDay.now());
        if (t != null) {
          // You might need state to update the text here, keeping it simple for now
          onSave("${t.hour}:${t.minute}");
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label + ": --:--", style: GoogleFonts.cairo()),
            Icon(Icons.access_time, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
