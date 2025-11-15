import 'package:cloud_firestore/cloud_firestore.dart';
import 'absen_detail.dart'; // Pastikan path ini benar

class AbsenModel {
  final String id;
  final String idUser;
  final Timestamp tanggal; // Tanggal absensi (00:00:00)
  final int count; // Jumlah absensi hari ini (1, 2, atau 3)
  final bool status; // True jika minimal 1x absen
  final Timestamp lastUpdate;
  final List<AbsenDetailModel> times; // Detail setiap sesi

  AbsenModel({
    required this.id,
    required this.idUser,
    required this.tanggal,
    required this.count,
    required this.status,
    required this.lastUpdate,
    required this.times,
  });

  factory AbsenModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null for ID: ${doc.id}");
    }

    int countValue = (data['count'] is num) ? (data['count'] as num).toInt() : 0;
    bool statusValue = (data['status'] is bool) ? data['status'] as bool : false;

    // Konversi List of Maps di Firestore menjadi List of AbsenDetailModel
    List<AbsenDetailModel> timesList = [];
    if (data['times'] is List) {
      timesList = (data['times'] as List)
          .map((item) => AbsenDetailModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return AbsenModel(
      id: doc.id,
      idUser: data['idUser'] ?? '',
      tanggal: data['tanggal'] ?? Timestamp.now(),
      count: countValue,
      status: statusValue,
      lastUpdate: data['lastUpdate'] ?? Timestamp.now(),
      times: timesList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'tanggal': tanggal,
      'count': count,
      'status': status,
      'lastUpdate': lastUpdate,
      // Konversi List of Model menjadi List of Maps
      'times': times.map((e) => e.toMap()).toList(), 
    };
  }
}