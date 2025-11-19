// File: lib/models/pengeluaran_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Pengeluaran {
  final String? id; // ID Dokumen Firestore
  final String deskripsi;
  final String kategori;
  final double nominal;
  final Timestamp tanggal; // Tipe data sudah benar: Timestamp

  Pengeluaran({
    this.id,
    required this.deskripsi,
    required this.kategori,
    required this.nominal,
    required this.tanggal,
    required this.isPaid,
  });

  // Konstruktor untuk membuat objek dari Map (dari Firestore)
  factory Pengeluaran.fromMap(String id, Map<String, dynamic> map) {
    // Penanganan nominal: memastikan konversi ke double
    // Menggunakan 'as num' untuk menangani int/double dan kemudian konversi ke double
    final double nominalValue = (map['nominal'] as num?)?.toDouble() ?? 0.0;
    
    // Penanganan tanggal: langsung ambil sebagai Timestamp dari Firestore
    // Menggunakan safe-cast dan fallback ke Timestamp.now() jika data kosong/tipe salah
    final Timestamp tanggalValue = map['tanggal'] is Timestamp 
        ? map['tanggal'] as Timestamp 
        : Timestamp.now(); 

    return Pengeluaran(
      id: id,
      deskripsi: map['deskripsi'] as String? ?? 'N/A',
      kategori: map['kategori'] as String? ?? 'N/A',
      nominal: nominalValue,
      tanggal: parsedDate,
    );
  }

  // Metode untuk mengkonversi objek menjadi Map (untuk disimpan ke Firestore)
  // Objek Timestamp dapat langsung dikirim ke Firestore tanpa konversi tambahan
  Map<String, dynamic> toMap() {
    return {
      'deskripsi': deskripsi,
      'kategori': kategori,
      'nominal': nominal,
      'tanggal': tanggal, // Langsung gunakan objek Timestamp
    };
  }

  // Metode bantu untuk mendapatkan DateTime dari Timestamp
  DateTime get dateTime => tanggal.toDate(); 
}