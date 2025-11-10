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

  factory AbsenModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AbsenModel(
      id: doc.id,
      idUser: data['idUser'] ?? '',
      tanggal: data['tanggal'] ?? Timestamp.now(),
      count: (data['count'] ?? 0) as int,
      status: (data['status'] ?? false) as bool,
      lastUpdate: data['lastUpdate'] ?? Timestamp.now(),
      times: (data['times'] != null)
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
