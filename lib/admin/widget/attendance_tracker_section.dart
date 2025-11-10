// lib/admin/widget/attendance_tracker_section.dart
import 'package:flutter/material.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'progress_item.dart'; // Import ProgressItem yang baru dipisah

class AttendanceTrackerSection extends StatelessWidget {
  // Jika data Absen Tracker dinamis, Anda akan meneruskan List<Map> di sini
  const AttendanceTrackerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul Absen Tracker (Delay: 0.9s)
        AnimatedFadeSlide(
          delay: 0.9,
          child: CustomSubtitle(text: "Absen Tracker")
        ),
        const SizedBox(height: 12),

        // Item Absen Tracker 1 (Delay: 1.0s)
        const AnimatedFadeSlide(
            delay: 1.0, child: ProgressItem(name: "Karyawan 1", value: 0.5)),

        // Item Absen Tracker 2 (Delay: 1.1s)
        const AnimatedFadeSlide(
            delay: 1.1, child: ProgressItem(name: "Karyawan 2", value: 0.75)),

        // Item Absen Tracker 3 (Delay: 1.2s)
        const AnimatedFadeSlide(
            delay: 1.2, child: ProgressItem(name: "Karyawan 3", value: 1.0)),
      ],
    );
  }
}