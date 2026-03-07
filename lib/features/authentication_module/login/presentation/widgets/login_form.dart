import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/email_input_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/email_input_cubit.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/pages/email_input_page.dart';
import 'package:el7erafe/features/authentication_module/select_type/presentation/cubit/select_type_cubit.dart';
import 'package:el7erafe/features/authentication_module/select_type/presentation/pages/select_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscured = true;
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().login(
            _phoneController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  color: const Color(0xFF727070),
                  size: 18.r,
                ),
                hintText: '01X XXX XXXX',
                hintStyle: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    color: const Color(0xFF727070),
                    fontWeight: FontWeight.w400),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFF3775FA))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
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
          Text('كلمة السر',
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
                  onPressed: () => setState(
                      () => _isPasswordObscured = !_isPasswordObscured),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFF3775FA))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                contentPadding: EdgeInsets.all(12.r),
                errorStyle: TextStyle(
                  fontSize: 11.sp,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'من فضلك دخل كلمة السر';
                }
                if (value.length < 10) {
                  return 'كلمة السر لازم تكون 10 أحرف على الأقل';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            textDirection: TextDirection.rtl,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    SlideRightRouteWithBuild(
                      builder: (context) => BlocProvider(
                        create: (context) => EmailInputCubit(
                            emailInputRepository:
                                RepositoryProvider.of<EmailInputRepository>(
                                    context)),
                        child: const EmailInputPage(),
                      ),
                    ),
                  );
                },
                child: Text('نسيت كلمه السر؟',
                    style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: const Color(0xFF3775FA),
                        fontWeight: FontWeight.w400)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
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
                      onPressed: isLoading ? null : _onLoginPressed,
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
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              Text('لو معندكش حساب تقدر تعمل',
                  style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      color: const Color(0xFF727070),
                      fontWeight: FontWeight.w400)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    SlideRightRouteWithBuild(
                      builder: (context) => BlocProvider(
                        create: (context) => SelectTypeCubit(),
                        child: SelectTypePage(),
                      ),
                    ),
                  );
                },
                child: Text('حساب جديد ؟',
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
