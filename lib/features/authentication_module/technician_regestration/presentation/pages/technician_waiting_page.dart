import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/techincian_registration_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_resubmit_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_waiting_page_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/technician_waititng_page_state.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/pages/technician_resubmit_page.dart';
import 'package:el7erafe/technician.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class TechnicianWaitingPage extends StatelessWidget {
  const TechnicianWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TechnicianRegistrationCubit(
            technicianRegRepository:
                RepositoryProvider.of<TechnicianRegRepository>(context),
          ),
        ),
      ],
      child: const TechnicianWaitingView(),
    );
  }
}

class TechnicianWaitingView extends StatefulWidget {
  const TechnicianWaitingView({super.key});

  @override
  State<TechnicianWaitingView> createState() => _TechnicianWaitingViewState();
}

class _TechnicianWaitingViewState extends State<TechnicianWaitingView> {
  @override
  void initState() {
    super.initState();
    context.read<TechnicianStatusCubit>().checkApprovalStatus();
  }

  void _onReloadPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<TechnicianStatusCubit>().checkApprovalStatus();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<TechnicianStatusCubit, TechnicianStatusState>(
        listener: (context, state) async {
          if (state is TechnicianStatusDenied) {
            if (state.status == "تحت المراجعة") {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(state.message, textDirection: TextDirection.rtl),
                  backgroundColor: Colors.blue,
                ),
              );
            } else if (state.status == "مرفوض") {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(state.message, textDirection: TextDirection.rtl),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => TechnicianResubmitCubit(
                      technicianRegRepository:
                          RepositoryProvider.of<TechnicianRegRepository>(
                              context),
                    ),
                    child: const TechnicianResubmitPage(),
                  ),
                ),
                (route) => false,
              );
              AuthLocalStorage authStorage = AuthLocalStorage();
              await authStorage.deleteTempToken();
            }
          } else if (state is TechnicianStatusBlocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => LoginCubit(
                    authRepository:
                        RepositoryProvider.of<AuthRepository>(context),
                  ),
                  child: const LoginPage(),
                ),
              ),
              (route) => false,
            );
            AuthLocalStorage authStorage = AuthLocalStorage();
            await authStorage.deleteTempToken();
          } else if (state is TechnicianStatusApproved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'تم قبول حسابك كحرفي متحمسين نشوف نجاحك بالتوفيق.',
                    textDirection: TextDirection.rtl),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const TechnicianPage()),
              (route) => false,
            );
            AuthLocalStorage authStorage = AuthLocalStorage();
            await authStorage.deleteTempToken();
          } else if (state is TechnicianStatusError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
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
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('images/technician_waiting.png',
                            width: (241 / 393) * screenWidth,
                            height: (361 / 852) * screenHeight),
                        SizedBox(height: (24 / 852) * screenHeight),
                        Directionality(
                            textDirection: TextDirection.rtl,
                            child: Center(
                              child: Text(
                                'شكراً لتسجيلك كحرفي! طلبك بيتراجع دلوقتي ، وهنرد عليك خلال 24 ساعة.',
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF000000),
                                ),
                              ),
                            )),
                        SizedBox(height: (18 / 852) * screenHeight),
                        SizedBox(
                          height: (40 / 852) * screenHeight,
                          width: (264 / 393) * screenWidth,
                          child: BlocBuilder<TechnicianStatusCubit,
                              TechnicianStatusState>(
                            builder: (context, state) {
                              final isLoading =
                                  state is TechnicianStatusLoading;
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
                                        : () => _onReloadPressed(context),
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
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('اعاده تحميل الصفحه',
                                                  style: GoogleFonts.cairo(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              SizedBox(
                                                  width:
                                                      (8 / 393) * screenWidth),
                                              Icon(Icons.refresh,
                                                  color: Colors.white,
                                                  size:
                                                      (24 / 393) * screenWidth),
                                            ],
                                          ),
                                  ));
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
