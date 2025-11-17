// lib/admin/widget/attendance_tracker_section.dart
import 'package:flutter/material.dart';
import 'progress_item.dart'; // Pastikan path ini benar

class AttendanceTrackerSection extends StatelessWidget {
  /// List yang berisi data karyawan yang sudah dihitung progresnya.
  /// Contoh item: {'userName': 'Budi', 'progressValue': 0.75}
  final List<Map<String, dynamic>> employeeData; 

  const AttendanceTrackerSection({
    super.key,
    required this.employeeData, // Data harus disediakan oleh parent widget (e.g., AttendanceTrackerScreen)
  });

  @override
  Widget build(BuildContext context) {
    if (employeeData.isEmpty) {
      // Tampilkan pesan jika tidak ada data karyawan yang ditemukan
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Tidak ada data karyawan absensi yang ditemukan.", style: TextStyle(fontStyle: FontStyle.italic)),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        
        // Iterasi melalui daftar karyawan
        ...employeeData.map((data) {
          final String name = data['userName'] as String;
          
          // Mengambil nilai progres (value) yang sudah dihitung.
          // Nilai ini sudah dipastikan berada di antara 0.0 hingga 1.0.
          final double progressValue = data['progressValue'] as double; 

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ProgressItem(
              name: name,
              value: progressValue, // Nilai progres (0.0 jika belum ada absen)
            ),
          );
        }),
      ],
    );
  }
}