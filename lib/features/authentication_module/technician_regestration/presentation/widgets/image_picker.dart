import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerButton extends StatefulWidget {
  final String? disabledImage;
  final bool enabled;
  final String defaultImage;
  final double height;
  final double width;
  final void Function(File pickedImage)? onImagePicked;

  const ImagePickerButton({
    super.key,
    required this.defaultImage,
    this.height = 120.0,
    this.width = 120.0,
    this.onImagePicked,
    this.disabledImage,
    this.enabled = true,
  });

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _checkPermissionAndPickImage(ImageSource source) async {
    Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      if (Platform.isAndroid) {
        permission = Permission.photos;
      } else {
        permission = Permission.photos;
      }
    }

    final status = await permission.request();

    if (status.isGranted) {
      _pickImage(source);
    } else if (status.isDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء السماح بالوصول إلى الكاميرا أو المعرض.',
                textDirection: TextDirection.rtl)),
      );
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;
      _showSettingsDialog();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعدادات الإذن مطلوبة',
            textDirection: TextDirection.rtl),
        content: const Text(
          'تم رفض الوصول إلى الكاميرا بشكل دائم. يرجى تمكينه في إعدادات التطبيق لالتقاط الصور.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('الكاميرا'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _checkPermissionAndPickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('المعرض'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        return;
      }

      final String extension = pickedFile.name.split('.').last.toLowerCase();

      if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("من فضلك اختر صورة بصيغة JPG أو PNG فقط.",
                textDirection: TextDirection.rtl),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final int sizeInBytes = await pickedFile.length();
      const int maxSizeInBytes = 1 * 1024 * 1024;

      if (sizeInBytes > maxSizeInBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("حجم الصورة يجب ألا يتجاوز 1 ميجابايت.",
                textDirection: TextDirection.rtl),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (sizeInBytes == 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("الصورة المختارة غير صالحة. من فضلك اختر صورة أخرى.",
                textDirection: TextDirection.rtl),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final File newImageFile = File(pickedFile.path);

      setState(() {
        _pickedImage = newImageFile;
      });

      if (widget.onImagePicked != null) {
        widget.onImagePicked!(newImageFile);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !widget.enabled;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Material(
            color: Colors.grey.shade200,
            child: InkWell(
              onTap: isDisabled ? null : () => _showPickerOptions(context),
              child: _pickedImage != null
                  ? SvgPicture.asset(
                      'images/uploaded.svg',
                      fit: BoxFit.fill,
                      width: widget.width,
                      height: widget.height,
                    )
                  : SvgPicture.asset(
                      isDisabled && widget.disabledImage != null
                          ? widget.disabledImage!
                          : widget.defaultImage,
                      fit: BoxFit.fill,
                      width: widget.width,
                      height: widget.height,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
