import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/otp_forget_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/reset_password_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/forget_otp_cubit.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/forget_otp_state.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/reset_password_cubit.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/pages/reset_password_page.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
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
              MaterialPageRoute(
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
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                    padding: EdgeInsets.only(
                        top: (68 / 852) * screenHeight,
                        bottom: (68 / 852) * screenHeight),
                    color: const Color(0xFF3775FA),
                    width: screenWidth,
                    height: (267 / 852) * screenHeight,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: (131 / 852) * screenHeight,
                        width: (131 / 393) * screenWidth,
                        child: Image.asset('images/Logo.png', fit: BoxFit.fill),
                      ),
                    )),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(44),
                    topRight: Radius.circular(44),
                  ),
                  child: Container(
                    height: (629 / 852) * screenHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDFDFD),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(44),
                        topRight: Radius.circular(44),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                          (16 / 393) * screenWidth,
                          (44 / 852) * screenHeight,
                          (16 / 393) * screenWidth,
                          (44 / 852) * screenHeight + keyboardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Center(
                              child: SizedBox(
                            height: (136 / 852) * screenHeight,
                            width: (182 / 393) * screenWidth,
                            child:
                                Image.asset('images/otp.png', fit: BoxFit.fill),
                          )),
                          SizedBox(height: (32 / 852) * screenHeight),
                          Center(
                            child: Text(
                              'أدخل رمز التحقق',
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                          ),
                          SizedBox(height: (8 / 852) * screenHeight),
                          Center(
                            child: Text(
                              'أدخل الكود المرسل على بريدك لإكمال العملية',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B6B6B),
                              ),
                            ),
                          ),
                          SizedBox(height: (24 / 852) * screenHeight),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: OtpTextField(
                              numberOfFields: 6,
                              fieldWidth: (50 / 393) * screenWidth,
                              fieldHeight: (50 / 852) * screenHeight,
                              borderColor: const Color(0xFF3775FA),
                              enabledBorderColor: const Color(0xFFE2DFDF),
                              focusedBorderColor: const Color(0xFF3775FA),
                              borderRadius: BorderRadius.circular(12.0),
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
                          SizedBox(height: (24 / 852) * screenHeight),
                          BlocBuilder<ForgetOtpCubit, ForgetOtpState>(
                            builder: (context, state) {
                              final isLoading = state is ForgetOtpLoading;
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
                                    onPressed: isLoading ? null : _onOtpPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3775FA),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          const Color.fromARGB(
                                              158, 55, 117, 250),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          side: const BorderSide(
                                              color: Colors.white, width: 1.0)),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                                color: Color(0xFF3775FA),
                                                strokeWidth: 3),
                                          )
                                        : Text('تحقق',
                                            style: GoogleFonts.cairo(
                                                fontSize: 16,
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
                                      fontSize: 14,
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
                                        fontSize: 14,
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
            ],
          ),
        ),
      ),
    );
  }
}
