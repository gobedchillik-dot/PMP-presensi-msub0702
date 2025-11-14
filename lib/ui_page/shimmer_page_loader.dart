import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.height = 80,
    this.width,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1C2A3A),           // warna dasar gelap
      highlightColor: const Color(0xFF243447),      // shimmering highlight
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2A3A),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
