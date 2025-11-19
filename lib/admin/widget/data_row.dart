// File: lib/widgets/profile/profile_data_row.dart (REVISI KETIGA)

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

  @override
  Widget build(BuildContext context) {
    // --- Penyesuaian Gaya ---
    final Color labelColor = isHighlight ? Colors.white : Colors.white70;
    // Nilai Keuntungan dibuat hijau terang jika isHighlight true
    final Color valueColor = isHighlight ? (label.toLowerCase().contains('keuntungan') ? Colors.greenAccent : Colors.white) : Colors.white;
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
                color: valueColor,
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