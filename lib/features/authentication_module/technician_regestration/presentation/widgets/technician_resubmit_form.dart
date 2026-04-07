import 'dart:io';
import 'package:el7erafe/core/services/local_storage/rejected_local_storage.dart';
import 'package:el7erafe/core/services/models/rejected_user.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/model/rejected_technician_model.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_resubmit_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_resubmit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      ModernSnackbar.showError(
          context: context,
          message: "حدث خطأ غير متوقع، الرجاء المحاولة لاحقًا");
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
    ModernSnackbar.showError(context: context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: 90.h,
            width: 361.w,
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 8.w, 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE2DFDF), width: 1.w),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: SvgPicture.asset('images/warning-2.svg'),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'سبب الرفض',
                      style: GoogleFonts.cairo(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF971313)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      rejectedTechnician?.rejectionReason ??
                          'جارٍ تحميل سبب الرفض...',
                      style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF000000)),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(width: 32.w),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Container(
              padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE2DFDF), width: 1.w),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('البيانات الاساسيه',
                        style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3775FA))),
                    SizedBox(height: 16.h),
                    Text('الاسم',
                        style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black)),
                    SizedBox(height: 8.h),
                    Container(
                      height: 40.h,
                      width: 345.w,
                      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xFFE2DFDF), width: 1.w),
                          borderRadius: BorderRadius.circular(12.r),
                          color: Color.fromARGB(255, 238, 238, 238)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            rejectedTechnician?.name ?? 'جارٍ تحميل الاسم...',
                            style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF727070)),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.person_2_outlined,
                            color: Color(0xFF727070),
                            size: 18.r,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text('رقم التليفون',
                        style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black)),
                    SizedBox(height: 8.h),
                    Container(
                      height: 40.h,
                      width: 345.w,
                      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xFFE2DFDF), width: 1.w),
                          borderRadius: BorderRadius.circular(12.r),
                          color: Color.fromARGB(255, 238, 238, 238)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            rejectedTechnician?.phone ??
                                'جارٍ تحميل رقم التليفون...',
                            style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF727070)),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.call,
                            color: Color(0xFF727070),
                            size: 18.r,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("المحافظة",
                            style: GoogleFonts.cairo(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        SizedBox(width: 123.w),
                        Text("المدينة",
                            style: GoogleFonts.cairo(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 40.h,
                          width: 166.w,
                          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFE2DFDF), width: 1.w),
                              borderRadius: BorderRadius.circular(12.r),
                              color: Color.fromARGB(255, 238, 238, 238)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF727070),
                                size: 15.r,
                              ),
                              Text(
                                rejectedTechnician?.city ??
                                    'جارٍ تحميل المدينة...',
                                style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF727070)),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          height: 40.h,
                          width: 166.w,
                          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFFE2DFDF), width: 1.w),
                              borderRadius: BorderRadius.circular(12.r),
                              color: Color.fromARGB(255, 238, 238, 238)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF727070),
                                size: 15.r,
                              ),
                              Text(
                                rejectedTechnician?.governorate ??
                                    'جارٍ تحميل المحافظه...',
                                style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF727070)),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text('الحرفة',
                        style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black)),
                    SizedBox(height: 8.h),
                    Container(
                      height: 40.h,
                      width: 166.w,
                      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xFFE2DFDF), width: 1.w),
                          borderRadius: BorderRadius.circular(12.r),
                          color: Color.fromARGB(255, 238, 238, 238)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF727070),
                            size: 15.r,
                          ),
                          Text(
                            rejectedTechnician?.serviceType ??
                                'جارٍ تحميل الحرف...',
                            style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF727070)),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ])),
          SizedBox(height: 14.h),
          Container(
              padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE2DFDF), width: 1.w),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('توثيق حسابك',
                        style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF3775FA))),
                    SizedBox(height: 16.h),
                    Text('بطاقتك الشخصية',
                        style: GoogleFonts.cairo(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000))),
                    SizedBox(height: 16.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('صورة البطاقة من الوش',
                                style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black)),
                            SizedBox(height: 8.h),
                            ImagePickerButton(
                              enabled: rejectedTechnician?.frontId ?? false,
                              disabledImage: 'images/uploaded.svg',
                              width: 345.w,
                              height: 94.h,
                              defaultImage: 'images/id_front_placeholder.svg',
                              onImagePicked: (file) {
                                setState(() {
                                  frontIdImage = file;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text('صورة البطاقة من الظهر',
                            style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        SizedBox(height: 8.h),
                        ImagePickerButton(
                          enabled: rejectedTechnician?.backId ?? false,
                          disabledImage: 'images/uploaded.svg',
                          width: 345.w,
                          height: 94.h,
                          defaultImage: 'images/id_back_placeholder.svg',
                          onImagePicked: (file) {
                            setState(() {
                              backIdImage = file;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text('الفيش الجنائي',
                        style: GoogleFonts.cairo(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000))),
                    SizedBox(height: 16.h),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('ارفع نسخة واضحة من الفيش الجنائي',
                              style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black)),
                        ),
                        SizedBox(height: 16.h),
                        ImagePickerButton(
                          enabled: rejectedTechnician?.criminalRecord ?? false,
                          disabledImage: 'images/uploaded.svg',
                          width: 345.w,
                          height: 94.h,
                          defaultImage:
                              'images/criminal_record_placeholder.svg',
                          onImagePicked: (file) {
                            setState(() {
                              criminalRecordImage = file;
                            });
                          },
                        ),
                      ],
                    ),
                  ])),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child:
                BlocBuilder<TechnicianResubmitCubit, TechnicianResubmitState>(
              builder: (context, state) {
                final isLoading = state is TechnicianResubmitLoading;
                return Container(
                    width: double.infinity,
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Color(0xFF3775FA),
                        width: 1.w,
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
                            borderRadius: BorderRadius.circular(12.r),
                            side: const BorderSide(
                                color: Colors.white, width: 1.0)),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 24.r,
                              width: 24.r,
                              child: const CircularProgressIndicator(
                                  color: Color(0xFF3775FA), strokeWidth: 3),
                            )
                          : Text('اعادة الارسال',
                              style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500)),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
