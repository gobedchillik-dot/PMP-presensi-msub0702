import 'package:cloud_firestore/cloud_firestore.dart';

class GmvModel {
  // 'id' akan diambil dari Document ID (UID) dari koleksi tbl_gmv
  final String id; 
  final double gmv; // Gross Merchandise Value
  final Timestamp tanggal; // Menyimpan tanggal sebagai Timestamp Firebase
  final Timestamp? createdAt; // Waktu pembuatan record (opsional untuk dibaca)

  GmvModel({
    required this.id,
    required this.gmv,
    required this.tanggal,
    this.createdAt,
  });

  // 1. Factory constructor untuk Deserialisasi (Membaca dari Firestore)
  factory GmvModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    // Memastikan data tidak null sebelum diakses
    final data = doc.data()!;
    
    // Penanganan konversi tipe data: 
    // Jika disimpan sebagai int (umum di Firestore), konversi ke double, jika null default ke 0.0
    final gmvValue = (data['gmv'] is int) ? (data['gmv'] as int).toDouble() : (data['gmv'] as double? ?? 0.0);
    
    return GmvModel(
      id: doc.id, // Mengambil UID dokumen dari Document ID
      gmv: gmvValue,
      tanggal: data['tanggal'] as Timestamp? ?? Timestamp.now(), 
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  // 2. Metode untuk Serialisasi (Menulis ke Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'gmv': gmv,
      'tanggal': tanggal,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}