// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/data/repositories/tech_profile_repo.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/cubit/tech_profile_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/cubit/tech_profile_state.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/pages/update_tech_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TechProfilePage extends StatelessWidget {
  final String? name;
  final String? token;

  const TechProfilePage({super.key, required this.name, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TechProfileCubit(TechProfileRepository())
        ..loadProfile(token ?? "", name ?? "مستخدم"),
      child: TechProfilePageView(name: name, token: token),
    );
  }
}

class TechProfilePageView extends StatefulWidget {
  final String? name;
  final String? token;
  const TechProfilePageView({super.key, this.name, this.token});

  @override
  State<TechProfilePageView> createState() => _TechProfilePageViewState();
}

class _TechProfilePageViewState extends State<TechProfilePageView> {
  bool _notificationsEnabled = false;
  String userName = "مستخدم";
  String _displayImage = "";
  String _aboutMe = "";
  List<String> _portfolioImages = [];
  bool _hasFetchedProfileOnce = false;
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
      SlideRightRouteWithBuild(
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
                context
                    .read<TechProfileCubit>()
                    .deleteAccount(widget.token ?? "");
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
    String? storedImage = await AuthLocalStorage().getUserProfileImage();
    if (mounted) {
      setState(() {
        userName = storedName ?? widget.name ?? "مستخدم";
        if (storedImage != null && storedImage.isNotEmpty) {
          _displayImage = storedImage;
        }
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
                context.read<TechProfileCubit>().logout(widget.token ?? "");
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
    return BlocConsumer<TechProfileCubit, TechProfileState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) return;
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
        if (state is ProfileLoaded) {
          _displayImage = state.imageUrl;
          if (state.profile != null) {
            _hasFetchedProfileOnce = true;
            _aboutMe = state.profile!.aboutMe ?? "";
            _portfolioImages = state.profile!.portfolioImages;
            userName = state.profile!.name;
          }
        }
        bool showWarning = _hasFetchedProfileOnce &&
            (_aboutMe.isEmpty || _portfolioImages.isEmpty);

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
                      top: 50.h,
                    ),
                    color: _primaryBlue,
                    width: double.infinity,
                    height: 300.h,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              width: 100.w,
                              height: 100.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border:
                                    Border.all(color: Colors.white, width: 4.w),
                              ),
                              child: ClipOval(
                                child: _displayImage.isEmpty
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : Image.network(
                                        _displayImage,
                                        fit: BoxFit.cover,
                                        width: 100.w,
                                        height: 100.h,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: _primaryBlue,
                                              strokeWidth: 3,
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              userName,
                              style: GoogleFonts.cairo(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 200.h, 
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
                          child: child,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12.h),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final profileCubit =
                                            context.read<TechProfileCubit>();
                                        await Navigator.push(
                                          context,
                                          SlideRightRouteWithBuild(
                                            builder: (context) =>
                                                BlocProvider.value(
                                              value: profileCubit,
                                              child: TechUpdateProfilePage(
                                                initialName: userName,
                                                currentImageUrl: _displayImage,
                                                token: widget.token ?? "",
                                                initialAboutMe: _aboutMe,
                                                initialPortfolioImages:
                                                    _portfolioImages,
                                              ),
                                            ),
                                          ),
                                        );
                                        if (_displayImage.isNotEmpty) {
                                          await NetworkImage(_displayImage)
                                              .evict();
                                        }
                                        await _loadLocalData();
                                        profileCubit.loadProfile(
                                            widget.token ?? "", userName);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF4C85FB),
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 24.w, vertical: 8.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                      ),
                                      icon: Icon(Icons.edit,
                                          color: Colors.white, size: 16.r),
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
                              SizedBox(height: 24.h),
                              if (showWarning)
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 8.h),
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3CD),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                        color: const Color(0xFFFFC107)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: const Color(0xFFFF8F00),
                                          size: 24.r),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          "أكمل بياناتك! إضافة نبذة عنك وصور لشغلك بيزود فرصتك في الحصول على طلبات أكتر.",
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF856404),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (showWarning) SizedBox(height: 8.h),
                              if (_aboutMe.isNotEmpty) ...[
                                _buildAboutMeSection(_aboutMe),
                                SizedBox(height: 16.h),
                              ],
                              if (_portfolioImages.isNotEmpty) ...[
                                _buildPortfolioSection(
                                    context, _portfolioImages),
                                SizedBox(height: 16.h),
                              ],
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20.w),
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryBlue.withOpacity(0.1),
                                      blurRadius: 10.r,
                                      offset: Offset(0, 4.h),
                                    ),
                                  ],
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 1.w),
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingItem(
                                      icon: Icons.notifications_none_outlined,
                                      title: "الإشعارات",
                                      subtitle:
                                          "اختار لو تحب توصلك تنبيهات عن الحجوزات أو العروض",
                                      trailing: SizedBox(
                                        width: 50.w,
                                        height: 20.h,
                                        child: Switch(
                                          value: _notificationsEnabled,
                                          activeThumbColor: _primaryBlue,
                                          onChanged: (val) => setState(() =>
                                              _notificationsEnabled = val),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                        height: 1.h,
                                        indent: 60.w,
                                        endIndent: 20.w),
                                    _buildSettingItem(
                                      icon: Icons.help_outline,
                                      title: "محتاج مساعدة؟",
                                      subtitle: "اعرف حقوقك وحقوق الحرفيين",
                                      trailing: Icon(Icons.arrow_forward_ios,
                                          size: 16.r, color: Colors.grey),
                                      onTap: () {},
                                    ),
                                    Divider(
                                        height: 1.h,
                                        indent: 60.w,
                                        endIndent: 20.w),
                                    _buildSettingItem(
                                      icon: Icons.description_outlined,
                                      title: "الشروط والأحكام",
                                      subtitle:
                                          "تواصل مع فريق الدعم لأي مشكلة أو استفسار",
                                      trailing: Icon(Icons.arrow_forward_ios,
                                          size: 16.r, color: Colors.grey),
                                      onTap: () {},
                                    ),
                                    Divider(
                                        height: 1.h,
                                        indent: 60.w,
                                        endIndent: 20.w),
                                    _buildSettingItem(
                                      icon: Icons.logout,
                                      title: "حذف الحساب",
                                      subtitle:
                                          "احذف حسابك وجميع بياناتك نهائياً",
                                      onTap: () {
                                        _onDeleteAccountPressed(context);
                                      },
                                    ),
                                    Divider(
                                        height: 1.h,
                                        indent: 60.w,
                                        endIndent: 20.w),
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
                              SizedBox(height: 30.h),
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
        );
      },
    );
  }

  Widget _buildAboutMeSection(String aboutText) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "نبذة عنك",
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border:
                  Border.all(color: Colors.grey.withOpacity(0.3), width: 1.w),
            ),
            child: Text(
              aboutText,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection(BuildContext context, List<String> images) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "صور لشغلك السابق",
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border:
                  Border.all(color: Colors.grey.withOpacity(0.3), width: 1.w),
            ),
            child: SizedBox(
              height: 60.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showImageGallery(context, images),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: images[index],
                        width: 80.w,
                        height: 60.h,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (context, url, error) => Container(
                          width: 80.w,
                          color: Colors.grey.shade200,
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageGallery(BuildContext context, List<String> images) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            insetPadding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "معرض الأعمال",
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: Colors.black54, size: 20.r),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: GridView.builder(
                    padding:
                        EdgeInsets.only(left: 16.w, right: 16.w, bottom: 24.h),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFF3775FA).withOpacity(0.5),
                            width: 1.w,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.w),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey, size: 40.r),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: (iconColor ?? _primaryBlue).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? _primaryBlue, size: 20.r),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: titleColor ?? _textBlack,
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: 11.sp,
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