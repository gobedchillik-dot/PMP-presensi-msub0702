import 'package:flutter/material.dart';

final List<bool> currentUserAttendance = List.generate(31, (day) => day < 30 ? day % 3 != 0 : true); // Data simulasi 31 hari const int totalDaysInMonth = 31; const double rowHeight = 35.0; const double boxWidth = 24.0;

class AttendanceCalendar extends StatelessWidget {
  final List<bool> attendanceData; // Data absensi bulanan (true = hadir)



  const AttendanceCalendar({
    required this.attendanceData,

  });

  // Fungsi pembantu untuk membuat kotak tanggal
  Widget _buildDateBox(int day, bool isAttended) {
    return Container(
      width: 50,
      height: 40,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isAttended ? Colors.green.shade400 : Colors.blueGrey.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        day.toString(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Asumsi bulan dimulai pada hari Rabu (1 Oktober 2025 adalah Rabu)
    const int startDayOfWeek = 3; // 1=Senin, 2=Selasa, 3=Rabu...
    final int totalDays = attendanceData.length;
    
    // Buat daftar kotak kosong (padding) sebelum tanggal 1
    final List<Widget> calendarBoxes = List.generate(
      startDayOfWeek - 1,
      (index) => const SizedBox(width: 50, height: 40),
    );

    // Tambahkan kotak tanggal
    for (int day = 1; day <= totalDays; day++) {
      // Index array dimulai dari 0, sedangkan hari dimulai dari 1
      final bool isAttended = attendanceData[day - 1]; 
      calendarBoxes.add(_buildDateBox(day, isAttended));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF152A46),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Hari
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayHeader(text: 'S', isWeekend: false), // Senin
              _DayHeader(text: 'S', isWeekend: false), // Selasa
              _DayHeader(text: 'R', isWeekend: false), // Rabu
              _DayHeader(text: 'K', isWeekend: false), // Kamis
              _DayHeader(text: 'J', isWeekend: false), // Jumat
              _DayHeader(text: 'S', isWeekend: true),  // Sabtu
              _DayHeader(text: 'M', isWeekend: true),  // Minggu
            ],
          ),
          const Divider(color: Colors.white30, height: 16),
          
          // Grid Kalender
          Wrap(
            spacing: 0, 
            runSpacing: 0,
            children: calendarBoxes,
          ),

          const SizedBox(height: 16),
          
          // Keterangan Legenda
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _Legend(color: Colors.green, label: "Hadir"),
              SizedBox(width: 8),
              _Legend(color: Color(0xFF546E7A), label: "Absen/Libur"),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String text;
  final bool isWeekend;

  const _DayHeader({required this.text, required this.isWeekend});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40, 
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isWeekend ? Colors.red.shade300 : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}