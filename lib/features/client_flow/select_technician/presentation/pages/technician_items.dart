// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/features/client_flow/select_technician/data/models/technicians_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class TechnicianCard extends StatefulWidget {
  final TechniciansModel technician;
  final VoidCallback onReserveTap;
  final VoidCallback onCardTap;

  const TechnicianCard({
    super.key,
    required this.technician,
    required this.onReserveTap,
    required this.onCardTap,
  });

  @override
  State<TechnicianCard> createState() => _TechnicianCardState();
}

class _TechnicianCardState extends State<TechnicianCard> {
  bool isFavorite = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onCardTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Color(0xFF3775FA).withOpacity(_isPressed ? 0.8 : 0.5),
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.technician.profilePicture.isNotEmpty
                              ? widget.technician.profilePicture
                              : 'https://i.pinimg.com/736x/43/76/88/4376889342d82f8a6033870c3e9a1640.jpg',
                          height: 100.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 100.h,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 100.h,
                            color: Colors.grey.shade100,
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey, size: 30.r),
                          ),
                        ),
                      )),
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star,
                              color: const Color(0xFFFFC107), size: 16.r),
                          SizedBox(width: 4.w),
                          Text(
                            widget.technician.rating.toStringAsFixed(1),
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.technician.name,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : const Color(0xFF3775FA),
                            size: 20.r,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.build_circle_outlined,
                            color: const Color(0xFF3775FA), size: 15.r),
                        SizedBox(width: 4.w),
                        Text(
                          widget.technician.serviceName,
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: const Color(0xFF3775FA), size: 15.r),
                        SizedBox(width: 4.w),
                        Text(
                          widget.technician.city,
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 40.h,
                      child: ElevatedButton(
                        onPressed: widget.onReserveTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3775FA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "اطلب الفني",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
