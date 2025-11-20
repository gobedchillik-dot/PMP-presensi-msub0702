import 'package:cloud_firestore/cloud_firestore.dart';

class GmvModel {
  final String id;
  final double gmv;
  final Timestamp tanggal;
  final Timestamp? createdAt;

  GmvModel({
    required this.id,
    required this.gmv,
    required this.tanggal,
    this.createdAt,
  });

  factory GmvModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    final gmvValue = (data['gmv'] is int)
        ? (data['gmv'] as int).toDouble()
        : (data['gmv'] as double? ?? 0.0);

    return GmvModel(
      id: doc.id,
      gmv: gmvValue,
      tanggal: data['tanggal'] as Timestamp? ?? Timestamp.now(),
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gmv': gmv,
      'tanggal': tanggal,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
