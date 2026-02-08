import 'dart:io';
import 'package:el7erafe/core/services/local_storage/rejected_local_storage.dart';
import 'package:el7erafe/core/services/models/rejected_user.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/model/rejected_technician_model.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_resubmit_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_resubmit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/widgets/image_picker.dart';

class TechnicianResubmitForm extends StatefulWidget {
  const TechnicianResubmitForm({super.key});

  @override
  State<TechnicianResubmitForm> createState() => _TechnicianResubmitFormState();
}

class _TechnicianResubmitFormState extends State<TechnicianResubmitForm> {
  RejectedUserModel? rejectedTechnician;
  RejectedTechnicianModel? requestModel;

  final _formKey = GlobalKey<FormState>();

  File? frontIdImage;
  File? backIdImage;
  File? criminalRecordImage;

  @override
  void initState() {
    super.initState();
    _loadRejectedUser();
  }

  Future<void> _loadRejectedUser() async {
    rejectedTechnician = await RejectedLocalStorage().getRejectedTechnician();
    setState(() {});
  }

  void _onRegisterPressed() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (rejectedTechnician == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('حدث خطأ في تحميل بيانات الرفض'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final missing = rejectedTechnician!.missingFiles;

    if (missing.contains("NationalIdFront") && frontIdImage == null) {
      _showError("الرجاء رفع صورة البطاقة الأمامية المطلوبة");
      return;
    }

    if (missing.contains("NationalIdBack") && backIdImage == null) {
      _showError("الرجاء رفع صورة البطاقة الخلفية المطلوبة");
      return;
    }

    if (missing.contains("CriminalRecord") && criminalRecordImage == null) {
      _showError("الرجاء رفع صحيفة الحالة الجنائية المطلوبة");
      return;
    }

    requestModel = RejectedTechnicianModel(
      frontIdImage: missing.contains("NationalIdFront") ? frontIdImage : null,
      backIdImage: missing.contains("NationalIdBack") ? backIdImage : null,
      criminalRecordImage:
          missing.contains("CriminalRecord") ? criminalRecordImage : null,
    );

    context.read<TechnicianResubmitCubit>().resubmitTechnicianRegistration(
          requestModel!,
          rejectedTechnician!,
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message, textDirection: TextDirection.rtl),
          backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: (90 / 852) * screenHeight,
            width: (361 / 393) * screenWidth,
            padding: EdgeInsets.fromLTRB(
                (12 / 393) * screenWidth,
                (12 / 852) * screenHeight,
                (8 / 393) * screenWidth,
                (12 / 852) * screenHeight),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE2DFDF), width: 1.0),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'سبب الرفض',
                      style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF971313)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: (8 / 393) * screenWidth),
                    SizedBox(
                      width: (24 / 393) * screenWidth,
                      height: (24 / 852) * screenHeight,
                      child: SvgPicture.asset('images/warning-2.svg'),
                    ),
                  ],
                ),
                SizedBox(height: (8 / 852) * screenHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      rejectedTechnician?.rejectionReason ??
                          'جارٍ تحميل سبب الرفض...',
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF000000)),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(width: (32 / 393) * screenWidth),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: (14 / 852) * screenHeight),
          Container(
              padding: EdgeInsets.fromLTRB(
                  (8 / 393) * screenWidth,
                  (12 / 852) * screenHeight,
                  (8 / 393) * screenWidth,
                  (12 / 852) * screenHeight),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE2DFDF), width: 1.0),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('البيانات الاساسيه',
                    style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3775FA))),
                SizedBox(height: (16 / 852) * screenHeight),
                Text('الاسم',
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black)),
                SizedBox(height: (8 / 852) * screenHeight),
                Container(
                  height: (40 / 852) * screenHeight,
                  width: (345 / 393) * screenWidth,
                  padding: EdgeInsets.fromLTRB(
                      (8 / 393) * screenWidth,
                      (8 / 852) * screenHeight,
                      (8 / 393) * screenWidth,
                      (8 / 852) * screenHeight),
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFE2DFDF), width: 1.0),
                      borderRadius: BorderRadius.circular(12.0),
                      color: Color.fromARGB(255, 238, 238, 238)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        rejectedTechnician?.name ?? 'جارٍ تحميل الاسم...',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF727070)),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(width: (8 / 393) * screenWidth),
                      Icon(
                        Icons.person_2_outlined,
                        color: Color(0xFF727070),
                        size: 18,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (16 / 852) * screenHeight),
                Text('رقم التليفون',
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black)),
                SizedBox(height: (8 / 852) * screenHeight),
                Container(
                  height: (40 / 852) * screenHeight,
                  width: (345 / 393) * screenWidth,
                  padding: EdgeInsets.fromLTRB(
                      (8 / 393) * screenWidth,
                      (8 / 852) * screenHeight,
                      (8 / 393) * screenWidth,
                      (8 / 852) * screenHeight),
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFE2DFDF), width: 1.0),
                      borderRadius: BorderRadius.circular(12.0),
                      color: Color.fromARGB(255, 238, 238, 238)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        rejectedTechnician?.phone ??
                            'جارٍ تحميل رقم التليفون...',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF727070)),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(width: (8 / 393) * screenWidth),
                      Icon(
                        Icons.call,
                        color: Color(0xFF727070),
                        size: 18,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (16 / 852) * screenHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("المدينة",
                        style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black)),
                    SizedBox(width: (123 / 393) * screenWidth),
                    Text("المحافظة",
                        style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black)),
                  ],
                ),
                SizedBox(height: (8 / 852) * screenHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: (40 / 852) * screenHeight,
                      width: (166 / 393) * screenWidth,
                      padding: EdgeInsets.fromLTRB(
                          (12 / 393) * screenWidth,
                          (8 / 852) * screenHeight,
                          (12 / 393) * screenWidth,
                          (8 / 852) * screenHeight),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xFFE2DFDF), width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                          color: Color.fromARGB(255, 238, 238, 238)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF727070),
                            size: 15,
                          ),
                          Text(
                            rejectedTechnician?.city ?? 'جارٍ تحميل المدينة...',
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF727070)),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: (8 / 393) * screenWidth),
                    Container(
                      height: (40 / 852) * screenHeight,
                      width: (166 / 393) * screenWidth,
                      padding: EdgeInsets.fromLTRB(
                          (12 / 393) * screenWidth,
                          (8 / 852) * screenHeight,
                          (12 / 393) * screenWidth,
                          (8 / 852) * screenHeight),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xFFE2DFDF), width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                          color: Color.fromARGB(255, 238, 238, 238)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF727070),
                            size: 15,
                          ),
                          Text(
                            rejectedTechnician?.governorate ??
                                'جارٍ تحميل المحافظه...',
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF727070)),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: (16 / 852) * screenHeight),
                Text('الحرفة',
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black)),
                SizedBox(height: (8 / 852) * screenHeight),
                Container(
                  height: (40 / 852) * screenHeight,
                  width: (166 / 393) * screenWidth,
                  padding: EdgeInsets.fromLTRB(
                      (12 / 393) * screenWidth,
                      (8 / 852) * screenHeight,
                      (12 / 393) * screenWidth,
                      (8 / 852) * screenHeight),
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFE2DFDF), width: 1.0),
                      borderRadius: BorderRadius.circular(12.0),
                      color: Color.fromARGB(255, 238, 238, 238)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF727070),
                        size: 15,
                      ),
                      Text(
                        rejectedTechnician?.serviceType ??
                            'جارٍ تحميل الحرف...',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF727070)),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ])),
          SizedBox(height: (14 / 852) * screenHeight),
          Container(
              padding: EdgeInsets.fromLTRB(
                  (8 / 393) * screenWidth,
                  (12 / 852) * screenHeight,
                  (8 / 393) * screenWidth,
                  (12 / 852) * screenHeight),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE2DFDF), width: 1.0),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('توثيق حسابك',
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF3775FA))),
                SizedBox(height: (16 / 852) * screenHeight),
                Text('بطاقتك الشخصية',
                    style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000))),
                SizedBox(height: (16 / 852) * screenHeight),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('صورة البطاقة من الوش',
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        const SizedBox(height: 8),
                        ImagePickerButton(
                          enabled: rejectedTechnician?.frontId ?? false,
                          disabledImage: 'images/uploaded.svg',
                          width: (345 / 393) * screenWidth,
                          height: (94 / 852) * screenHeight,
                          defaultImage: 'images/id_front_placeholder.svg',
                          onImagePicked: (file) {
                            setState(() {
                              frontIdImage = file;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: (12 / 852) * screenHeight),
                    Text('صورة البطاقة من الظهر',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black)),
                    const SizedBox(height: 8),
                    ImagePickerButton(
                      enabled: rejectedTechnician?.backId ?? false,
                      disabledImage: 'images/uploaded.svg',
                      width: (345 / 393) * screenWidth,
                      height: (94 / 852) * screenHeight,
                      defaultImage: 'images/id_back_placeholder.svg',
                      onImagePicked: (file) {
                        setState(() {
                          backIdImage = file;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('الفيش الجنائي',
                    style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000000))),
                SizedBox(height: (16 / 852) * screenHeight),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('ارفع نسخة واضحة من الفيش الجنائي',
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.black)),
                    ),
                    SizedBox(height: (16 / 852) * screenHeight),
                    ImagePickerButton(
                      enabled: rejectedTechnician?.criminalRecord ?? false,
                      disabledImage: 'images/uploaded.svg',
                      width: (345 / 393) * screenWidth,
                      height: (94 / 852) * screenHeight,
                      defaultImage: 'images/criminal_record_placeholder.svg',
                      onImagePicked: (file) {
                        setState(() {
                          criminalRecordImage = file;
                        });
                      },
                    ),
                  ],
                ),
              ])),
          SizedBox(height: (24 / 852) * screenHeight),
          SizedBox(
            width: double.infinity,
            height: (40 / 852) * screenHeight,
            child:
                BlocBuilder<TechnicianResubmitCubit, TechnicianResubmitState>(
              builder: (context, state) {
                final isLoading = state is TechnicianResubmitLoading;
                return Container(
                    width: double.infinity,
                    height: (40 / 852) * screenHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Color(0xFF3775FA),
                        width: 1.0,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onRegisterPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3775FA),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color.fromARGB(158, 55, 117, 250),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                                color: Colors.white, width: 1.0)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Color(0xFF3775FA), strokeWidth: 3),
                            )
                          : Text('اعادة الارسال',
                              style: GoogleFonts.cairo(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
