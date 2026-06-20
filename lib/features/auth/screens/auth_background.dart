import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:budget_tracker/core/constants.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Background Base Color
        Container(
          color: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
        ),
        // Glow Blob 1 (Top Left)
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withOpacity(isDark ? 0.15 : 0.08),
            ),
          ),
        ),
        // Glow Blob 2 (Bottom Right)
        Positioned(
          bottom: -80,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8FD9B6).withOpacity(isDark ? 0.12 : 0.06),
            ),
          ),
        ),
        // Glow Blob 3 (Center Left/Middle)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.45,
          left: -100,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE9621B).withOpacity(isDark ? 0.08 : 0.04),
            ),
          ),
        ),
        // Blur Filter to smooth out the blobs into a soft gradient overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
            child: const SizedBox.shrink(),
          ),
        ),
        // Foreground Content
        child,
      ],
    );
  }
}
