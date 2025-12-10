// lib/karyawan/widget/detail_absen_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 🔥 BIARKAN DEFINISI MODEL ABSENSI HARIAN & SESI
class AbsensiHarian {
  final String tanggal;
  final int totalPresensi;
  final List<PresensiSesi> detailSesi;
  bool isExpanded; // Biarkan isExpanded ada di model

  AbsensiHarian({
    required this.tanggal,
    required this.totalPresensi,
    required this.detailSesi,
    this.isExpanded = false,
  });
}

class PresensiSesi {
  final String namaSesi;
  final bool isHadir;
  final String? waktu;

  PresensiSesi(this.namaSesi, this.isHadir, this.waktu);
}

/// =====================================================================
///  🔥 FORMATTER AGAR TANGGAL DIPASTIKAN KONSISTEN "d MMMM yyyy"
/// =====================================================================
final DateFormat _dateFormatter = DateFormat("d MMMM yyyy", "id_ID");

/// =====================================================================
///  🔥 KOMPONEN CARD TETAP SAMA (HANYA MENAMPILKAN DATA)
/// =====================================================================
class AbsenDailyCard extends StatelessWidget {
  final AbsensiHarian data;
  final VoidCallback onTap;

  const AbsenDailyCard({
    required this.data,
    required this.onTap,
    super.key,
  });

  Color _getIndicatorColor(int count) {
    if (count == 0) return Colors.red;
    if (count == 3) return Colors.green;
    return Colors.orange;
  }

  // 🔥 FUNGSI BARU: Mendapatkan status dan warna badge
  Map<String, dynamic> _getAbsenceStatus() {
    try {
      // Parse tanggal dari string model ke objek DateTime
      final DateTime dateModel = _dateFormatter.parse(data.tanggal);
      final DateTime now = DateTime.now();
      
      // Mengabaikan waktu (hanya membandingkan tanggal)
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime targetDate = DateTime(dateModel.year, dateModel.month, dateModel.day);

      if (targetDate.isAfter(today)) {
        // Masa Depan
        return {
          'color': Colors.amber[700],
          'text': "Belum melakukan presensi di tanggal ini",
        };
      } else if (targetDate.isBefore(today)) {
        // Masa Lalu
        return {
          'color': Colors.red,
          'text': "Tidak hadir di tanggal ini",
        };
      } else {
        // Hari Ini
        return {
          'color': Colors.red,
          'text': "Belum melakukan presensi di tanggal ini",
        };
      }
    } catch (e) {
      // Fallback jika parsing gagal
      return {'color': Colors.red, 'text': "Status tidak diketahui"};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil status hanya jika totalPresensi = 0
    final status = data.totalPresensi == 0 ? _getAbsenceStatus() : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF20252D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.tanggal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Tampilkan status jika totalPresensi = 0
                    if (status != null)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status['color'] as Color, // Menggunakan warna dinamis
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status['text'] as String, // Menggunakan teks dinamis
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _getIndicatorColor(data.totalPresensi),
                      child: Text(
                        data.totalPresensi.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      data.isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: data.isExpanded
                ? Column(
                    key: const ValueKey(true),
                    children: [
                      const SizedBox(height: 14),
                      ...data.detailSesi
                          .map((e) => _buildSessionDetail(e))
                          .toList(),
                    ],
                  )
                : const SizedBox(key: ValueKey(false)),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetail(PresensiSesi sesi) {
    final Color iconColor = sesi.isHadir ? Colors.green : Colors.red;
    final IconData icon = sesi.isHadir ? Icons.check_box : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3440),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(
                sesi.namaSesi,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          Text(
            sesi.waktu ?? '-',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}