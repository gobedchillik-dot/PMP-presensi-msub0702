import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AttendanceCalendar extends StatelessWidget {
  final List<Map<String, dynamic>> attendanceData;

  const AttendanceCalendar({super.key, required this.attendanceData});

  @override
  Widget build(BuildContext context) {
    // Ambil tanggal bulan ini
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    // Mapping tanggal => status absensi
    final Map<String, String> attendanceMap = {};
    for (var item in attendanceData) {
      try {
        DateTime tanggal;
        if (item['tanggal'] is DateTime) {
          tanggal = item['tanggal'];
        } else if (item['tanggal'] is Timestamp) {
          tanggal = (item['tanggal'] as Timestamp).toDate();
        } else if (item['tanggal'] is String) {
          tanggal = DateTime.parse(item['tanggal']);
        } else {
          continue;
        }

        final key = DateFormat('yyyy-MM-dd').format(tanggal);
        attendanceMap[key] = item['status'] ?? '-';
      } catch (e) {
        debugPrint('Gagal parsing tanggal: $e');
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2B4A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            DateFormat('MMMM yyyy').format(now),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            itemCount: daysInMonth,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 hari dalam seminggu
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              final date =
                  DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, day));

              final status = attendanceMap[date];
              Color color;

              switch (status) {
                case 'Hadir':
                  color = Colors.greenAccent.shade400;
                  break;
                case 'Izin':
                  color = Colors.orangeAccent.shade400;
                  break;
                case 'Sakit':
                  color = Colors.redAccent.shade400;
                  break;
                default:
                  color = const Color(0xFF2E3B57);
              }

              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
