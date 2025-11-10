import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../model/absen.dart';

class AbsenController with ChangeNotifier {
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection('tbl_user');
  final CollectionReference _absenRef =
      FirebaseFirestore.instance.collection('tbl_absen');

  // ... (Fungsi punch() dan lainnya dihilangkan untuk fokus pada UI & Data)

  /// ✅ Stream semua absen (misal untuk admin)
  Stream<List<AbsenModel>> streamAll() {
    return _absenRef.snapshots().map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
      }
      return snapshot.docs.map((doc) => AbsenModel.fromFirestore(doc)).toList();
    });
  }

  /// ✅ Ambil semua user dan nama panggilan (DIKOREKSI KE 'name')
  Future<Map<String, String>> getUserNames() async {
    final snap = await _userRef.get();
    final userMap = {
      for (var doc in snap.docs)
        // 🚨 KOREKSI: Mengganti 'panggilan' ke 'name'
        doc.id: (doc.data() as Map<String, dynamic>?)?['panggilan']?.toString() ?? '-'
    };
    return userMap;
  }
  
  // ... (Fungsi lain dihilangkan)
}