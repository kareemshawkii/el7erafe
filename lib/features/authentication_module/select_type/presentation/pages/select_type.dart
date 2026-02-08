import 'package:el7erafe/features/authentication_module/client_regestration/data/repositories/client_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/client_registration_cubit.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/pages/client_registration_page.dart';
import 'package:el7erafe/features/authentication_module/select_type/presentation/cubit/select_type_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/techincian_registration_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/pages/technician_registration_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectTypePage extends StatelessWidget {
  const SelectTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectTypeCubit(),
      child: const SelectTypeView(),
    );
  }
}

class SelectTypeView extends StatelessWidget {
  const SelectTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
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
                    (44 / 852) * screenHeight),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('قولنا انت حرفي ولا مستخدم',
                          style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      SizedBox(height: (32 / 852) * screenHeight),
                      Text('التصنيف',
                          style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black)),
                      SizedBox(height: (8 / 852) * screenHeight),
                      BlocBuilder<SelectTypeCubit, UserType>(
                        builder: (context, selection) {
                          return Column(
                            children: [
                              Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: selection == UserType.user
                                        ? const Color(0xFF3775FA)
                                        : Color(0xFFE2DFDF),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  splashColor: Colors.transparent,
                                  onTap: () => context
                                      .read<SelectTypeCubit>()
                                      .selectType(UserType.user),
                                  title: Text('مستخدم',
                                      style: GoogleFonts.cairo(
                                          color: const Color(0xFF727070),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400)),
                                  leading: _CustomRadioIcon(
                                    isSelected: selection == UserType.user,
                                  ),
                                ),
                              ),
                              SizedBox(height: (8 / 852) * screenHeight),
                              Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: selection == UserType.technician
                                        ? const Color(0xFF3775FA)
                                        : Color(0xFFE2DFDF),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  splashColor: Colors.transparent,
                                  onTap: () => context
                                      .read<SelectTypeCubit>()
                                      .selectType(UserType.technician),
                                  title: Text('حرفي',
                                      style: GoogleFonts.cairo(
                                          color: const Color(0xFF727070),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400)),
                                  leading: _CustomRadioIcon(
                                    isSelected:
                                        selection == UserType.technician,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: (24 / 852) * screenHeight),
                      Container(
                          width: double.infinity,
                          height: (40 / 852) * screenHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Color(0xFF3775FA),
                              width: 1.0,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsetsGeometry.all(1),
                            child: ElevatedButton(
                              onPressed: () {
                                if (context.read<SelectTypeCubit>().state ==
                                    UserType.user) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                        create: (context) =>
                                            ClientRegistrationCubit(
                                                clientRegRepository:
                                                    RepositoryProvider.of<
                                                            ClientRegRepository>(
                                                        context)),
                                        child: const ClientRegistrationPage(),
                                      ),
                                    ),
                                  );
                                } else if (context
                                        .read<SelectTypeCubit>()
                                        .state ==
                                    UserType.technician) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                        create: (context) =>
                                            TechnicianRegistrationCubit(
                                                technicianRegRepository:
                                                    RepositoryProvider.of<
                                                            TechnicianRegRepository>(
                                                        context)),
                                        child:
                                            const TechnicianRegistrationPage(),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3775FA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'يلا نبدأ',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomRadioIcon extends StatelessWidget {
  final bool isSelected;

  const _CustomRadioIcon({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      color: isSelected ? const Color(0xFF3775FA) : Color(0xFFE2DFDF),
      size: 30,
    );
  }
}