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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) async {
          if (state is ResetPasswordInvalid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage, textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is ResetPasswordValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تغيير كلمة السر بنجاح', textDirection: TextDirection.rtl),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
              builder: (context) => BlocProvider(
              create: (context) =>
                LoginCubit(
                  authRepository: RepositoryProvider.of<AuthRepository>(context),
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
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: EdgeInsets.only(top: (68/852)*screenHeight,bottom: (68/852)*screenHeight),
                  color: const Color(0xFF3775FA),
                  width: screenWidth,
                  height: (267/852)*screenHeight,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child:  SizedBox(
                    height: (131/852)*screenHeight,
                    width: (131/393)*screenWidth,
                    child: Image.asset('images/Logo.png', fit: BoxFit.fill),
                  ),
                  )
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: (629/852)*screenHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDFDFD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(44),
                      topRight: Radius.circular(44),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB((16/393)*screenWidth, (44/852)*screenHeight , (16/393)*screenWidth, (44/852)*screenHeight + keyboardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                         height: (136/852)*screenHeight,
                         width: (147/393)*screenWidth,
                         child: Image.asset('images/email_input.png', fit: BoxFit.fill),
                        ),
                        SizedBox(height: (32/852)*screenHeight),
                        Text(
                          'اكتب كلمه السر الجديده',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3775FA),
                          ),
                        ),
                        SizedBox(height: (32/852)*screenHeight),
                        Form(
                           key: _formKey,
                           autovalidateMode: AutovalidateMode.onUserInteraction,
                          child:Directionality(
                          textDirection: TextDirection.rtl,
                          child: Column(
                            children:[
                              Directionality(textDirection: TextDirection.rtl, 
                              child: TextFormField(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  textAlign: TextAlign.right,
                                  obscureText: _isPasswordObscured,
                                  decoration: InputDecoration(
                                    hintText: 'من فضلك دخل كلمه السر',
                                    hintStyle: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF727070),fontWeight: FontWeight.w400),
                                    prefixIcon: const Icon(Iconsax.lock, color: Color(0xFF727070),size: 18,),
                                    suffixIcon: IconButton(
                                        icon: Icon(_isPasswordObscured ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF727070),size: 18,),
                                        onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                                    ),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3775FA))),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                                    contentPadding: EdgeInsets.all(12),
                                    errorStyle: TextStyle(
                                    fontSize: 11, 
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'من فضلك دخل كلمة السر';
                                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{10,})').hasMatch(value)) {
                                      return 'كلمة السر لازم تحتوي على حرف كبير، رقم، رمز وطولها 10 أحرف على الأقل';
                                    }
                                    if (value.length > 32) return 'كلمة السر لازم تكون أقل من 32 حرف';
                                    return null;
                                  },
                                  onChanged: (val){
                                    _password = val;
                                    context.read<PasswordStrengthCubit>().validatePassword(val);
                                  },
                              ),
                              ),
                              SizedBox(height: (12/852)*screenHeight),
                              Directionality(textDirection: TextDirection.rtl, 
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'كلمه السر لازم تحتوي على التالي:',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              )
                              ),
                              SizedBox(height: (12/852)*screenHeight),
                              BlocBuilder<PasswordStrengthCubit, PasswordStrengthState>(
                                    builder: (context, state) {
                                      return Column(
                                        children: [
                                          _buildValidationCheckItem(
                                            text: '١٠ حروف أو أكثر',
                                            isValid: state.hasMinLength,
                                          ),
                                          SizedBox(height: (8/852)*screenHeight),
                                          _buildValidationCheckItem(
                                            text: '(A-Z) حرف كابيتال واحد على الأقل ',
                                            isValid: state.hasCapitalLetter,
                                          ),
                                          SizedBox(height: (8/852)*screenHeight),
                                          _buildValidationCheckItem(
                                            text: 'رقم واحد على الأقل (0-9)',
                                            isValid: state.hasNumber,
                                          ),
                                          SizedBox(height: (8/852)*screenHeight),
                                          _buildValidationCheckItem(
                                            text: '(!@#) رمز خاص واحد على الأقل ',
                                            isValid: state.hasSpecialChar,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                              SizedBox(height: (16/852)*screenHeight),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: TextFormField(
                                    controller: _passwordController,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    textAlign: TextAlign.right,
                                    obscureText: _isConfirmPasswordObscured,
                                    decoration: InputDecoration(
                                      hintText: 'من فضلك دخل كلمه السر مره تانيه للتأكيد',
                                      hintStyle: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF727070),fontWeight: FontWeight.w400),
                                      prefixIcon: const Icon(Iconsax.lock, color: Color(0xFF727070),size: 18,),
                                      suffixIcon: IconButton(
                                          icon: Icon(_isConfirmPasswordObscured ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF727070),size: 18,),
                                          onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
                                      ),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3775FA))),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2DFDF))),
                                      contentPadding: EdgeInsets.all(12),
                                      errorStyle: TextStyle(
                                      fontSize: 11, 
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'من فضلك دخل كلمه السر مره تانيه للتأكيد';
                                      if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])(?=.{10,})').hasMatch(value)) {
                                        return 'كلمة السر لازم تحتوي على حرف كبير، رقم، رمز وطولها 10 أحرف على الأقل';
                                      }
                                      if (value.length > 32) return 'كلمة السر لازم تكون أقل من 32 حرف';
                                      if (value != _password) return 'كلمة السر مش متطابقة';
                                      return null;
                                    },
                                ),
                              ),
                            ] 
                          )
                        ),
                        ),
            SizedBox(height: (24/852)*screenHeight),
            SizedBox(
            width: double.infinity,
            height: (40/852)*screenHeight,
            child: BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
              builder: (context, state) {
                final isLoading = state is ResetPasswordLoading;
                return Container (
                  width: double.infinity,
                          height: (40/852)*screenHeight,
                          decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Color(0xFF3775FA), 
                            width: 1.0,
                          ),
                        ),   
                              child:ElevatedButton(
                              onPressed: isLoading ? null : () => _onSendPressed(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3775FA),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color.fromARGB(158, 55, 117, 250),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0), side: const BorderSide(color: Colors.white, width: 1.0)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Color(0xFF3775FA), strokeWidth: 3),
                                    )
                                  : Text('تأكيد كلمه السر الجديده', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500)),
                            )
                            );
                          },
                        ),
                      ),
                      ],
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

Widget _buildValidationCheckItem({required String text, required bool isValid}) {
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