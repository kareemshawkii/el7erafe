import 'package:el7erafe/core/services/local_storage/auth_local_storage.dart';
import 'package:el7erafe/core/utils/modern_snakebar.dart';
import 'package:el7erafe/features/chat_system/data/models/chat_message_model.dart';
import 'package:el7erafe/features/chat_system/data/repositories/chat_repository.dart';
import 'package:el7erafe/features/chat_system/presentation/cubit/chat_cubit.dart';
import 'package:el7erafe/features/chat_system/presentation/cubit/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatRoomPage extends StatelessWidget {
  final int chatId;
  final String receiverName;
  final String receiverImage;

  const ChatRoomPage({
    super.key,
    required this.chatId,
    required this.receiverName,
    required this.receiverImage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        ChatRepository(),
        chatId: chatId,
      )..connectAndLoadHistory(),
      child: ChatRoomView(
        receiverName: receiverName,
        receiverImage: receiverImage,
      ),
    );
  }
}

class ChatRoomView extends StatefulWidget {
  final String receiverName;
  final String receiverImage;

  const ChatRoomView({
    super.key,
    required this.receiverName,
    required this.receiverImage,
  });

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView>
    with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  bool _isSendingLocation = false;
  String currentUserId = "";
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserId();
  }

  void _loadUserId() async {
    final id = await AuthLocalStorage().getUserId();
    if (mounted) {
      setState(() {
        currentUserId = id ?? "";
        _isLoadingUser = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ChatCubit>().reconnectAndRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      context.read<ChatCubit>().disconnectSignalR();
    }
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isNotEmpty) {
      context.read<ChatCubit>().sendMessage(text);
      _messageController.clear();
    }
  }

  Future<void> _sendCurrentLocation() async {
    setState(() {
      _isSendingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('يرجى تفعيل خدمات الموقع في هاتفك');
        setState(() {
          _isSendingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('تم رفض صلاحية الوصول للموقع');
          setState(() {
            _isSendingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('صلاحية الموقع مرفوضة دائماً من إعدادات الهاتف');
        setState(() {
          _isSendingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.high);
      String mapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      if (mounted) context.read<ChatCubit>().sendMessage(mapsUrl);
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء تحديد الموقع');
    }

    setState(() {
      _isSendingLocation = false;
    });
  }

  void _showSnackBar(String text) {
    if (!mounted) return;
    ModernSnackbar.showError(context: context, message: text);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: const Color(0xFF3775FA)),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildCustomAppBar(context),
            _buildWarningBanner(),
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatModerationRejected) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierLabel: '',
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (context, anim1, anim2) => const SizedBox(),
                      transitionBuilder: (context, anim1, anim2, child) {
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                              CurvedAnimation(
                                  parent: anim1, curve: Curves.easeOutBack)),
                          child: FadeTransition(
                            opacity: anim1,
                            child: AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r)),
                              contentPadding: EdgeInsets.all(24.r),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_rounded,
                                      color: Colors.red, size: 60.r),
                                  SizedBox(height: 16.h),
                                  Text("تحذير هام",
                                      style: GoogleFonts.cairo(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red)),
                                  SizedBox(height: 12.h),
                                  Text(
                                    "يمنع منعاً باتاً إرسال أي أرقام هواتف أو وسائل تواصل خارجية. تكرار هذا الأمر سيؤدي إلى حظر حسابك نهائياً.",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cairo(
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 20.h),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r))),
                                      child: Text("حسناً، فهمت",
                                          style: GoogleFonts.cairo(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  else if (state is ChatError) {
                    _showSnackBar(state.message);
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/icon/loading.json',
                            width: 200.w,
                            height: 200.h,
                            repeat: true,
                            animate: true,
                          ),
                        ],
                      ),
                    );
                  }  else if (state is ChatLoaded ||
                      state is ChatModerationRejected) {
                    final messages = state is ChatLoaded
                        ? state.messages
                        : (state as ChatModerationRejected).messages;

                    return ListView.builder(
                      reverse: true,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == "ME" ||
                            message.senderId == currentUserId;
                        return _buildChatBubble(message, isMe, index);
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      color: const Color(0xFF3775FA),
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12.h,
          bottom: 12.h,
          left: 16.w,
          right: 16.w),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, -20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Row(
          children: [
            GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 24.r))),
            SizedBox(width: 12.w),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                bool isUserOnline = false;
                if (state is ChatLoaded) {
                  isUserOnline = state.isOnline;
                }
                return Expanded(
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                              radius: 22.r,
                              backgroundImage:
                                  NetworkImage(widget.receiverImage)),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12.r,
                              height: 12.r,
                              decoration: BoxDecoration(
                                  color:
                                      isUserOnline ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFF3775FA),
                                      width: 2.w)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.receiverName,
                                style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 4.h),
                            Text(isUserOnline ? "متصل الان" : "غير متصل",
                                style: GoogleFonts.cairo(
                                    color: Colors.white70, fontSize: 12.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        margin:
            EdgeInsets.only(top: 12.h, bottom: 0.h, left: 16.w, right: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(8.r)),
        child: Row(
          children: [
            Icon(Icons.push_pin_outlined, color: Colors.redAccent, size: 18.r),
            SizedBox(width: 8.w),
            Expanded(
                child: Text(
                    "لأمان حسابك، لا تشارك رقم هاتفك او اي وسيلة تواصل شخصيه, التواصل داخل التطبيق فقط.",
                    style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel message, bool isMe, int index) {
    Widget bubbleContent;

    if (message.messageType == 'CallDeclined') {
      bubbleContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.call_end, color: Colors.red, size: 20.r),
          SizedBox(width: 8.w),
          Text(message.content,
              style: GoogleFonts.cairo(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14.sp)),
        ],
      );
    } else if (message.messageType == 'CallCancelled') {
      bubbleContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.call_missed_outgoing, color: Colors.red, size: 20.r),
          SizedBox(width: 8.w),
          Text(message.content,
              style: GoogleFonts.cairo(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14.sp)),
        ],
      );
    } else if (message.messageType == 'CallEnded') {
      bubbleContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.call,
              color: isMe ? Colors.white : const Color(0xFF3775FA), size: 20.r),
          SizedBox(width: 8.w),
          Text(message.content,
              style: GoogleFonts.cairo(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14.sp)),
        ],
      );
    } else if (message.messageType == 'CallAccepted') {
      bubbleContent = Text("📞 ${message.content}",
          style: GoogleFonts.cairo(
              color: isMe ? Colors.white : Colors.black87, fontSize: 14.sp));
    } else if (message.messageType == 'CallInvite') {
      bubbleContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.ring_volume,
              color: isMe ? Colors.white : const Color(0xFF3775FA), size: 20.r),
          SizedBox(width: 8.w),
          Text(isMe ? "مكالمة صادرة" : "مكالمة واردة",
              style: GoogleFonts.cairo(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold)),
        ],
      );
    } else {
      bubbleContent = _buildMessageTextWithLinks(message.content, isMe);
    }

    int staggerDelayIndex = index > 15 ? 15 : index;

    return TweenAnimationBuilder<double>(
      key: ValueKey(message.id),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (staggerDelayIndex * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () {
          if (message.messageType.startsWith('Call')) return;
          Clipboard.setData(ClipboardData(text: message.content));
          ModernSnackbar.show(
            context: context,
            message: "تم نسخ الرسالة",
            color: const Color(0xFF3775FA),
            icon: Icons.copy,
            title: "نسخ",
          );
        },
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color:
                      isMe ? const Color(0xFF3775FA) : const Color(0xFFEBEBEB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: Radius.circular(isMe ? 16.r : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 16.r),
                  ),
                ),
                child: bubbleContent,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMe) ...[
                    _buildMessageStatusIcon(message.messageStatus),
                    SizedBox(width: 4.w),
                  ],
                  Text(message.formattedTime,
                      style: GoogleFonts.cairo(
                          fontSize: 11.sp, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageTextWithLinks(String text, bool isMe) {
    if (text.startsWith('https://www.google.com/maps/search/?api=1&query=')) {
      return GestureDetector(
        onTap: () async {
          final url = Uri.parse(text);
          try {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } catch (e) {
            _showSnackBar('تعذر فتح الرابط');
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on,
                color: isMe ? Colors.white : Colors.red, size: 20.r),
            SizedBox(width: 8.w),
            Text("الموقع (اضغط للفتح)",
                style: GoogleFonts.cairo(
                    color: isMe ? Colors.white : const Color(0xFF3775FA),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }
    return Text(text,
        style: GoogleFonts.cairo(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500));
  }

  Widget _buildMessageStatusIcon(String status) {
    if (status == 'Failed') {
      return Icon(Icons.error_outline, color: Colors.red, size: 16.r);
    }
    if (status == 'Read') {
      return Icon(Icons.done_all, color: const Color(0xFF3775FA), size: 16.r);
    }
    if (status == 'Delivered') {
      return Icon(Icons.done_all, color: Colors.grey.shade500, size: 16.r);
    }
    return Icon(Icons.check, color: Colors.grey.shade500, size: 16.r);
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h, bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        boxShadow: [
          BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                height: 45.h,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border:
                        Border.all(color: Colors.grey.shade300, width: 1.w)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.cairo(fontSize: 14.sp),
                        decoration: InputDecoration(
                            hintText: "اكتب رسالتك",
                            hintStyle: GoogleFonts.cairo(
                                color: Colors.grey.shade400, fontSize: 14.sp),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 10.h)),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: _isSendingLocation
                          ? Padding(
                              key: const ValueKey('loading'),
                              padding: EdgeInsets.only(left: 12.w),
                              child: SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF3775FA))),
                            )
                          : GestureDetector(
                              key: const ValueKey('icon'),
                              onTap: _sendCurrentLocation,
                              child: Padding(
                                padding: EdgeInsets.only(left: 12.w),
                                child: Icon(Icons.location_on,
                                    color: const Color(0xFF3775FA), size: 24.r),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(45.r),
                // ignore: deprecated_member_use
                splashColor: const Color(0xFF3775FA).withOpacity(0.3),
                // ignore: deprecated_member_use
                highlightColor: const Color(0xFF3775FA).withOpacity(0.1),
                child: Container(
                  width: 45.r,
                  height: 45.r,
                  padding: EdgeInsets.all(1.r),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF3775FA), width: 1.5.w)),
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Color(0xFF3775FA), shape: BoxShape.circle),
                      child: Transform.flip(
                          flipX: true,
                          child: Icon(Iconsax.send,
                              color: Colors.white, size: 20.r))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
