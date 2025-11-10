import 'package:cloud_firestore/cloud_firestore.dart';

class AbsenModel {
  final String id;
  final String idUser;
  final Timestamp tanggal;
  final int count;
  final bool status;
  final Timestamp lastUpdate;
  final List<Timestamp> times;

  AbsenModel({
    required this.id,
    required this.idUser,
    required this.tanggal,
    required this.count,
    required this.status,
    required this.lastUpdate,
    required this.times,
  });

  // AbsenModel.dart - Versi yang lebih aman

factory AbsenModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>?;

  // Jika data null (seharusnya tidak terjadi, tapi untuk safety)
  if (data == null) {
      throw Exception("Document data is null for ID: ${doc.id}");
  }

  // 1. Ambil Count (Handling num/int)
  int countValue = 0;
  if (data['count'] is num) {
      countValue = (data['count'] as num).toInt();
  }

  // 2. Ambil Status (Handling bool/String/null)
  bool statusValue = false;
  if (data['status'] is bool) {
      statusValue = data['status'] as bool;
  } else if (data['status'] is String) {
      // Jika status disimpan sebagai String 'true' atau 'false' (contoh terburuk)
      statusValue = (data['status'] as String).toLowerCase() == 'true';
      
      // Jika Anda yakin "hadir" adalah String yang tidak sengaja masuk ke field 'status', 
      // Anda perlu hapus data tersebut atau perbaiki logika penyimpanan.
      
      // Catatan: Error "hadir" mungkin muncul jika Anda tidak sengaja menggunakan field 
      // yang berisi String "hadir" saat menyimpan data.
  }

  return AbsenModel(
    id: doc.id,
    idUser: data['idUser'] ?? '',
    tanggal: data['tanggal'] ?? Timestamp.now(),
    count: countValue,
    status: statusValue, // Menggunakan statusValue yang sudah divalidasi
    lastUpdate: data['lastUpdate'] ?? Timestamp.now(),
    times: (data['times'] is List)
        ? List<Timestamp>.from(data['times'])
        : <Timestamp>[],
  );
}

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'tanggal': tanggal,
      'count': count,
      'status': status,
      'lastUpdate': lastUpdate,
      'times': times,
    };
  }
}