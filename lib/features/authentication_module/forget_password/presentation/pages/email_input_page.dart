import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/otp_forget_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/email_input_cubit.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/email_input_state.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/forget_otp_cubit.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/pages/forget_otp_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailInputPage extends StatelessWidget {
  const EmailInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EmailInputView();
  }
}

class EmailInputView extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  EmailInputView({super.key});

  void _onSendPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<EmailInputCubit>().sendEmail(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<EmailInputCubit, EmailInputState>(
        listener: (context, state) async {
          if (state is EmailInputInvalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(state.errorMessage, textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is EmailInputValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم ارسال كود التحقق الي البريد الإلكتروني بنجاح',
                    textDirection: TextDirection.rtl),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.push(
              context,
              SlideRightRouteWithBuild(
                builder: (context) => BlocProvider(
                  create: (context) => ForgetOtpCubit(
                    otpForgetRepository:
                        RepositoryProvider.of<OtpForgetRepository>(context),
                  ),
                  child: ForgetOtpPage(email: _emailController.text),
                ),
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
                    padding: EdgeInsets.only(top: 68.h, bottom: 68.h),
                    color: const Color(0xFF3775FA),
                    width: double.infinity,
                    height: double.infinity,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: 131.h,
                        width: 131.w,
                        child: Image.asset('images/Logo.png', fit: BoxFit.fill),
                      ),
                    )),
              ),
              Align(
                alignment: Alignment.bottomCenter,
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
                      height: 629.h,
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 136.h,
                              width: 147.w,
                              child: Image.asset('images/email_input.png',
                                  fit: BoxFit.fill),
                            ),
                            SizedBox(height: 32.h),
                            Text(
                              'نسيت كلمه السر ؟',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3775FA),
                              ),
                            ),
                            Text(
                              'اكتب البريد الالكتروني اللي سجلت بيه',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF000000),
                              ),
                            ),
                            SizedBox(height: 32.h),
                            Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: TextFormField(
                                  controller: _emailController,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  textAlign: TextAlign.right,
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
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFE2DFDF))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF3775FA))),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFE2DFDF))),
                                    contentPadding: EdgeInsets.all(12.r),
                                    errorStyle: TextStyle(
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'من فضلك دخل البريد الإلكتروني';
                                    }
                                    if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return 'من فضلك دخل بريد إلكتروني صحيح';
                                    }
                                    if (value.length > 50) {
                                      return 'البريد الإلكتروني لازم يكون أقل من 50 حرف';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            SizedBox(
                              width: double.infinity,
                              height: 40.h,
                              child:
                                  BlocBuilder<EmailInputCubit, EmailInputState>(
                                builder: (context, state) {
                                  final isLoading = state is EmailInputLoading;
                                  return Container(
                                      width: double.infinity,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: Color(0xFF3775FA),
                                          width: 1.w,
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => _onSendPressed(context),
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
                                                        color:
                                                            Color(0xFF3775FA),
                                                        strokeWidth: 3),
                                              )
                                            : Text('ارسال',
                                                style: GoogleFonts.cairo(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                      ));
                                },
                              ),
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
