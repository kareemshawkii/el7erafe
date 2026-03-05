// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/cubit/tech_profile_cubit.dart';
import 'package:el7erafe/features/technician_flow/tech_profile/presentation/cubit/tech_profile_state.dart';

String hashedEmail = "";

class TechUpdateProfilePage extends StatefulWidget {
  final String initialName;
  final String currentImageUrl;
  final String token;
  final String initialAboutMe;
  final List<String> initialPortfolioImages;

  const TechUpdateProfilePage({
    super.key,
    required this.initialName,
    required this.currentImageUrl,
    required this.token,
    this.initialAboutMe = "",
    this.initialPortfolioImages = const [],
  });

  @override
  State<TechUpdateProfilePage> createState() => _TechUpdateProfilePageState();
}

class _TechUpdateProfilePageState extends State<TechUpdateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneDisplayController = TextEditingController();
  final TextEditingController _emailDisplayController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  final _mainFormKey = GlobalKey<FormState>();

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  List<String> _existingPortfolioImages = [];
  final List<File> _newPortfolioImages = [];
  final List<String> _deletedPortfolioImages = [];

  final Color _primaryBlue = const Color(0xFF3775FA);
  final Color _textBlack = Colors.black;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _aboutMeController.text = widget.initialAboutMe;
    _existingPortfolioImages = List.from(widget.initialPortfolioImages);
    _loadStoredContactData();
  }

  Future<void> _loadStoredContactData() async {
    final email = await AuthLocalStorage().getEmail() ?? "";
    final phone = await AuthLocalStorage().getPhoneNumber() ?? "";
    if (mounted) {
      setState(() {
        _emailDisplayController.text = email;
        _phoneDisplayController.text = phone;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneDisplayController.dispose();
    _emailDisplayController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<File> _compressImage(File file) async {
    int size = file.lengthSync();
    if (size <= 1024 * 1024) return file;

    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
    );

    return result != null ? File(result.path) : file;
  }

  Future<void> _pickImage(ImageSource source,
      {required bool isProfileImage}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        File originalFile = File(image.path);
        File compressedFile = await _compressImage(originalFile);
        if (compressedFile.lengthSync() == 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "حدث خطأ أثناء معالجة الصورة. الرجاء المحاولة مرة أخرى.",
                  textDirection: TextDirection.rtl),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        setState(() {
          if (isProfileImage) {
            _pickedImage = compressedFile;
          } else {
            if (_existingPortfolioImages.length + _newPortfolioImages.length <
                20) {
              _newPortfolioImages.add(compressedFile);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('الحد الأقصى هو 20 صورة',
                      textDirection: TextDirection.rtl),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء اختيار الصورة',
              textDirection: TextDirection.rtl),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceSheet(BuildContext context,
      {required bool isProfileImage}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading:
                    Icon(Icons.photo_camera, color: Colors.black, size: 24.r),
                title: Text('الكاميرا ',
                    style: TextStyle(color: Colors.black, fontSize: 14.sp)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera,
                      isProfileImage: isProfileImage);
                },
              ),
              Divider(height: 1.h),
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: Colors.black, size: 24.r),
                title: Text('المعرض ',
                    style: TextStyle(color: Colors.black, fontSize: 14.sp)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery,
                      isProfileImage: isProfileImage);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageGallery(BuildContext context) {
    final List<dynamic> allImages = [
      ..._existingPortfolioImages,
      ..._newPortfolioImages
    ];

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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                    ),
                    itemCount: allImages.length,
                    itemBuilder: (context, index) {
                      final item = allImages[index];
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
                          child: item is String
                              ? CachedNetworkImage(
                                  imageUrl: item,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.w),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(Icons.broken_image,
                                        color: Colors.grey, size: 40.r),
                                  ),
                                )
                              : Image.file(
                                  item as File,
                                  fit: BoxFit.cover,
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

  void _showSensitiveUpdateSheet(BuildContext ctx, {required bool isForPhone}) {
    ctx.read<TechProfileCubit>().resetUpdateFlowState(widget.currentImageUrl);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (dbContext) {
        return BlocProvider.value(
          value: ctx.read<TechProfileCubit>(),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(dbContext).viewInsets.bottom),
            child: _SensitiveUpdateFlowSheet(
              token: widget.token,
              isForPhone: isForPhone,
              currentImageUrl: widget.currentImageUrl,
            ),
          ),
        );
      },
    ).then((_) {
      if (ctx.mounted) {
        ctx
            .read<TechProfileCubit>()
            .resetUpdateFlowState(widget.currentImageUrl);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _primaryBlue,
        appBar: AppBar(
          backgroundColor: _primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.r),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "تعديل الملف الشخصي",
            style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22.sp),
          ),
          centerTitle: true,
        ),
        body: BlocListener<TechProfileCubit, TechProfileState>(
          listener: (context, state) {
            if (state is FieldUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message,
                    style: GoogleFonts.cairo(),
                    textDirection: TextDirection.rtl),
                backgroundColor: Colors.green,
              ));

              if (state.newName != null) _nameController.text = state.newName!;
              if (state.newPhone != null) {
                _phoneDisplayController.text = state.newPhone!;
                AuthLocalStorage().savePhoneNumber(state.newPhone!);
              }
              if (state.newEmail != null) {
                _emailDisplayController.text = state.newEmail!;
                AuthLocalStorage().saveEmail(state.newEmail!);
              }
              if (state.newImageUrl != null) {
                setState(() => _pickedImage = null);
                AuthLocalStorage().saveUserProfileImage(state.newImageUrl!);
              }
              Navigator.pop(context);
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message,
                    style: GoogleFonts.cairo(),
                    textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
              ));
            }
          },
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3.w),
                        ),
                        child: ClipOval(
                          child: _pickedImage != null
                              ? Image.file(_pickedImage!, fit: BoxFit.cover)
                              : BlocBuilder<TechProfileCubit, TechProfileState>(
                                  builder: (context, state) {
                                    String imageToDisplay =
                                        widget.currentImageUrl;
                                    if (state is ProfileLoaded &&
                                        state.imageUrl.isNotEmpty) {
                                      imageToDisplay = state.imageUrl;
                                    }

                                    if (imageToDisplay.isNotEmpty) {
                                      return Image.network(
                                        imageToDisplay,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }

                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          );
                                        },
                                      );
                                    }
                                    return const Icon(Icons.person,
                                        size: 60, color: Colors.grey);
                                  },
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showImageSourceSheet(context,
                              isProfileImage: true),
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Icon(Icons.edit,
                                color: _primaryBlue, size: 20.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
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
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Form(
                    key: _mainFormKey,
                    child: Container(
                      height: 560.h,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 30.h),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            Container(
                              padding: EdgeInsets.all(16.r),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("الاسم"),
                                  _buildTextField(
                                    _nameController,
                                    Icons.person_outline,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'من فضلك دخل اسمك الثنائي';
                                      }
                                      if (!RegExp(
                                              r'^([A-Za-z\u0600-\u06FF\s]+)$')
                                          .hasMatch(value)) {
                                        return 'الاسم لازم يكون حروف عربية أو إنجليزية فقط';
                                      }
                                      if (!RegExp(
                                              r'^[A-Za-z\u0600-\u06FF]+\s+[A-Za-z\u0600-\u06FF]+$')
                                          .hasMatch(value)) {
                                        return 'الرجاء إدخال الاسم الأول والأخير (مثال: كريم شوقي)';
                                      }
                                      if (value.length < 3 ||
                                          value.length > 50) {
                                        return 'الاسم لازم يكون بين 3 و 50 حرف';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildLabel("اكتب نبذه عنك"),
                                  _buildAboutMeField(widget.initialName),
                                  SizedBox(height: 16.h),
                                  _buildPortfolioSection(),
                                  SizedBox(height: 16.h),
                                  _buildLabel("رقم التلفون"),
                                  _buildReadOnlyFieldWithChangeAction(
                                    controller: _phoneDisplayController,
                                    icon: Icons.phone_android_outlined,
                                    onChangeTap: () {
                                      _showSensitiveUpdateSheet(context,
                                          isForPhone: true);
                                    },
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildLabel("البريد الالكتروني"),
                                  _buildReadOnlyFieldWithChangeAction(
                                    controller: _emailDisplayController,
                                    icon: Icons.email_outlined,
                                    onChangeTap: () {
                                      _showSensitiveUpdateSheet(context,
                                          isForPhone: false);
                                    },
                                  ),
                                  SizedBox(height: 24.h),
                                  BlocBuilder<TechProfileCubit,
                                      TechProfileState>(
                                    builder: (context, state) {
                                      bool isLoading =
                                          state is ProfileBasicUpdateLoading;
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 56.h,
                                        child: ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  if (_mainFormKey.currentState!
                                                      .validate()) {
                                                    String currentName =
                                                        _nameController.text
                                                            .trim();
                                                    String nameToSend =
                                                        (currentName ==
                                                                widget
                                                                    .initialName)
                                                            ? ""
                                                            : currentName;

                                                    if (nameToSend.isEmpty &&
                                                        _pickedImage == null &&
                                                        _newPortfolioImages
                                                            .isEmpty &&
                                                        _deletedPortfolioImages
                                                            .isEmpty &&
                                                        _aboutMeController.text
                                                                .trim() ==
                                                            widget
                                                                .initialAboutMe) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              "لم تقم بإجراء أي تعديلات",
                                                              textDirection:
                                                                  TextDirection
                                                                      .rtl),
                                                          backgroundColor:
                                                              Colors.grey,
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    context
                                                        .read<
                                                            TechProfileCubit>()
                                                        .updateBasicInfo(
                                                          token: widget.token,
                                                          name: nameToSend,
                                                          aboutMe: (_aboutMeController
                                                                      .text
                                                                      .trim()
                                                                      .isEmpty ||
                                                                  _aboutMeController
                                                                          .text
                                                                          .trim() ==
                                                                      widget
                                                                          .initialAboutMe)
                                                              ? ""
                                                              : _aboutMeController
                                                                  .text
                                                                  .trim(),
                                                          profileImage:
                                                              _pickedImage,
                                                          newPortfolioImages:
                                                              _newPortfolioImages,
                                                          deletedPortfolioImages:
                                                              _deletedPortfolioImages,
                                                          currentPortfolioCount:
                                                              _existingPortfolioImages
                                                                  .length,
                                                        );
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: _primaryBlue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                              side: BorderSide(
                                                  color: _primaryBlue),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: isLoading
                                              ? CircularProgressIndicator(
                                                  color: _primaryBlue)
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons.save_outlined),
                                                    SizedBox(width: 8.w),
                                                    Text("حفظ التعديلات",
                                                        style:
                                                            GoogleFonts.cairo(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    16.sp)),
                                                  ],
                                                ),
                                        ),
                                      );
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
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
      child: Text(text,
          style: GoogleFonts.cairo(
              fontSize: 14.sp, fontWeight: FontWeight.bold, color: _textBlack)),
    );
  }

  Widget _buildAboutMeField(String name) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: TextFormField(
        controller: _aboutMeController,
        style: GoogleFonts.cairo(color: _textBlack),
        maxLength: 200,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: "أنا $name، عندي أكثر من 8 سنين خبرة...",
          hintStyle: GoogleFonts.cairo(color: Colors.grey, fontSize: 12.sp),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: _primaryBlue, width: 1.w),
          ),
          counterStyle: GoogleFonts.cairo(fontSize: 12.sp, color: _primaryBlue),
        ),
      ),
    );
  }

  Widget _buildPortfolioSection() {
    final int totalImages =
        _existingPortfolioImages.length + _newPortfolioImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("اضف صور لشغلك السابق"),
        Container(
          height: 104.h,
          width: double.infinity,
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300, width: 1.w),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: totalImages + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: () {
                    if (totalImages >= 20) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('الحد الأقصى هو 20 صورة',
                                textDirection: TextDirection.rtl),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    _showImageSourceSheet(context, isProfileImage: false);
                  },
                  child: Container(
                    width: 100.w,
                    margin: EdgeInsets.only(left: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: const Color(0xFF3775FA).withOpacity(0.3),
                          width: 1.w),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline,
                            color: const Color(0xFF3775FA), size: 28.r),
                        SizedBox(height: 4.h),
                        Text("إضافة صورة",
                            style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: const Color(0xFF3775FA),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }

              int imgIndex = index - 1;
              dynamic imageItem;
              bool isNetwork = imgIndex < _existingPortfolioImages.length;

              if (isNetwork) {
                imageItem = _existingPortfolioImages[imgIndex];
              } else {
                imageItem = _newPortfolioImages[
                    imgIndex - _existingPortfolioImages.length];
              }

              return Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageGallery(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: isNetwork
                            ? CachedNetworkImage(
                                imageUrl: imageItem,
                                height: 104.h,
                                width: 100.w,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: Colors.grey.shade200),
                                errorWidget: (context, url, error) => Container(
                                    color: Colors.grey.shade200,
                                    child:
                                        Icon(Icons.error, color: Colors.grey)))
                            : Image.file(imageItem,
                                height: 104.h, width: 100.w, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isNetwork) {
                              String url = _existingPortfolioImages[imgIndex];
                              String exactFilename =
                                  Uri.parse(url).pathSegments.last;
                              _deletedPortfolioImages.add(exactFilename);
                              _existingPortfolioImages.removeAt(imgIndex);
                            } else {
                              _newPortfolioImages.removeAt(
                                  imgIndex - _existingPortfolioImages.length);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ],
                          ),
                          child:
                              Icon(Icons.close, color: Colors.red, size: 16.r),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon, {
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.cairo(color: _textBlack),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          hintText: "ادخل النص المطلوب",
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20.r),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: _primaryBlue, width: 1.w),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          errorStyle: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildReadOnlyFieldWithChangeAction({
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onChangeTap,
  }) {
    String maskData(String data) {
      if (data.isEmpty) return "";

      if (data.contains('@')) {
        final parts = data.split('@');
        final name = parts[0];
        final domain = parts.length > 1 ? "@${parts[1]}" : "";

        if (name.length <= 2) return data;
        hashedEmail = '${name.substring(0, 2)}****$domain';
        return '${name.substring(0, 2)}****$domain';
      } else {
        if (data.length <= 4) return data;

        return '${'*' * (data.length - 5)}${data.substring(0, 5)}';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade100.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade300)),
          child: TextField(
            controller: TextEditingController(text: maskData(controller.text)),
            readOnly: true,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(color: Colors.grey.shade700),
            decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.grey, size: 20.r),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h)),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(top: 8.h, left: 8.w),
            child: GestureDetector(
                onTap: onChangeTap,
                child: Text("تغيير",
                    style: GoogleFonts.cairo(
                        color: _primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp))),
          ),
        )
      ],
    );
  }
}

class _SensitiveUpdateFlowSheet extends StatefulWidget {
  final String token;
  final bool isForPhone;
  final String currentImageUrl;
  const _SensitiveUpdateFlowSheet({
    required this.token,
    required this.isForPhone,
    required this.currentImageUrl,
  });

  @override
  State<_SensitiveUpdateFlowSheet> createState() =>
      _SensitiveUpdateFlowSheetState();
}

class _SensitiveUpdateFlowSheetState extends State<_SensitiveUpdateFlowSheet> {
  final _otpController = TextEditingController();
  final _newValueController = TextEditingController();
  final _confirmValueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _currentEmail = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? email = await AuthLocalStorage().getEmail();
      if (mounted) {
        setState(() {
          _currentEmail = email ?? "";
        });

        context.read<TechProfileCubit>().sendFirstOtp(
              widget.token,
              _currentEmail,
              isForPhone: widget.isForPhone,
            );
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newValueController.dispose();
    _confirmValueController.dispose();
    super.dispose();
  }

  String get _hashedEmail {
    if (_currentEmail.isEmpty || !_currentEmail.contains("@")) {
      return _currentEmail;
    }
    final parts = _currentEmail.split("@");
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return "***@$domain";
    return "${name.substring(0, 2)}***@$domain";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final state = context.read<TechProfileCubit>().state;
        if (state is ProfileLoaded) Navigator.of(context).pop();
      },
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: BlocConsumer<TechProfileCubit, TechProfileState>(
          listener: (context, state) {
            if (state is FieldUpdateSuccess) {
              Navigator.pop(context);
            } else if (state is FirstOtpSent) {
              _otpController.clear();
            } else if (state is FirstOtpVerified || state is NewEmailOtpSent) {
              _otpController.clear();
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return SizedBox(
                  height: 200.h,
                  child: const Center(
                      child: CircularProgressIndicator(
                    color: Color(0xFF3775FA),
                  )));
            }
            if (state is ProfileError) {
              return _buildErrorUI(context, state.message);
            }
            if (state is FirstOtpSent) {
              return _buildCurrentOtpStep(context, _hashedEmail);
            }
            if (state is FirstOtpVerified) {
              return _buildNewInputFieldsStep(context);
            }
            if (state is NewEmailOtpSent) {
              return _buildNewOtpStep(context);
            }
            return SizedBox(
                height: 200.h,
                child: const Center(
                    child: CircularProgressIndicator(
                  color: Color(0xFF3775FA),
                )));
          },
        ),
      ),
    );
  }

  Widget _buildNewInputFieldsStep(BuildContext context) {
    String label =
        widget.isForPhone ? "رقم الهاتف الجديد" : "البريد الإلكتروني الجديد";
    IconData icon =
        widget.isForPhone ? Icons.phone_android : Icons.email_outlined;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("إدخال البيانات الجديدة",
              style: GoogleFonts.cairo(
                  fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 20.h),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D))),
          SizedBox(height: 8.h),
          _buildValidatedTextField(_newValueController, icon,
              isPhone: widget.isForPhone),
          SizedBox(height: 16.h),
          Text("تأكيد $label",
              style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D))),
          SizedBox(height: 8.h),
          _buildValidatedTextField(_confirmValueController, icon,
              isPhone: widget.isForPhone,
              confirmController: _newValueController),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: () {
                      context
                          .read<TechProfileCubit>()
                          .resetUpdateFlowState(widget.currentImageUrl);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        side: BorderSide(color: Colors.grey.shade400)),
                    child: Text("إلغاء",
                        style: GoogleFonts.cairo(
                            color: Colors.grey.shade700,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.isForPhone) {
                          context.read<TechProfileCubit>().finalizePhoneChange(
                              widget.token, _newValueController.text);
                        } else {
                          context.read<TechProfileCubit>().sendOtpToNewEmail(
                              widget.token, _newValueController.text);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3775FA),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r))),
                    child: Text(widget.isForPhone ? "حفظ" : "إرسال رمز التحقق",
                        style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNewOtpStep(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("التحقق من البريد الجديد",
            style: GoogleFonts.cairo(
                fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        Text("تم إرسال رمز تحقق إلى البريد الإلكتروني الجديد: ",
            style: GoogleFonts.cairo(color: Colors.grey.shade700)),
        SizedBox(height: 8.h),
        Text(_newValueController.text,
            style: GoogleFonts.cairo(
                color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
        SizedBox(height: 24.h),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade300)),
          child: TextField(
            controller: _otpController,
            style: GoogleFonts.cairo(color: const Color(0xFF2D2D2D)),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              hintText: "أدخل رمز التحقق الجديد",
              hintStyle: GoogleFonts.cairo(),
              prefixIcon:
                  Icon(Icons.lock_outline, color: Colors.grey, size: 20.r),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
        ),
        SizedBox(height: 32.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50.h,
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<TechProfileCubit>()
                        .resetUpdateFlowState(widget.currentImageUrl);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      side: BorderSide(color: Colors.grey.shade400)),
                  child: Text("إلغاء",
                      style: GoogleFonts.cairo(
                          color: Colors.grey.shade700,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
                child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  if (_otpController.text.isNotEmpty) {
                    context.read<TechProfileCubit>().verifyNewEmail(
                          widget.token,
                          _newValueController.text,
                          _otpController.text,
                        );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3775FA),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r))),
                child: Text("تأكيد وتحديث",
                    style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
              ),
            ))
          ],
        ),
      ],
    );
  }

  Widget _buildErrorUI(BuildContext context, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 50.r),
        SizedBox(height: 16.h),
        Text(message,
            style: GoogleFonts.cairo(color: Colors.red),
            textAlign: TextAlign.center),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<TechProfileCubit>()
                        .resetUpdateFlowState(widget.currentImageUrl);
                    Navigator.pop(context);
                  },
                  child: Text("إلغاء",
                      style: GoogleFonts.cairo(color: Colors.grey))),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    context.read<TechProfileCubit>().sendFirstOtp(
                          widget.token,
                          _currentEmail,
                          isForPhone: widget.isForPhone,
                        );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3775FA)),
                  child: Text("إعادة المحاولة",
                      style: GoogleFonts.cairo(color: Colors.white))),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCurrentOtpStep(BuildContext context, String hashedEmail) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("التحقق من الهوية",
            style: GoogleFonts.cairo(
                fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        Text("تم إرسال رمز تحقق إلى بريدك الإلكتروني الحالي: ",
            style: GoogleFonts.cairo(color: Colors.grey.shade700)),
        SizedBox(height: 8.h),
        Text(hashedEmail,
            style: GoogleFonts.cairo(
                color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300, width: 0),
          ),
          child: TextField(
            controller: _otpController,
            style: GoogleFonts.cairo(color: const Color(0xFF2D2D2D)),
            cursorColor: const Color(0xFF3775FA),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              hintText: "أدخل رمز التحقق",
              hintStyle: GoogleFonts.cairo(),
              prefixIcon:
                  Icon(Icons.lock_outline, color: Colors.grey, size: 20.r),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: Color(0xFF3775FA))),
            ),
          ),
        ),
        SizedBox(height: 32.h),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50.h,
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<TechProfileCubit>()
                        .resetUpdateFlowState(widget.currentImageUrl);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      side: BorderSide(color: Colors.grey.shade400)),
                  child: Text("إلغاء",
                      style: GoogleFonts.cairo(
                          color: Colors.grey.shade700,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_otpController.text.isNotEmpty) {
                      context.read<TechProfileCubit>().verifyFirstOtp(
                            widget.token,
                            _currentEmail,
                            _otpController.text,
                            isForPhone: widget.isForPhone,
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3775FA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r))),
                  child: Text("تحقق",
                      style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildValidatedTextField(
      TextEditingController controller, IconData icon,
      {required bool isPhone, TextEditingController? confirmController}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.cairo(color: const Color(0xFF2D2D2D)),
      keyboardType: isPhone ? TextInputType.phone : TextInputType.emailAddress,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: isPhone
              ? "أدخل رقم الهاتف الجديد"
              : "أدخل البريد الإلكتروني الجديد",
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey, size: 20.r),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Color(0xFF3775FA))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h)),
      validator: (value) {
        if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
        if (confirmController != null && value != confirmController.text) {
          return "القيم غير متطابقة";
        }

        if (isPhone) {
          if (value.length < 11 || value.length > 11) {
            return "رقم الهاتف غير صحيح";
          }
        } else {
          if (!value.contains('@') || !value.contains('.')) {
            return "البريد الإلكتروني غير صحيح";
          }
        }
        return null;
      },
    );
  }
}
