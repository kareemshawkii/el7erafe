import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/otp_forget_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/email_input_cubit.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/email_input_state.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/forget_otp_cubit.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/pages/forget_otp_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
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
              MaterialPageRoute(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: (136 / 852) * screenHeight,
                            width: (147 / 393) * screenWidth,
                            child: Image.asset('images/email_input.png',
                                fit: BoxFit.fill),
                          ),
                          SizedBox(height: (32 / 852) * screenHeight),
                          Text(
                            'نسيت كلمه السر ؟',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3775FA),
                            ),
                          ),
                          Text(
                            'اكتب البريد الالكتروني اللي سجلت بيه',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF000000),
                            ),
                          ),
                          SizedBox(height: (32 / 852) * screenHeight),
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
                                    size: 18,
                                  ),
                                  hintText: 'name@domain.com',
                                  hintStyle: GoogleFonts.cairo(
                                      fontSize: 15,
                                      color: const Color(0xFF727070),
                                      fontWeight: FontWeight.w400),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2DFDF))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF3775FA))),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2DFDF))),
                                  contentPadding: EdgeInsets.all(12),
                                  errorStyle: TextStyle(
                                    fontSize: 11,
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
                          SizedBox(height: (24 / 852) * screenHeight),
                          SizedBox(
                            width: double.infinity,
                            height: (40 / 852) * screenHeight,
                            child:
                                BlocBuilder<EmailInputCubit, EmailInputState>(
                              builder: (context, state) {
                                final isLoading = state is EmailInputLoading;
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
                                                BorderRadius.circular(12.0),
                                            side: const BorderSide(
                                                color: Colors.white,
                                                width: 1.0)),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                  color: Color(0xFF3775FA),
                                                  strokeWidth: 3),
                                            )
                                          : Text('ارسال',
                                              style: GoogleFonts.cairo(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
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
            ],
          ),
        ),
      ),
    );
  }
}
