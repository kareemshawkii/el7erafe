// ignore_for_file: deprecated_member_use

import 'package:el7erafe/core/utils/animated_navigaton_with_build.dart';
import 'package:el7erafe/features/authentication_module/login/data/repositories/auth_repository.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/cubit/login_cubit.dart';
import 'package:el7erafe/features/authentication_module/login/presentation/pages/login_page.dart';
import 'package:el7erafe/features/chat_system/data/repositories/inbox_repository.dart';
import 'package:el7erafe/features/chat_system/presentation/cubit/inbox_cubit.dart';
import 'package:el7erafe/features/chat_system/presentation/cubit/inbox_state.dart';
import 'package:el7erafe/features/chat_system/presentation/pages/chat_room_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:el7erafe/features/chat_system/data/models/inbox_conversation_model.dart';
import 'package:lottie/lottie.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InboxCubit(InboxRepository())..fetchInbox(),
      child: const InboxPageView(),
    );
  }
}

class InboxPageView extends StatefulWidget {
  const InboxPageView({super.key});

  @override
  State<InboxPageView> createState() => _InboxPageViewState();
}

class _InboxPageViewState extends State<InboxPageView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
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
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      children: [
                        SizedBox(width: 4.w),
                        GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            },
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black,
                                size: 24.r,
                              ),
                            )),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 0),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                context
                                    .read<InboxCubit>()
                                    .searchConversations(value);
                              },
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: "دور على حرفي بالاسم",
                                hintStyle: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade300, width: 1.w),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                      color: const Color(0xFF3775FA),
                                      width: 1.w),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.h, horizontal: 12.w),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey.shade500,
                                  size: 20.r,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: BlocConsumer<InboxCubit, InboxState>(
                    listener: (context, state) {
                      if (state is InboxUnauthorized) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(state.message, style: GoogleFonts.cairo()),
                            backgroundColor: Colors.red,
                          ),
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          SlideRightRouteWithBuild(
                            builder: (context) => BlocProvider(
                              create: (context) =>
                                  LoginCubit(authRepository: AuthRepository()),
                              child: const LoginPage(),
                            ),
                          ),
                          (route) => false,
                        );
                      } else if (state is InboxError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(state.message, style: GoogleFonts.cairo()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is InboxLoading) {
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
                      } else if (state is InboxError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: GoogleFonts.cairo(
                                fontSize: 16.sp, color: Colors.red),
                          ),
                        );
                      } else if (state is InboxLoaded) {
                        if (state.conversations.isEmpty) {
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) =>
                                Opacity(opacity: value, child: child),
                            child: Center(
                              child: Text(
                                "لا توجد محادثات",
                                style: GoogleFonts.cairo(
                                    fontSize: 16.sp, color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        final sortedConversations =
                            List<InboxConversationModel>.from(
                                state.conversations);
                        sortedConversations.sort((a, b) {
                          if (a.unreadCount > 0 && b.unreadCount == 0) {
                            return -1;
                          }
                          if (a.unreadCount == 0 && b.unreadCount > 0) return 1;
                          return b.lastMessageTime.compareTo(a.lastMessageTime);
                        });
                        return ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: sortedConversations.length,
                          itemBuilder: (context, index) {
                            final chat = sortedConversations[index];
                            return AnimatedChatCardItem(
                                chat: chat, index: index);
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedChatCardItem extends StatefulWidget {
  final InboxConversationModel chat;
  final int index;

  const AnimatedChatCardItem({
    super.key,
    required this.chat,
    required this.index,
  });

  @override
  State<AnimatedChatCardItem> createState() => _AnimatedChatCardItemState();
}

class _AnimatedChatCardItemState extends State<AnimatedChatCardItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = widget.chat.unreadCount > 0;

    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.chat.chatId),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (widget.index * 75)),
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
      child: Listener(
        onPointerDown: (_) => setState(() => _isPressed = true),
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                  color: hasUnread
                      ? const Color(0xFF3775FA)
                      : Colors.grey.shade200,
                  width: 1.w),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                splashColor: const Color(0xFF3775FA).withOpacity(0.1),
                highlightColor: const Color(0xFF3775FA).withOpacity(0.05),
                onTap: () {
                  FocusScope.of(context).unfocus();

                  Future.delayed(const Duration(milliseconds: 80), () {
                    if (!mounted) return;
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      SlideRightRouteWithBuild(
                        builder: (context) => ChatRoomPage(
                          chatId: widget.chat.chatId,
                          receiverId: widget.chat.receiverId,
                          receiverName: widget.chat.receiverName,
                          receiverImage: widget.chat.receiverImage,
                        ),
                      ),
                    );
                  });
                },
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50.r),
                        child: Image.network(
                          widget.chat.receiverImage,
                          width: 48.r,
                          height: 48.r,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 48.r,
                            height: 48.r,
                            color: Colors.grey.shade300,
                            child: Icon(Icons.person,
                                color: Colors.grey, size: 24.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.chat.receiverName,
                              style: GoogleFonts.cairo(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.7,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                if (widget.chat.isLastMessageFromMe) ...[
                                  if (widget.chat.messageStatus == 'Read')
                                    Padding(
                                      padding: EdgeInsets.only(left: 4.w),
                                      child: Icon(
                                        Icons.done_all,
                                        color: const Color(0xFF3775FA),
                                        size: 16.r,
                                      ),
                                    ),
                                  if (widget.chat.messageStatus == 'Sent')
                                    Padding(
                                      padding: EdgeInsets.only(left: 4.w),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.grey.shade500,
                                        size: 16.r,
                                      ),
                                    ),
                                  if (widget.chat.messageStatus == 'Delivered')
                                    Padding(
                                      padding: EdgeInsets.only(left: 4.w),
                                      child: Icon(
                                        Icons.done_all,
                                        color: Colors.grey.shade500,
                                        size: 16.r,
                                      ),
                                    ),
                                ],
                                Expanded(
                                  child: Text(
                                    widget.chat.lastMessageContent,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: hasUnread
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      height: 1.7,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (hasUnread)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.h),
                              constraints: BoxConstraints(
                                minWidth: 20.r,
                                minHeight: 20.r,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3775FA),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                widget.chat.unreadCount > 99
                                    ? '99+'
                                    : widget.chat.unreadCount.toString(),
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                            )
                          else
                            SizedBox(height: 20.r),
                          SizedBox(height: 12.h),
                          Text(
                            widget.chat.formattedTime,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
