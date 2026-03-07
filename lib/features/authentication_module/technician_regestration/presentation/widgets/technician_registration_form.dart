import 'dart:convert';
import 'dart:io';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/password_strength_cubit.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/password_strength_state.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/techincian_registration_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_registration_state.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/widgets/location_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/widgets/image_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http/http.dart' as http;

class TechnicianRegistrationForm extends StatefulWidget {
  const TechnicianRegistrationForm({super.key});

  @override
  State<TechnicianRegistrationForm> createState() =>
      _TechnicianRegistrationFormState();
}

class _TechnicianRegistrationFormState
    extends State<TechnicianRegistrationForm> {
  final ValueNotifier<String?> _serviceNotifier = ValueNotifier<String?>(null);
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  String? _password;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  File? profileImage;
  File? frontIdImage;
  File? backIdImage;
  File? criminalRecordImage;
  String? _selectedGovernorate;
  String? _selectedCity;
  bool isLoading = false;
  List<String> services = [];
  String? selectedService;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    List<String> data = await getServices();
    if (mounted) {
      setState(() {
        services = data;
        isLoading = false;
      });
    }
  }

  Future<List<String>> getServices() async {
    var url = Uri.parse(
        'https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net/api/public/services');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        if (responseBody is Map<String, dynamic> &&
            responseBody.containsKey('services')) {
          if (responseBody['services'] is List) {
            return List<String>.from(responseBody['services']);
          }
        }
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  void _onRegisterPressed() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (frontIdImage == null ||
          backIdImage == null ||
          criminalRecordImage == null ||
          profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('الرجاء إرفاق جميع الصور المطلوبة',
                  textDirection: TextDirection.rtl),
              backgroundColor: Colors.red),
        );
        return;
      }
    }

    if (_selectedGovernorate == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء اختيار المحافظة والمدينة',
                textDirection: TextDirection.rtl),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء اختيار نوع الحرفة',
                textDirection: TextDirection.rtl),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<TechnicianRegistrationCubit>().register(
            _nameController.text.trim(), 
            _phoneController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text, 
            profileImage!,
            frontIdImage!,
            backIdImage!,
            criminalRecordImage!,
            _selectedGovernorate!,
            _selectedCity!,
            selectedService!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      controller: _nameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textAlign: TextAlign.right,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person_2_outlined,
                          color: Color(0xFF727070),
                          size: 18.r,
                        ),
                        hintText: 'ادخل اسمك ثنائي ',
                        hintStyle: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            color: const Color(0xFF727070),
                            fontWeight: FontWeight.w400),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2DFDF))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFF3775FA))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2DFDF))),
                        contentPadding: EdgeInsets.all(12.r),
                        errorStyle: TextStyle(
                          fontSize: 11.sp,
                        ),
                      ),
                      validator: (value) {
                        final cleanValue = value?.trim() ?? '';
                        
                        if (cleanValue.isEmpty) {
                          return 'من فضلك دخل اسمك الثنائي';
                        }
                        if (!RegExp(r'^([A-Za-z\u0600-\u06FF\s]+)$')
                            .hasMatch(cleanValue)) {
                          return 'الاسم لازم يكون حروف عربية أو إنجليزية فقط';
                        }
                        if (!RegExp(
                                r'^[A-Za-z\u0600-\u06FF]+\s+[A-Za-z\u0600-\u06FF]+$')
                            .hasMatch(cleanValue)) {
                          return 'الرجاء إدخال الاسم الأول والأخير (مثال: كريم شوقي)';
                        }
                        if (cleanValue.length < 3 || cleanValue.length > 50) {
                          return 'الاسم لازم يكون بين 3 و 50 حرف';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text('رقم التليفون',
                      style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black)),
                  SizedBox(height: 8.h),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      controller: _phoneController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Iconsax.call,
                          color: Color(0xFF727070),
                          size: 18.r,
                        ),
                        hintText: '01X XXX XXXX',
                        hintStyle: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            color: const Color(0xFF727070),
                            fontWeight: FontWeight.w400),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2DFDF))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFF3775FA))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2DFDF))),
                        contentPadding: EdgeInsets.all(12.r),
                        errorStyle: TextStyle(
                          fontSize: 11.sp,
                        ),
                      ),
                      validator: (value) {
                        final cleanValue = value?.trim() ?? '';
                        if (cleanValue.isEmpty) {
                          return 'من فضلك دخل رقم التليفون';
                        }
                        if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(cleanValue)) {
                          return 'من فضلك دخل رقم التليفون صحيح';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text('البريد الإلكتروني',
                      style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black)),
                  SizedBox(height: 8.h),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      controller: _emailController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')), 
                        LengthLimitingTextInputFormatter(50),
                      ],
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email,
                          color: Color(0xFF727070),
                          size: 18.r,
                        ),
                        hintText: 'name@domain.com',
                        hintStyle: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            color: const Color(0xFF727070),
                            fontWeight: FontWeight.w400),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2DFDF))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFF3775FA))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2DFDF))),
                        contentPadding: EdgeInsets.all(12.r),
                        errorStyle: TextStyle(
                          fontSize: 11.sp,
                        ),
                      ),
                      validator: (value) {
                        final cleanValue = value?.trim() ?? '';
                        if (cleanValue.isEmpty) {
                          return 'من فضلك دخل البريد الإلكتروني';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(cleanValue)) {
                          return 'من فضلك دخل بريد إلكتروني صحيح';
                        }
                        if (cleanValue.length > 50) {
                          return 'البريد الإلكتروني لازم يكون أقل من 50 حرف';
                        }
                        return null;
                      },
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
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: EgyptGovernoratePicker(
                      language: Language.arabic,
                      layout: Layout.horizontal,
                      showCities: true,
                      governorateDropdownLabel: "المحافظة",
                      cityDropdownLabel: "المدينة",
                      assetDataPath: "assets/data/egypt_data.json",
                      onGovernorateChanged: (String? newGov) {
                        setState(() {
                          _selectedGovernorate = newGov;
                          _selectedCity = null;
                        });
                      },
                      onCityChanged: (String? newCity) {
                        setState(() {
                          _selectedCity = newCity;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text('الحرفة',
                      style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black)),
                  SizedBox(height: 8.h),
                  Directionality(
                      textDirection: TextDirection.rtl,
                      child: SizedBox(
                          width: 165.w,
                          child: DropdownButtonFormField2<String>(
                            valueListenable: _serviceNotifier,
                            isExpanded: true,
                            onChanged: isLoading
                                ? null
                                : (newValue) {
                                    setState(() {
                                      selectedService = newValue;
                                      _serviceNotifier.value = newValue;
                                    });
                                  },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2DFDF)),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xFF3775FA)),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              contentPadding: EdgeInsets.all(8.r),
                              hintText: isLoading
                                  ? "جارٍ تحميل الحرف..."
                                  : "اختار حرفتك",
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: Colors.white,
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                            ),
                            items: isLoading
                                ? [
                                    DropdownItem<String>(
                                      value: null,
                                      enabled: false,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 3),
                                        ),
                                      ),
                                    ),
                                  ]
                                : services.map((service) {
                                    return DropdownItem<String>(
                                      value: service,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          service,
                                          style: GoogleFonts.cairo(
                                            fontSize: 15.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textDirection: TextDirection.rtl,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                          ))),
                  SizedBox(height: 16.h),
                  Text('صوره شخصيه',
                      style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black)),
                  SizedBox(height: 8.h),
                  ImagePickerButton(
                    width: 337.w,
                    height: 118.h,
                    defaultImage: 'images/profileImage.svg',
                    onImagePicked: (file) {
                      setState(() {
                        profileImage = file;
                      });
                    },
                  ),
                ],
              )),
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
                    Text('أمان حسابك',
                        style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3775FA))),
                    SizedBox(height: 16.h),
                    Text('كلمة السر',
                        style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black)),
                    SizedBox(height: 8.h),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textAlign: TextAlign.right,
                        obscureText: _isPasswordObscured,
                        decoration: InputDecoration(
                          hintText: 'من فضلك دخل كلمه السر',
                          hintStyle: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              color: const Color(0xFF727070),
                              fontWeight: FontWeight.w400),
                          prefixIcon: const Icon(
                            Iconsax.lock,
                            color: Color(0xFF727070),
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF727070),
                              size: 18.r,
                            ),
                            onPressed: () => setState(() =>
                                _isPasswordObscured = !_isPasswordObscured),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2DFDF))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  const BorderSide(color: Color(0xFF3775FA))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2DFDF))),
                          contentPadding: EdgeInsets.all(12.r),
                          errorStyle: TextStyle(
                            fontSize: 11.sp,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'من فضلك دخل كلمة السر';
                          }
                          if (!RegExp(
                                  r'''^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[~!@#$%^&*()_\-+=\[\]{}|\\:;"<>,.?/`'])(?=.{10,})''')
                              .hasMatch(value)) {
                            return 'كلمة السر لازم تحتوي على حرف كبير، رقم، رمز وطولها 10 أحرف على الأقل';
                          }
                          if (value.length > 32) {
                            return 'كلمة السر لازم تكون أقل من 32 حرف';
                          }
                          return null;
                        },
                        onChanged: (val) {
                          _password = val;
                          context
                              .read<PasswordStrengthCubit>()
                              .validatePassword(val);
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(':كلمة السر لازم تحتوي على',
                        style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF727070))),
                    SizedBox(height: 12.h),
                    BlocBuilder<PasswordStrengthCubit, PasswordStrengthState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            _buildValidationCheckItem(
                              text: '١٠ حروف أو أكثر',
                              isValid: state.hasMinLength,
                            ),
                            SizedBox(height: 8.h),
                            _buildValidationCheckItem(
                              text: 'حرف كابيتال واحد على الأقل (A-Z) ',
                              isValid: state.hasCapitalLetter,
                            ),
                            SizedBox(height: 8.h),
                            _buildValidationCheckItem(
                              text: 'رقم واحد على الأقل (0-9)',
                              isValid: state.hasNumber,
                            ),
                            SizedBox(height: 8.h),
                            _buildValidationCheckItem(
                              text: 'رمز خاص واحد على الأقل (!@#) ',
                              isValid: state.hasSpecialChar,
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text('تأكيد كلمة السر',
                        style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black)),
                    SizedBox(height: 8.h),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextFormField(
                        controller: _passwordController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textAlign: TextAlign.right,
                        obscureText: _isConfirmPasswordObscured,
                        decoration: InputDecoration(
                          hintText: 'من فضلك دخل كلمه السر مره تانيه للتأكيد',
                          hintStyle: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              color: const Color(0xFF727070),
                              fontWeight: FontWeight.w400),
                          prefixIcon: const Icon(
                            Iconsax.lock,
                            color: Color(0xFF727070),
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF727070),
                              size: 18.r,
                            ),
                            onPressed: () => setState(() =>
                                _isConfirmPasswordObscured =
                                    !_isConfirmPasswordObscured),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2DFDF))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  const BorderSide(color: Color(0xFF3775FA))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2DFDF))),
                          contentPadding: EdgeInsets.all(12.r),
                          errorStyle: TextStyle(
                            fontSize: 11.sp,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'من فضلك دخل كلمه السر مره تانيه للتأكيد';
                          }
                          if (!RegExp(
                                  r'''^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[~!@#$%^&*()_\-+=\[\]{}|\\:;"<>,.?/`'])(?=.{10,})''')
                              .hasMatch(value)) {
                            return 'كلمة السر لازم تحتوي على حرف كبير، رقم، رمز وطولها 10 أحرف على الأقل';
                          }
                          if (value.length > 32) {
                            return 'كلمة السر لازم تكون أقل من 32 حرف';
                          }
                          if (value != _password) return 'كلمة السر مش متطابقة';
                          return null;
                        },
                      ),
                    ),
                  ])),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: BlocBuilder<TechnicianRegistrationCubit,
                TechnicianRegistrationState>(
              builder: (context, state) {
                final isLoading = state is TechnicianRegLoading;
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
                          : Text('سجل دخولك',
                              style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500)),
                    ));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              Text('لو عندك حساب تقدر تعمل',
                  style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      color: const Color(0xFF727070),
                      fontWeight: FontWeight.w400)),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    SlideRightRouteWithBuild(
                      builder: (context) => BlocProvider(
                        create: (context) => LoginCubit(
                            authRepository: context.read<AuthRepository>()),
                        child: LoginPage(),
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: Text('تسجيل دخول ؟',
                    style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: const Color(0xFF3775FA),
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildValidationCheckItem(
    {required String text, required bool isValid}) {
  final Color color = isValid ? Colors.green : Colors.grey.shade600;
  return Row(
    textDirection: TextDirection.rtl,
    children: [
      Icon(
        isValid ? Icons.check_circle : Icons.error_outline,
        color: color,
        size: 12.r,
      ),
      SizedBox(width: 8.w),
      Text(
        text,
        style: GoogleFonts.cairo(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}