// File: lib/widgets/profile/profile_data_row.dart (REVISI KEEMPAT - DENGAN LOGIKA NUMERIK)

import 'package:flutter/material.dart';

class ProfileDataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiLine;
  final bool isHighlight;

  const ProfileDataRow({
    super.key,
    required this.label,
    required this.value,
    this.isMultiLine = false,
    this.isHighlight = false,
  });

  // Fungsi utilitas untuk membersihkan string mata uang dan mengurainya menjadi double
  double _parseValue(String value) {
    // 1. Membersihkan karakter non-numerik yang umum di format mata uang
    // Misalnya: Rp, $, ., ,, spasi. Kecuali tanda minus (-).
    String cleanValue = value.replaceAll(RegExp(r'[^\d\.-]'), '');

    // 2. Mengganti koma desimal dengan titik desimal (standar Dart/double)
    // Perhatian: Ini mengasumsikan format: 1.000.000,00 -> 1000000.00 atau 1,000,000.00 -> 1000000.00
    // Karena format yang umum di Indonesia adalah menggunakan koma sebagai pemisah desimal,
    // kita coba ganti koma menjadi titik HANYA jika ada koma.
    // Namun, jika formatnya sudah dipastikan bersih (seperti "1000000" atau "-50000"), abaikan.

    // Untuk amannya, kita akan mengurai langsung setelah membersihkan sebagian besar karakter.
    // Jika formatnya "Rp 1.234.567,89", ini akan gagal karena ada dua titik/koma.
    // ASUMSI: Data 'value' sudah berupa string angka bersih atau standar mata uang.

    try {
      // Kita asumsikan format mata uang yang masuk sudah cukup bersih atau menggunakan titik
      // sebagai pemisah desimal jika ada desimal (cth: "1000.50").
      return double.tryParse(cleanValue) ?? 0.0;
    } catch (e) {
      // Jika gagal, kembalikan 0.0 agar aman (misal: "N/A" atau string non-angka lainnya)
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Penyesuaian Gaya ---
    final Color labelColor = isHighlight ? Colors.white : Colors.white70;

    // 1. Tentukan warna default jika isHighlight false
    Color valueColor = Colors.white;

    // 2. Logika Pewarnaan berdasarkan nilai HANYA JIKA isHighlight true
    if (isHighlight) {
      if (label.toLowerCase().contains('keuntungan')) {
        final double numericValue = _parseValue(value);

        if (numericValue < 0) {
          // KONDISI BARU: Merah jika nilai < 0
          valueColor = Colors.redAccent;
        } else {
          // KONDISI LAMA: Hijau terang jika nilai >= 0
          valueColor = Colors.greenAccent;
        }
      } else {
        // Jika isHighlight true tapi bukan label 'keuntungan', warnanya putih
        valueColor = Colors.white;
      }
    }
    
    final FontWeight valueWeight = isHighlight ? FontWeight.bold : FontWeight.w500;
    final double valueSize = isHighlight ? 16 : 15;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          
          // 1. KOLOM KETERANGAN (Label) - Flex: 55%
          Expanded(
            flex: 55, 
            child: Text(
              label,
              textAlign: TextAlign.left,
              style: TextStyle(color: labelColor, fontSize: 15),
              overflow: TextOverflow.ellipsis,
              maxLines: 1, 
            ),
          ),

          // 2. KOLOM SEPARATOR (Titik Dua) - Static
          // Menggunakan SizedBox kecil agar titik dua selalu sejajar
          const SizedBox(
            width: 10, // Lebar kecil, cukup untuk " : "
            child: Text(
              " : ", 
              textAlign: TextAlign.center, // Perataan tengah memastikan konsistensi
              style: TextStyle(color: Colors.white),
            ),
          ),
          
          // 3. KOLOM NILAI (Value) - Flex: 45%
          Expanded(
            flex: 45, 
            child: Text(
              value,
              textAlign: TextAlign.right, // Penting agar teks nilai menempel di sisi kanan
              style: TextStyle(
                color: valueColor, // MENGGUNAKAN valueColor yang sudah diperbarui
                fontWeight: valueWeight,
                fontSize: valueSize,
              ),
              maxLines: isMultiLine ? 3 : 1,
              overflow: isMultiLine ? TextOverflow.ellipsis : TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }
}