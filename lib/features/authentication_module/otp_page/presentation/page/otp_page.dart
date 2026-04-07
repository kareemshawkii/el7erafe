import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/client_flow/client_home/presentation/pages/client_home_page.dart';
import 'package:el7erafe/features/authentication_module/otp_page/data/Repository/otp_repository.dart';
import 'package:el7erafe/features/authentication_module/otp_page/presentation/cubit/otp_cubit.dart';
import 'package:el7erafe/features/authentication_module/otp_page/presentation/cubit/otp_state.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpPage extends StatelessWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpCubit(
        otpRepository: RepositoryProvider.of<OtpRepository>(context),
      ),
      child: OtpView(email: email),
    );
  }
}

class OtpView extends StatefulWidget {
  final String email;
  const OtpView({super.key, required this.email});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  String _enteredOtp = "";

  void _onOtpPressed() {
    FocusScope.of(context).unfocus();
    if (_enteredOtp.length == 6) {
      context.read<OtpCubit>().otpAuth(
            widget.email,
            _enteredOtp,
          );
    } else {
      ModernSnackbar.showError(
          context: context,
          message: "الرجاء إدخال رمز التحقق المكون من 6 أرقام");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<OtpCubit, OtpState>(
        listener: (context, state) {
          if (state is OtpFailure) {
            ModernSnackbar.showError(context: context, message: state.error);
          }
          if (state is OtpSuccess) {
            ModernSnackbar.showSuccess(
                context: context, message: "تم تفعيل الحساب بنجاح");
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(builder: (_) => const ClientHomePage()),
              (route) => false,
            );
          }
          if (state is OtpResent) {
            ModernSnackbar.showSuccess(
                context: context, message: "تم إعادة إرسال كود التحقق بنجاح");
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
                            BlocBuilder<OtpCubit, OtpState>(
                              builder: (context, state) {
                                final isLoading = state is OtpLoading;
                                return Container(
                                    width: double.infinity,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFF3775FA),
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
                                        .read<OtpCubit>()
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
