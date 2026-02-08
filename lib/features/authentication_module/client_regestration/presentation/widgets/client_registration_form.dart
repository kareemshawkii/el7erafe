import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/client_registration_cubit.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/client_registration_state.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/password_strength_cubit.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/password_strength_state.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class ClientRegistrationForm extends StatefulWidget {
  const ClientRegistrationForm({super.key});

  @override
  State<ClientRegistrationForm> createState() => _ClientRegistrationFormState();
}

class _ClientRegistrationFormState extends State<ClientRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  String? _password;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<ClientRegistrationCubit>().register(
            _nameController.text,
            _phoneController.text,
            _emailController.text,
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('الاسم',
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black)),
          SizedBox(height: (8 / 852) * screenHeight),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextFormField(
              controller: _nameController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.person_2_outlined,
                  color: Color(0xFF727070),
                  size: 18,
                ),
                hintText: 'ادخل اسمك ثنائي ',
                hintStyle: GoogleFonts.cairo(
                    fontSize: 15,
                    color: const Color(0xFF727070),
                    fontWeight: FontWeight.w400),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3775FA))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                contentPadding: EdgeInsets.all(12),
                errorStyle: TextStyle(
                  fontSize: 11,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'من فضلك دخل اسمك الثنائي';
                }
                if (!RegExp(r'^([A-Za-z\u0600-\u06FF\s]+)$').hasMatch(value)) {
                  return 'الاسم لازم يكون حروف عربية أو إنجليزية فقط';
                }
                if (!RegExp(
                        r'^[A-Za-z\u0600-\u06FF]+\s+[A-Za-z\u0600-\u06FF]+$')
                    .hasMatch(value)) {
                  return 'الرجاء إدخال الاسم الأول والأخير (مثال: كريم شوقي)';
                }
                if (value.length < 3 || value.length > 50) {
                  return 'الاسم لازم يكون بين 3 و 50 حرف';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: (16 / 852) * screenHeight),
          Text('رقم التليفون',
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black)),
          SizedBox(height: (8 / 852) * screenHeight),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextFormField(
              controller: _phoneController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Iconsax.call,
                  color: Color(0xFF727070),
                  size: 18,
                ),
                hintText: '01X XXX XXXX',
                hintStyle: GoogleFonts.cairo(
                    fontSize: 15,
                    color: const Color(0xFF727070),
                    fontWeight: FontWeight.w400),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3775FA))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                contentPadding: EdgeInsets.all(12),
                errorStyle: TextStyle(
                  fontSize: 11,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'من فضلك دخل رقم التليفون';
                }
                if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) {
                  return 'من فضلك دخل رقم التليفون صحيح';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: (16 / 852) * screenHeight),
          Text('البريد الإلكتروني',
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black)),
          SizedBox(height: (8 / 852) * screenHeight),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextFormField(
              controller: _emailController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.email,
                  color: Color(0xFF727070),
                  size: 18,
                ),
                hintText: 'name@domain.com',
                hintStyle: GoogleFonts.cairo(
                    fontSize: 15,
                    color: const Color(0xFF727070),
                    fontWeight: FontWeight.w400),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3775FA))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                contentPadding: EdgeInsets.all(12),
                errorStyle: TextStyle(
                  fontSize: 11,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'من فضلك دخل البريد الإلكتروني';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
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
          SizedBox(height: (16 / 852) * screenHeight),
          Text('كلمة السر',
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black)),
          SizedBox(height: (8 / 852) * screenHeight),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textAlign: TextAlign.right,
              obscureText: _isPasswordObscured,
              decoration: InputDecoration(
                hintText: 'من فضلك دخل كلمه السر',
                hintStyle: GoogleFonts.cairo(
                    fontSize: 13,
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
                    size: 18,
                  ),
                  onPressed: () => setState(
                      () => _isPasswordObscured = !_isPasswordObscured),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3775FA))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                contentPadding: EdgeInsets.all(12),
                errorStyle: TextStyle(
                  fontSize: 11,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'من فضلك دخل كلمة السر';
                }
                if (!RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{10,})')
                    .hasMatch(value)) {
                  return 'كلمة السر لازم تحتوي على حرف كبير، رقم، رمز وطولها 10 أحرف على الأقل';
                }
                if (value.length < 10 || value.length > 32) {
                  return 'كلمة السر لازم تكون بين 10 و 32 حرف';
                }
                return null;
              },
              onChanged: (val) {
                _password = val;
                context.read<PasswordStrengthCubit>().validatePassword(val);
              },
            ),
          ),
          SizedBox(height: (12 / 852) * screenHeight),
          Text(':كلمة السر لازم تحتوي على',
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF727070))),
          SizedBox(height: (12 / 852) * screenHeight),
          BlocBuilder<PasswordStrengthCubit, PasswordStrengthState>(
            builder: (context, state) {
              return Column(
                children: [
                  _buildValidationCheckItem(
                    text: '١٠ حروف أو أكثر',
                    isValid: state.hasMinLength,
                  ),
                  SizedBox(height: (8 / 852) * screenHeight),
                  _buildValidationCheckItem(
                    text: '(A-Z) حرف كابيتال واحد على الأقل ',
                    isValid: state.hasCapitalLetter,
                  ),
                  SizedBox(height: (8 / 852) * screenHeight),
                  _buildValidationCheckItem(
                    text: 'رقم واحد على الأقل (0-9)',
                    isValid: state.hasNumber,
                  ),
                  SizedBox(height: (8 / 852) * screenHeight),
                  _buildValidationCheckItem(
                    text: '(!@#) رمز خاص واحد على الأقل ',
                    isValid: state.hasSpecialChar,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: (16 / 852) * screenHeight),
          Text('تأكيد كلمة السر',
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black)),
          SizedBox(height: (8 / 852) * screenHeight),
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
                    fontSize: 13,
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
                    size: 18,
                  ),
                  onPressed: () => setState(() =>
                      _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3775FA))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                contentPadding: EdgeInsets.all(12),
                errorStyle: TextStyle(
                  fontSize: 11,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'من فضلك دخل كلمه السر مره تانيه للتأكيد';
                }
                if (!RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{10,})')
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
          SizedBox(height: (24 / 852) * screenHeight),
          SizedBox(
            width: double.infinity,
            height: (40 / 852) * screenHeight,
            child:
                BlocBuilder<ClientRegistrationCubit, ClientRegistrationState>(
              builder: (context, state) {
                final isLoading = state is ClientRegLoading;
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
                          : Text('سجل دخولك',
                              style: GoogleFonts.cairo(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
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
                      fontSize: 14,
                      color: const Color(0xFF727070),
                      fontWeight: FontWeight.w400)),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
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
                        fontSize: 14,
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
        size: 12,
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: GoogleFonts.cairo(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}
