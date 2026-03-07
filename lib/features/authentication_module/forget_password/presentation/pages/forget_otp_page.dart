import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/otp_forget_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/reset_password_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/forget_otp_cubit.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/forget_otp_state.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/reset_password_cubit.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/pages/reset_password_page.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgetOtpPage extends StatelessWidget {
  final String email;
  const ForgetOtpPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgetOtpCubit(
        otpForgetRepository:
            RepositoryProvider.of<OtpForgetRepository>(context),
      ),
      child: ForgetOtpView(email: email),
    );
  }
}

class ForgetOtpView extends StatefulWidget {
  final String email;
  const ForgetOtpView({super.key, required this.email});

  @override
  State<ForgetOtpView> createState() => _ForgetOtpViewState();
}

class _ForgetOtpViewState extends State<ForgetOtpView> {
  String _enteredOtp = "";

  void _onOtpPressed() {
    FocusScope.of(context).unfocus();
    if (_enteredOtp.length == 6) {
      context.read<ForgetOtpCubit>().otpAuth(
            widget.email,
            _enteredOtp,
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال الرمز المكون من 6 أرقام',
              textDirection: TextDirection.rtl),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<ForgetOtpCubit, ForgetOtpState>(
        listener: (context, state) {
          if (state is ForgetOtpFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is ForgetOtpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم التحقق من الرمز بنجاح',
                    textDirection: TextDirection.rtl),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                builder: (context) => BlocProvider(
                  create: (context) => ResetPasswordCubit(
                    resetPasswordRepository:
                        RepositoryProvider.of<ResetPasswordRepository>(context),
                  ),
                  child: ResetPasswordPage(),
                ),
              ),
              (route) => false,
            );
          }
          if (state is ForgetOtpResent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إعادة إرسال رمز التحقق بنجاح',
                    textDirection: TextDirection.rtl),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF3775FA),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 250.h,
                child: Center(
                  child: SizedBox(
                    height: 150.h,
                    width: 150.w,
                    child: Image.asset('images/Logo.png', fit: BoxFit.fill),
                  ),
                ),
              ),
              Positioned(
                top: 230.h,
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(44.r),
                    topRight: Radius.circular(44.r),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 200 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFDFD),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(44.r),
                          topRight: Radius.circular(44.r),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                            16.w, 44.h, 16.w, 44.h + keyboardPadding),
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Center(
                                child: SizedBox(
                              height: 136.h,
                              width: 182.w,
                              child: Image.asset('images/otp.png',
                                  fit: BoxFit.fill),
                            )),
                            SizedBox(height: 32.h),
                            Center(
                              child: Text(
                                'أدخل رمز التحقق',
                                style: GoogleFonts.cairo(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Center(
                              child: Text(
                                'أدخل الكود المرسل على بريدك لإكمال العملية',
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6B6B6B),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: OtpTextField(
                                numberOfFields: 6,
                                fieldWidth: 50.w,
                                fieldHeight: 50.h,
                                borderColor: const Color(0xFF3775FA),
                                enabledBorderColor: const Color(0xFFE2DFDF),
                                focusedBorderColor: const Color(0xFF3775FA),
                                borderRadius: BorderRadius.circular(12.r),
                                showFieldAsBox: true,
                                onSubmit: (String verificationCode) {
                                  setState(() {
                                    _enteredOtp = verificationCode;
                                  });
                                },
                                onCodeChanged: (String code) {
                                  setState(() {
                                    _enteredOtp = code;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 24.h),
                            BlocBuilder<ForgetOtpCubit, ForgetOtpState>(
                              builder: (context, state) {
                                final isLoading = state is ForgetOtpLoading;
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
                                      onPressed:
                                          isLoading ? null : _onOtpPressed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF3775FA),
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            const Color.fromARGB(
                                                158, 55, 117, 250),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            side: const BorderSide(
                                                color: Colors.white,
                                                width: 1.0)),
                                      ),
                                      child: isLoading
                                          ? SizedBox(
                                              height: 24.r,
                                              width: 24.r,
                                              child:
                                                  const CircularProgressIndicator(
                                                      color: Color(0xFF3775FA),
                                                      strokeWidth: 3),
                                            )
                                          : Text('تحقق',
                                              style: GoogleFonts.cairo(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500)),
                                    ));
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: TextDirection.rtl,
                              children: [
                                Text('ماوصلكش الكود؟  ابعت طلب',
                                    style: GoogleFonts.cairo(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF727070),
                                        fontWeight: FontWeight.w400)),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<ForgetOtpCubit>()
                                        .resendOtp(widget.email);
                                  },
                                  child: Text('لإعادة الإرسال',
                                      style: GoogleFonts.cairo(
                                          fontSize: 14.sp,
                                          color: const Color(0xFF3775FA),
                                          fontWeight: FontWeight.w400)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
