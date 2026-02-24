import 'package:el7erafe/features/authentication_module/client_regestration/data/repositories/client_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/cubit/client_registration_cubit.dart';
import 'package:el7erafe/features/authentication_module/client_regestration/presentation/pages/client_registration_page.dart';
import 'package:el7erafe/features/authentication_module/select_type/presentation/cubit/select_type_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/data/repositories/technician_registration_repo.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/cubit/techincian_registration_cubit.dart';
import 'package:el7erafe/features/authentication_module/technician_regestration/presentation/pages/technician_registration_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
                padding: EdgeInsets.only(top: 68.h, bottom: 68.h),
                color: const Color(0xFF3775FA),
                width: double.infinity,
                height: 267.h,
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
                  padding: EdgeInsets.fromLTRB(16.w, 44.h, 16.w, 44.h),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('قولنا انت حرفي ولا مستخدم',
                            style: GoogleFonts.cairo(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                        SizedBox(height: 32.h),
                        Text('التصنيف',
                            style: GoogleFonts.cairo(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black)),
                        SizedBox(height: 8.h),
                        BlocBuilder<SelectTypeCubit, UserType>(
                          builder: (context, selection) {
                            return Column(
                              children: [
                                Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: selection == UserType.user
                                          ? const Color(0xFF3775FA)
                                          : Color(0xFFE2DFDF),
                                      width: 1.w,
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
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400)),
                                    leading: _CustomRadioIcon(
                                      isSelected: selection == UserType.user,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: selection == UserType.technician
                                          ? const Color(0xFF3775FA)
                                          : Color(0xFFE2DFDF),
                                      width: 1.w,
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
                                            fontSize: 14.sp,
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
                        SizedBox(height: 24.h),
                        Container(
                            width: double.infinity,
                            height: 40.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Color(0xFF3775FA),
                                width: 1.w,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(1.r),
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
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  'يلا نبدأ',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16.sp,
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
      size: 30.r,
    );
  }
}
