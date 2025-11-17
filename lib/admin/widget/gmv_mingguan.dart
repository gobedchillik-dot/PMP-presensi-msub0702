import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GmvWeeklyCard extends StatelessWidget {
  final int mingguKe;
  final double total; // 💡 Diubah menjadi double
  final bool isUp;
  // Tambahkan dateRange (opsional, tapi berguna untuk GmvController)
  final String dateRange; 

  const GmvWeeklyCard({
    super.key,
    required this.mingguKe,
    required this.total,
    required this.isUp,
    this.dateRange = '', // Beri nilai default
  });

  // 💡 Gunakan formatMoney yang sudah ada untuk konsistensi
  String formatMoney(double number) {
    // Menggunakan compactCurrency untuk angka besar
    if (number >= 1000000) {
      final formatter = NumberFormat.compactCurrency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 1,
      );
      return formatter.format(number);
    }
    // Menggunakan format penuh untuk angka yang lebih kecil
    final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
    );
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    final Color color = isUp ? const Color(0xFF00E676) : Colors.red; // Green untuk Up

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF152A46),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Minggu ke - $mingguKe",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          // Tambahkan rentang tanggal jika Anda mau (saat ini di-hidden)
          // if (dateRange.isNotEmpty)
          //   Text(dateRange, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                formatMoney(total),
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              // Hanya tampilkan panah jika total > 0 (untuk menghindari panah di Rp 0)
              if (total > 0)
                Icon(
                  isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  color: color,
                  size: 18,
                ),
            ],
          ),
        ],
      ),
    );
  }
}