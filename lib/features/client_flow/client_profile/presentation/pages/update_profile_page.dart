import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/features/client_flow/client_profile/presentation/cubit/client_profile_cubit.dart';
import 'package:el7erafe/features/client_flow/client_profile/presentation/cubit/client_profile_state.dart';

String hashedEmail = "";

class ClientUpdateProfilePage extends StatefulWidget {
  final String initialName;
  final String currentImageUrl;
  final String token;

  const ClientUpdateProfilePage({
    super.key,
    required this.initialName,
    required this.currentImageUrl,
    required this.token,
  });

  @override
  State<ClientUpdateProfilePage> createState() =>
      _ClientUpdateProfilePageState();
}

class _ClientUpdateProfilePageState extends State<ClientUpdateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneDisplayController = TextEditingController();
  final TextEditingController _emailDisplayController = TextEditingController();
  final _mainFormKey = GlobalKey<FormState>();

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  final Color _primaryBlue = const Color(0xFF3775FA);
  final Color _textBlack = Colors.black;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _loadStoredContactData();
  }

  Future<void> _loadStoredContactData() async {
    final email = await AuthLocalStorage().getEmail() ??
        ""; 
    final phone = await AuthLocalStorage().getPhoneNumber() ??
        "";
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
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  void _showSensitiveUpdateSheet(BuildContext ctx, {required bool isForPhone}) {
    ctx.read<ProfileCubit>().resetUpdateFlowState(widget.currentImageUrl);

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
          value: ctx.read<ProfileCubit>(),
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
      // ignore: use_build_context_synchronously
      ctx.read<ProfileCubit>().resetUpdateFlowState(widget.currentImageUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _primaryBlue,
        appBar: AppBar(
          backgroundColor: _primaryBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "تعديل الملف الشخصي",
            style: GoogleFonts.cairo(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: BlocListener<ProfileCubit, ProfileState>(
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
                AuthLocalStorage()
                    .savePhoneNumber(state.newPhone!); // Update local storage
              }
              if (state.newEmail != null) {
                _emailDisplayController.text = state.newEmail!;
                AuthLocalStorage()
                    .saveEmail(state.newEmail!); // Update local storage
              }
              if (state.newImageUrl != null) {
                setState(() => _pickedImage = null);
                AuthLocalStorage().saveUserProfileImage(
                    state.newImageUrl!); // Update local storage
              }
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
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : BlocBuilder<ProfileCubit, ProfileState>(
                                builder: (context, state) {
                                  String imageToDisplay =
                                      widget.currentImageUrl;
                                  if (state is ProfileLoaded &&
                                      state.imageUrl.isNotEmpty) {
                                    imageToDisplay = state.imageUrl;
                                  }

                                  if (imageToDisplay.isNotEmpty) {
                                    return CachedNetworkImage(
                                      imageUrl: imageToDisplay,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(
                                              color: Colors.white),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.person,
                                              size: 60, color: Colors.grey),
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
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child:
                              Icon(Icons.edit, color: _primaryBlue, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                  child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Form(
                  key: _mainFormKey,
                  child: Container(
                    height: (560 / 852) * screenHeight,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                              padding: const EdgeInsets.all(16),
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
                                  const SizedBox(height: 12),
                                  _buildLabel("رقم التلفون"),
                                  _buildReadOnlyFieldWithChangeAction(
                                    controller: _phoneDisplayController,
                                    icon: Icons.phone_android_outlined,
                                    onChangeTap: () =>
                                        _showSensitiveUpdateSheet(context,
                                            isForPhone: true),
                                  ),
                                  _buildLabel("البريد الالكتروني"),
                                  _buildReadOnlyFieldWithChangeAction(
                                    controller: _emailDisplayController,
                                    icon: Icons.email_outlined,
                                    onChangeTap: () =>
                                        _showSensitiveUpdateSheet(context,
                                            isForPhone: false),
                                  ),
                                  const SizedBox(height: 24),
                                  BlocBuilder<ProfileCubit, ProfileState>(
                                    builder: (context, state) {
                                      bool isLoading =
                                          state is ProfileBasicUpdateLoading;
                                      return SizedBox(
                                        width: double.infinity,
                                        height: 56,
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
                                                        _pickedImage == null) {
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
                                                        .read<ProfileCubit>()
                                                        .updateBasicInfo(
                                                          widget.token,
                                                          nameToSend,
                                                          _pickedImage,
                                                        );
                                                  }
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: _primaryBlue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
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
                                                    const SizedBox(width: 8),
                                                    Text("حفظ التعديلات",
                                                        style:
                                                            GoogleFonts.cairo(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16)),
                                                  ],
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )),
                        ],
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
      padding: const EdgeInsets.only(bottom: 8.0, right: 4),
      child: Text(text,
          style: GoogleFonts.cairo(
              fontSize: 14, fontWeight: FontWeight.bold, color: _textBlack)),
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
        borderRadius: BorderRadius.circular(16),
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
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primaryBlue, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          errorStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.red),
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
              // ignore: deprecated_member_use
              color: Colors.grey.shade100.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300)),
          child: TextField(
            controller: TextEditingController(text: maskData(controller.text)),
            readOnly: true,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.cairo(color: Colors.grey.shade700),
            decoration: InputDecoration(
                prefixIcon: Icon(icon, color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
            child: GestureDetector(
                onTap: onChangeTap,
                child: Text("تغيير",
                    style: GoogleFonts.cairo(
                        color: _primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14))),
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
  const _SensitiveUpdateFlowSheet(
      {required this.token,
      required this.isForPhone,
      required this.currentImageUrl});

  @override
  State<_SensitiveUpdateFlowSheet> createState() =>
      _SensitiveUpdateFlowSheetState();
}

class _SensitiveUpdateFlowSheetState extends State<_SensitiveUpdateFlowSheet> {
  final _otpController = TextEditingController();
  final _newValueController = TextEditingController();
  final _confirmValueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? currentEmail = await AuthLocalStorage().getEmail();
      if (mounted) {
        context.read<ProfileCubit>().initiateSensitiveChange(
              widget.token,
              isForPhone: widget.isForPhone,
              email: currentEmail ?? "",
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (didPop) return;
        final state = context.read<ProfileCubit>().state;
        if (state is ProfileLoaded) Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is FieldUpdateSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'تم تحديث ${widget.isForPhone ? "رقم الهاتف" : "البريد الإلكتروني"} بنجاح',
                    style: GoogleFonts.cairo(),
                    textDirection: TextDirection.rtl),
                backgroundColor: Colors.green,
              ));
            } else if (state is SensitiveChangeOtpSent) {
              _otpController.clear();
            } else if (state is SensitiveChangeCurrentVerified ||
                state is NewEmailOtpSent) {
              _otpController.clear();
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const SizedBox(
                  height: 200,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Color(0xFF3775FA),
                  )));
            }
            if (state is ProfileError) {
              return _buildErrorUI(context, state.message);
            }
            if (state is SensitiveChangeOtpSent) {
              return _buildCurrentOtpStep(context, state.hashedEmail); 
            }
            if (state is SensitiveChangeCurrentVerified) {
              return _buildNewInputFieldsStep(context);
            }
            if (state is NewEmailOtpSent) {
              return _buildNewOtpStep(context);
            }
            return const SizedBox(
                height: 200,
                child: Center(
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
              style:
                  GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D))),
          const SizedBox(height: 8),
          _buildValidatedTextField(_newValueController, icon,
              isPhone: widget.isForPhone),
          const SizedBox(height: 16),
          Text("تأكيد $label",
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D))),
          const SizedBox(height: 8),
          _buildValidatedTextField(_confirmValueController, icon,
              isPhone: widget.isForPhone,
              confirmController: _newValueController),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      context
                          .read<ProfileCubit>()
                          .resetUpdateFlowState(widget.currentImageUrl);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade400)),
                    child: Text("إلغاء",
                        style: GoogleFonts.cairo(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.isForPhone) {
                          context.read<ProfileCubit>().finalizePhoneChange(
                              widget.token,
                              _newValueController.text);
                        } else {
                          context.read<ProfileCubit>().sendOtpToNewEmail(
                              widget.token, _newValueController.text);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3775FA),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text(widget.isForPhone ? "حفظ" : "إرسال رمز التحقق",
                        style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
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
            style:
                GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text("تم إرسال رمز تحقق إلى البريد الإلكتروني الجديد: ",
            style: GoogleFonts.cairo(color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Text(_newValueController.text,
            style: GoogleFonts.cairo(
                color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300)),
          child: TextField(
            controller: _otpController,
            style: GoogleFonts.cairo(color: const Color(0xFF2D2D2D)),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
              hintText: "أدخل رمز التحقق الجديد",
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (_otpController.text.isNotEmpty) {
                context.read<ProfileCubit>().confirmNewEmail(
                    widget.token,
                    _otpController.text,
                    _newValueController.text,
                    isForPhone: false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3775FA),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text("تأكيد وتحديث",
                style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget _buildErrorUI(BuildContext context, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 50),
        const SizedBox(height: 16),
        Text(message,
            style: GoogleFonts.cairo(color: Colors.red),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<ProfileCubit>()
                        .resetUpdateFlowState(widget.currentImageUrl);
                    Navigator.pop(context);
                  },
                  child: Text("إلغاء",
                      style: GoogleFonts.cairo(color: Colors.grey))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                  onPressed: () async {
                    String? currentEmail = await AuthLocalStorage().getEmail();
                    if (context.mounted) {
                      context.read<ProfileCubit>().initiateSensitiveChange(
                            widget.token,
                            isForPhone: widget.isForPhone,
                            email: currentEmail ?? "",
                          );
                    }
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
            style:
                GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text("تم إرسال رمز تحقق إلى بريدك الإلكتروني الحالي: ",
            style: GoogleFonts.cairo(color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Text(hashedEmail,
            style: GoogleFonts.cairo(
                color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
            decoration: const InputDecoration(
              hintText: "أدخل رمز التحقق",
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: Color(0xFF3775FA))),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    context
                        .read<ProfileCubit>()
                        .resetUpdateFlowState(widget.currentImageUrl);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade400)),
                  child: Text("إلغاء",
                      style: GoogleFonts.cairo(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_otpController.text.isNotEmpty) {
                      String? currentEmail = await AuthLocalStorage().getEmail();
                      if (context.mounted) {
                        context.read<ProfileCubit>().verifyCurrentEmailOtp(
                            widget.token, _otpController.text, currentEmail ?? "",
                            isForPhone: widget.isForPhone);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3775FA),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text("تحقق",
                      style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16,
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
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF3775FA))),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
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
