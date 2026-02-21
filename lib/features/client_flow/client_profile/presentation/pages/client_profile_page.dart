import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/client_flow/client_profile/data/repositories/client_profile_repo.dart';
import 'package:el7erafe/features/client_flow/client_profile/presentation/cubit/client_profile_cubit.dart';
import 'package:el7erafe/features/client_flow/client_profile/presentation/cubit/client_profile_state.dart';
import 'package:el7erafe/features/client_flow/client_profile/presentation/pages/update_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClientProfilePage extends StatelessWidget {
   final String? name;
   final String? token;

   const ClientProfilePage({super.key, required this.name, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(ProfileRepository())
        ..loadProfile(token ?? "", name ?? "مستخدم"),
      child: ClientProfilePageView(name: name, token: token),
    );
  }
}

class ClientProfilePageView extends StatefulWidget {
   final String? name;
  final String? token;
   const ClientProfilePageView({super.key, this.name, this.token});

  @override
  State<ClientProfilePageView> createState() => _ClientProfilePageViewState();
}

class _ClientProfilePageViewState extends State<ClientProfilePageView> {
  bool _notificationsEnabled = false;
  String userName = "مستخدم";

  final Color _primaryBlue = const Color(0xFF3775FA);
  final Color _bgGrey = const Color(0xFFF5F7FA);
  final Color _textBlack = const Color(0xFF2D2D2D);
  final Color _textGrey = const Color(0xFF9E9E9E);
  final Color _dangerRed = const Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  void _navigateToLogin(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => LoginCubit(authRepository: AuthRepository()),
          child: const LoginPage(),
        ),
      ),
      (route) => false,
    );
  }

  void _onDeleteAccountPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shadowColor: Colors.black45,
          title: Text("حذف الحساب",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(
            "هل أنت متأكد أنك تريد حذف حسابك نهائياً؟ لا يمكن التراجع عن هذا الإجراء.",
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
                  Text("إلغاء", style: GoogleFonts.cairo(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ProfileCubit>().deleteAccount(widget.token ?? "");
              },
              child: Text("حذف",
                  style: GoogleFonts.cairo(
                      color: _dangerRed, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadLocalData() async {
    String? storedName = await AuthLocalStorage().getUserName();
    if (mounted) {
      setState(() {
        userName = storedName ?? widget.name ?? "مستخدم";
      });
    }
  }

  void _onLogoutPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shadowColor: Colors.black45,
          title: Text("تسجيل الخروج",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(
            "هل أنت متأكد أنك تريد تسجيل الخروج؟",
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child:
                  Text("إلغاء", style: GoogleFonts.cairo(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ProfileCubit>().logout(widget.token ?? "");
              },
              child: Text("خروج",
                  style: GoogleFonts.cairo(
                      color: _dangerRed, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUnauth) {
          _navigateToLogin(context, state.message);
        } else if (state is ProfileActionSuccess) {
          _navigateToLogin(context, state.message);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, textDirection: TextDirection.rtl),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        String displayImage = "";
        if (state is ProfileLoaded) {
          displayImage = state.imageUrl;
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: _bgGrey,
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: (50 / 852) * screenHeight,
                    ),
                    color: _primaryBlue,
                    width: screenWidth,
                    height: (300 / 852) * screenHeight,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: ClipOval(
                              child: displayImage.isEmpty
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: displayImage,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: _primaryBlue,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Name
                          Text(
                            userName,
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular((44 / 852) * screenHeight),
                      topRight: Radius.circular((44 / 852) * screenHeight),
                    ),
                    child: Container(
                      height: (560 / 852) * screenHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFDFD),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular((44 / 852) * screenHeight),
                          topRight: Radius.circular((44 / 852) * screenHeight),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final profileCubit =
                                          context.read<ProfileCubit>();
                                      await Navigator.push(
                                        context,
                                        SlideRightRouteWithBuild(
                                          builder: (context) =>
                                              BlocProvider.value(
                                            value: profileCubit,
                                            child: ClientUpdateProfilePage(
                                              initialName: userName,
                                              currentImageUrl: displayImage,
                                              token: widget.token ?? "",
                                            ),
                                          ),
                                        ),
                                      );
                                      await _loadLocalData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4C85FB),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white, size: 16),
                                    label: Text(
                                      "عدل ملفك الشخصي",
                                      style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: _primaryBlue.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                    // ignore: deprecated_member_use
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 1),
                              ),
                              child: Column(
                                children: [
                                  _buildSettingItem(
                                    icon: Icons.notifications_none_outlined,
                                    title: "الإشعارات",
                                    subtitle:
                                        "اختار لو تحب توصلك تنبيهات عن الحجوزات أو العروض",
                                    trailing: SizedBox(
                                      width: 30,
                                      height: 20,
                                      child: Switch(
                                        value: _notificationsEnabled,
                                        activeThumbColor: _primaryBlue,
                                        onChanged: (val) => setState(
                                            () => _notificationsEnabled = val),
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                      height: 1, indent: 60, endIndent: 20),
                                  _buildSettingItem(
                                    icon: Icons.help_outline,
                                    title: "محتاج مساعدة؟",
                                    subtitle: "اعرف حقوقك وحقوق الحرفيين",
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey),
                                    onTap: () {},
                                  ),
                                  const Divider(
                                      height: 1, indent: 60, endIndent: 20),
                                  _buildSettingItem(
                                    icon: Icons.description_outlined,
                                    title: "الشروط والأحكام",
                                    subtitle:
                                        "تواصل مع فريق الدعم لأي مشكلة أو استفسار",
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey),
                                    onTap: () {},
                                  ),
                                  const Divider(
                                      height: 1, indent: 60, endIndent: 20),
                                  _buildSettingItem(
                                    icon: Icons.logout,
                                    title: "حذف الحساب",
                                    subtitle:
                                        "احذف حسابك وجميع بياناتك نهائياً",
                                    onTap: () {
                                      _onDeleteAccountPressed(context);
                                    },
                                  ),
                                  const Divider(
                                      height: 1, indent: 60, endIndent: 20),
                                  _buildSettingItem(
                                    icon: Icons.logout,
                                    title: "تسجيل الخروج",
                                    subtitle: "اخرج من الحساب بأمان",
                                    iconColor: _dangerRed,
                                    titleColor: _dangerRed,
                                    onTap: () {
                                      _onLogoutPressed(context);
                                    },
                                  ),
                                ],
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
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: (iconColor ?? _primaryBlue).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? _primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: titleColor ?? _textBlack,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: _textGrey,
            height: 1.3,
          ),
        ),
      ),
      trailing: trailing,
    );
  }
}
