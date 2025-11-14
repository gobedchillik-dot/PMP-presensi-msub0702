// lib/widgets/profile/profile_section_wrapper.dart

import 'package:flutter/material.dart';

class ProfileSectionWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool isSimple; 

  const ProfileSectionWrapper({
    super.key,
    required this.title,
    this.subtitle = "",
    required this.children,
    this.isSimple = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4), // Memberi jarak kecil setelah title
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70, // Lebih lembut dari putih penuh
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 12),
        isSimple
            ? Column(
                children: children,
              )
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF152A46), 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: children,
                ),
              ),
      ],
    );
  }
}