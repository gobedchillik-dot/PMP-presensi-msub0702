import 'package:flutter/material.dart';


// TIPE DATA DIPERBARUI ke List<int> UNTUK MENDUKUNG LOGIKA 4 LEVEL (0-3)
class AttendanceCalendar extends StatelessWidget {
  final List<int> attendanceData;

  const AttendanceCalendar({super.key, required this.attendanceData});

  // Fungsi penentu warna berdasarkan count (0-3)
  Color _getColorForCount(int count, int day) {
    final now = DateTime.now();
    final today = now.day;
    
    switch (count) {
      case 3:
        // 🏆 Kehadiran Penuh
        return Colors.greenAccent.shade400; 
      case 2:
        // Hampir Penuh (Transisi)
        return Colors.lightBlueAccent.shade400; 
      case 1:
        // Kurang Penuh (Peringatan)
        return Colors.amberAccent.shade400; 
      case 0:
        // Status Absen
        if (day < today) {
          // 🔴 Absen di Masa Lalu (Alpha)
          return Colors.redAccent.shade400; 
        } else if (day == today) {
          // 🟡 Absen Hari Ini (Perlu tindakan)
          return Colors.amber.shade400; 
        } else {
          // ⚪ Hari Mendatang
          return Colors.blueGrey.shade700;
        }
      default:
        // Default (misalnya nilai count > 3 atau tidak valid)
        return Colors.blueGrey.shade700; 
    }
  }

  Widget _buildDateBox(int day, int count, double size) {
    // Memanggil fungsi penentu warna berdasarkan count
    final color = _getColorForCount(count, day);

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        day.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = "${_getMonthName(now.month)} ${now.year}";
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = 4.0;
    
    final totalColumns = 8; 
    final boxSize = (screenWidth - 32 - (spacing * (totalColumns - 1))) / totalColumns;

    final int totalDays = attendanceData.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF152A46),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            monthName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Wrap di tengah (Header Hari Dihapus)
          Center(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(totalDays, (index) {
                final day = index + 1;
                // Mengambil nilai count (0-3) dari data yang sudah diubah tipenya
                final count = attendanceData[index]; 
                return _buildDateBox(day, count, boxSize);
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Legend Diperbarui
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              Legend(color: Color(0xFFC6FF00), label: "3 Sesi (Penuh)"),
              Legend(color: Color(0xFF40C4FF), label: "2 Sesi"),
              Legend(color: Color(0xFFFFAB40), label: "1 Sesi"),
              Legend(color: Color(0xFFFF5252), label: "Absen Lalu"),
              Legend(color: Color(0xFF546E7A), label: "Hari Mendatang"),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return monthNames[month];
  }
}

class Legend extends StatelessWidget {
  final Color color;
  final String label;
  const Legend({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}