import 'package:cached_network_image/cached_network_image.dart';
import 'package:el7erafe/core/utils/animated_navigation.dart';
import 'package:el7erafe/features/client_flow/client_home/data/models/service_item.dart';
import 'package:el7erafe/features/client_flow/quick_reserve/presentation/pages/quick_reserve_page.dart';
import 'package:flutter/material.dart';
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
            // ignore: use_build_context_synchronously
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3775FA),
              width: _isPressed ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    // ignore: deprecated_member_use
                    ? const Color(0xFF3775FA).withOpacity(0.3)
                    // ignore: deprecated_member_use
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isPressed ? 12 : 6,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: widget.service.imageUrl,
                width: 60,
                height: 60,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.service.name,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
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
