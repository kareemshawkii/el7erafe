import 'dart:convert';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class ClientProfilePage extends StatefulWidget {
  final String? name;
  final String? token;
  const ClientProfilePage({super.key, required this.name, required this.token});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  bool _notificationsEnabled = false;
  late String userName;
  late String userToken;
  late String userImage = "";
  final Color _primaryBlue = const Color(0xFF3775FA);
  final Color _bgGrey = const Color(0xFFF5F7FA);
  final Color _textBlack = const Color(0xFF2D2D2D);
  final Color _textGrey = const Color(0xFF9E9E9E);
  final Color _dangerRed = const Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    userName = widget.name ?? "مستخدم";
    userToken = widget.token!;
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    String fullImageUrl = await AuthLocalStorage().getUserProfileImage() ?? "";
    if (fullImageUrl.isNotEmpty) {
      if (mounted) {
        setState(() {
          userImage = fullImageUrl;
        });
      }
      return;
    }
    final Uri url = Uri.parse(
        'https://el7rafe-gma4hrg0e9epfsc0.uaenorth-01.azurewebsites.net/api/cf/profile');

    final headers = {
      'Authorization': 'Bearer $userToken',
      'Content-Type': 'application/json',
    };
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        await AuthLocalStorage().saveEmail(data['email']);
        await AuthLocalStorage().savePhoneNumber(data['phoneNumber']);
        fullImageUrl = data['imageURL'] ?? "";
        await AuthLocalStorage().saveUserProfileImage(fullImageUrl);
        if (mounted) {
          setState(() {
            userImage = fullImageUrl;
          });
        }
      } else if (response.statusCode == 401) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("جلسة المستخدم انتهت، الرجاء تسجيل الدخول مرة أخرى.",
                textDirection: TextDirection.rtl),
            backgroundColor: Colors.red,
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
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['errorMessage'] ?? "حدث خطأ غير معروف";
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, textDirection: TextDirection.rtl),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "فشل تحميل بيانات الملف الشخصي الرجاء المحاولة مرة اخرى.",
                textDirection: TextDirection.rtl),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "يوجد خطأ في الاتصال بالإنترنت الرجاء التحقق من اتصالك والمحاولة مرة اخرى.",
              textDirection: TextDirection.rtl),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onDeleteAccountPressed() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text("حذف الحساب",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(
            "هل أنت متأكد أنك تريد حذف حسابك نهائياً؟ لا يمكن التراجع عن هذا الإجراء.",
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("إلغاء", style: GoogleFonts.cairo(color: _textGrey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
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
                      top: (50 / 852) * screenHeight,),
                  color: const Color(0xFF3775FA),
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
                              child: userImage.isEmpty
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: userImage,
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
                          const SizedBox(height: 4),
                          Text(
                            userName,
                            style: GoogleFonts.cairo(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ))),
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
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4C85FB),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Color(0xFF3775FA).withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            // ignore: deprecated_member_use
                            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
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
                                )
                              ),
                              const Divider(
                                  height: 1, indent: 60, endIndent: 20),
                              _buildSettingItem(
                                icon: Icons.help_outline,
                                title: "محتاج مساعدة؟",
                                subtitle: "تواصل مع فريق الدعم لأي مشكلة أو استفسار",
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.grey),
                                onTap: () {},
                              ),
                              const Divider(
                                  height: 1, indent: 60, endIndent: 20),
                              _buildSettingItem(
                                icon: Icons.description_outlined,
                                title: "الشروط والأحكام",
                                subtitle:
                                    "اعرف حقوقك وحقوق الحرفيين",
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.grey),
                                onTap: () {},
                              ),
                              const Divider(
                                  height: 1, indent: 60, endIndent: 20),
                            _buildSettingItem(icon: Icons.delete_forever,
                             title: "حذف الحساب",
                            subtitle: "احذف حسابك وجميع بياناتك نهائياً"
                            ,
                            onTap: _onDeleteAccountPressed,
                            ),
                              const Divider(
                                  height: 1, indent: 60, endIndent: 20),
                              _buildSettingItem(
                                icon: Icons.logout,
                                title: "تسجيل الخروج",
                                subtitle: "اخرج من الحساب بأمان",
                                iconColor: _dangerRed,
                                titleColor: _dangerRed,
                                onTap: () {},
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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

