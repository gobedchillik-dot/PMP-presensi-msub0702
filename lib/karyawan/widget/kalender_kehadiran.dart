import 'package:flutter/material.dart';


class AttendanceCalendar extends StatelessWidget {
  final List<bool> attendanceData;

  const AttendanceCalendar({super.key, required this.attendanceData});

  Widget _buildDateBox(int day, bool isAttended, double size) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isAttended ? Colors.green.shade400 : Colors.blueGrey.shade700,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF152A46),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan grid
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

          // Wrap di tengah
          Center(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(totalDays, (index) {
                return _buildDateBox(index + 1, attendanceData[index], boxSize);
              }),
            ),
          ),

          const SizedBox(height: 16),

          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Legend(color: Colors.green, label: "Hadir"),
              SizedBox(width: 8),
              Legend(color: Color(0xFF546E7A), label: "Absen/Libur"),
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
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}