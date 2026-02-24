// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/core/utils/animated_navigation.dart';
import 'package:el7erafe/features/client_flow/client_home/data/models/service_item.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/pages/quick_reserve_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class ServiceItemCard extends StatefulWidget {
  final ServiceItem service;

  const ServiceItemCard({super.key, required this.service});

  @override
  ServiceItemCardState createState() => ServiceItemCardState();
}

class ServiceItemCardState extends State<ServiceItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () async {
        await Future.delayed(const Duration(milliseconds: 50));

        if (mounted) {
          setState(() => _isPressed = false);
        }

        await Future.delayed(const Duration(milliseconds: 50));

        if (mounted) {
          Navigator.push(
            context,
            SlideRightRoute(
              page: QuickReservePage(
                serviceId: widget.service.id,
                serviceName: widget.service.name,
              ),
            ),
          );
        }
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF3775FA),
              width: _isPressed ? 2.w : 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? const Color(0xFF3775FA).withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isPressed ? 12.r : 6.r,
                offset: Offset(0, 4.h),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: widget.service.imageUrl,
                width: 60.w,
                height: 60.h,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  widget.service.name,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: _isPressed ? FontWeight.bold : FontWeight.w600,
                    color:
                        _isPressed ? const Color(0xFF3775FA) : Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
