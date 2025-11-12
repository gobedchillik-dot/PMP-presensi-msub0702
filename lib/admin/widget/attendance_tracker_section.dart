// lib/admin/widget/attendance_tracker_section.dart
import 'package:flutter/material.dart';
import 'progress_item.dart'; // Import ProgressItem yang baru dipisah

class AttendanceTrackerSection extends StatelessWidget {
  // Jika data Absen Tracker dinamis, Anda akan meneruskan List<Map> di sini
  const AttendanceTrackerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        ProgressItem(name: "Karyawan 1", value: 0.5),
        ProgressItem(name: "Karyawan 2", value: 0.75),
        ProgressItem(name: "Karyawan 3", value: 1.0),
      ],
    );
  }
}