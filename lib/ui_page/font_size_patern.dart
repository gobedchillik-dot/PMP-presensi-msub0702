import 'package:flutter/material.dart';

// Definisi warna yang digunakan oleh kInfoStyle
const Color _kDarkerTextColor = Colors.white70;

/// ---
/// 🎯 DEFINISI FONT STYLE (Pola)
/// ---
// Dibuat menjadi class internal (atau private dengan _ di depan)
class _FontStylePattern { 
  /// Style untuk Judul Utama (kTitleStyle)
  static const TextStyle kTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  /// Style untuk Sub Judul (kSubtitleStyle)
  static const TextStyle kSubtitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Style untuk Informasi Tambahan/Keterangan Kecil (kInfoStyle)
  static const TextStyle kInfoStyle = TextStyle(
    color: _kDarkerTextColor,
    fontSize: 15,
    fontWeight: FontWeight.normal,
  );
}

/// ---
/// 🎯 WIDGET WRAPPER (Komponen)
/// ---

/// Widget untuk menampilkan teks dengan Style Judul Utama (kTitleStyle).
class CustomTitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const CustomTitle({
    super.key,
    required this.text,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      // Mengakses style yang didefinisikan di atas
      style: _FontStylePattern.kTitleStyle, 
    );
  }
}

/// Widget untuk menampilkan teks dengan Style Sub Judul (kSubtitleStyle).
class CustomSubtitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const CustomSubtitle({
    super.key,
    required this.text,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      // Mengakses style yang didefinisikan di atas
      style: _FontStylePattern.kSubtitleStyle,
    );
  }
}

/// Widget untuk menampilkan teks dengan Style Info Kecil (kInfoStyle).
class CustomInfo extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const CustomInfo({
    super.key,
    required this.text,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      // Mengakses style yang didefinisikan di atas
      style: _FontStylePattern.kInfoStyle,
    );
  }
}