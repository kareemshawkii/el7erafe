import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/password_strength_cubit.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/password_strength_state.dart';
import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/reset_password_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/reset_password_cubit.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/reset_password_state.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ResetPasswordCubit(
            resetPasswordRepository:
                RepositoryProvider.of<ResetPasswordRepository>(context),
          ),
        ),
        BlocProvider(
          create: (context) => PasswordStrengthCubit(),
        ),
      ],
      child: const ResetPasswordView(),
    );
  }
}

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordView> {
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  String? _password;

  void _onSendPressed() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<ResetPasswordCubit>().sendPassword(_passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) async {
          if (state is ResetPasswordInvalid) {
            ModernSnackbar.showError(
                context: context, message: state.errorMessage);
          }
          if (state is ResetPasswordValid) {
            ModernSnackbar.showSuccess(
                context: context, message: 'تم تغيير كلمة السر بنجاح');
            Navigator.pushAndRemoveUntil(
              context,
              SlideRightRouteWithBuild(
                builder: (context) => BlocProvider(
                  create: (context) => LoginCubit(
                    authRepository:
                        RepositoryProvider.of<AuthRepository>(context),
                  ),
                  child: LoginPage(),
                ),
              ),
              (route) => false,
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
                              'اكتب كلمه السر الجديده',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3775FA),
                              ),
                            ),
                            SizedBox(height: 32.h),
                            Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Column(children: [
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
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
                                                _isPasswordObscured =
                                                    !_isPasswordObscured),
                                          ),
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
                                    Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'كلمه السر لازم تحتوي على التالي:',
                                            style: GoogleFonts.cairo(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        )),
                                    SizedBox(height: 12.h),
                                    BlocBuilder<PasswordStrengthCubit,
                                        PasswordStrengthState>(
                                      builder: (context, state) {
                                        return Column(
                                          children: [
                                            _buildValidationCheckItem(
                                              text: '١٠ حروف أو أكثر',
                                              isValid: state.hasMinLength,
                                            ),
                                            SizedBox(height: 8.h),
                                            _buildValidationCheckItem(
                                              text:
                                                  'حرف كابيتال واحد على الأقل (A-Z) ',
                                              isValid: state.hasCapitalLetter,
                                            ),
                                            SizedBox(height: 8.h),
                                            _buildValidationCheckItem(
                                              text: 'رقم واحد على الأقل (0-9)',
                                              isValid: state.hasNumber,
                                            ),
                                            SizedBox(height: 8.h),
                                            _buildValidationCheckItem(
                                              text:
                                                  'رمز خاص واحد على الأقل (!@#) ',
                                              isValid: state.hasSpecialChar,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(height: 16.h),
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: TextFormField(
                                        controller: _passwordController,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        textAlign: TextAlign.right,
                                        obscureText: _isConfirmPasswordObscured,
                                        decoration: InputDecoration(
                                          hintText:
                                              'من فضلك دخل كلمه السر مره تانيه للتأكيد',
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
                                          if (value != _password) {
                                            return 'كلمة السر مش متطابقة';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ])),
                            ),
                            SizedBox(height: 24.h),
                            SizedBox(
                              width: double.infinity,
                              height: 40.h,
                              child: BlocBuilder<ResetPasswordCubit,
                                  ResetPasswordState>(
                                builder: (context, state) {
                                  final isLoading =
                                      state is ResetPasswordLoading;
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
                                            : () => _onSendPressed(),
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
                                            : Text('تأكيد كلمه السر الجديده',
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
