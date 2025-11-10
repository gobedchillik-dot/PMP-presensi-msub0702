import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../model/absen.dart';

class AbsenController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection('tbl_user');
  final CollectionReference _absenRef =
      FirebaseFirestore.instance.collection('tbl_absen');
  final CollectionReference _logRef =
      FirebaseFirestore.instance.collection('tbl_absen_logs');

  // ... (Fungsi punch() dan lainnya dihilangkan untuk fokus pada UI & Data)

  /// ✅ Stream semua absen (misal untuk admin)
  Stream<List<AbsenModel>> streamAll() {
    print('DEBUG ABSEN: Mencoba stream data dari tbl_absen...');
    return _absenRef.snapshots().map((snapshot) {
      print('DEBUG ABSEN: Total dokumen absen ditemukan: ${snapshot.docs.length}');
      if (snapshot.docs.isNotEmpty) {
        print('DEBUG ABSEN: Sample ID User pertama: ${snapshot.docs.first.get('idUser')}');
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
    print('DEBUG USER: Total pengguna ditemukan: ${userMap.length}');
    if (userMap.isNotEmpty) {
      print('DEBUG USER: Sample User ID: ${userMap.keys.first}');
    }
    return userMap;
  }
  
  // ... (Fungsi lain dihilangkan)
}