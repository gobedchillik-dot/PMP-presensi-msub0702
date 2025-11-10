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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // Membuat ID dokumen unik per user per tanggal (misal: userId_20251110)
  String _docIdFor(DateTime day, String userId) {
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '${userId}_$y$m$d';
  }

  Timestamp _dayStartTimestamp(DateTime d) {
    final start = DateTime(d.year, d.month, d.day);
    return Timestamp.fromDate(start);
  }

  /// ✅ CREATE / UPDATE (punch masuk atau keluar)
  Future<bool> punch({
    required String userId,
    int maxCount = 3,
    bool writeLog = true,
  }) async {
    _setLoading(true);
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final docId = _docIdFor(dayStart, userId);
    final docRef = _absenRef.doc(docId);

    try {
      await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(docRef);
        final serverNow = Timestamp.now();

        if (!snapshot.exists) {
          // ✅ Buat dokumen baru jika belum ada
          final newData = {
            'id_user': userId,
            'tanggal': _dayStartTimestamp(dayStart),
            'count': 1,
            'times': [serverNow],
            'last_updated': serverNow,
          };
          tx.set(docRef, newData);

          if (writeLog) {
            final logRef = _logRef.doc();
            tx.set(logRef, {
              'id_user': userId,
              'doc_id': docId,
              'action': 'punch_created',
              'timestamp': serverNow,
              'count_after': 1,
            });
          }
        } else {
          // ✅ Update dokumen existing
          final data = snapshot.data() as Map<String, dynamic>? ?? {};
          final currentCount =
              (data['count'] is num) ? (data['count'] as num).toInt() : 0;
          final existingTimes = (data['times'] is List)
              ? List<dynamic>.from(data['times'])
              : <dynamic>[];

          if (currentCount >= maxCount) {
            // Maksimal punch per hari tercapai
            if (writeLog) {
              final logRef = _logRef.doc();
              tx.set(logRef, {
                'id_user': userId,
                'doc_id': docId,
                'action': 'punch_ignored_max',
                'timestamp': serverNow,
                'count_after': currentCount,
                'meta': {'reason': 'max_reached'},
              });
            }
            return;
          }

          // Tambahkan waktu baru ke array
          final newCount = currentCount + 1;
          existingTimes.add(serverNow);

          tx.update(docRef, {
            'count': newCount,
            'times': existingTimes,
            'last_updated': serverNow,
          });

          if (writeLog) {
            final logRef = _logRef.doc();
            tx.set(logRef, {
              'id_user': userId,
              'doc_id': docId,
              'action': 'punch_increment',
              'timestamp': serverNow,
              'count_after': newCount,
            });
          }
        }
      });

      _setLoading(false);
      return true;
    } catch (e, st) {
      debugPrint('punch error: $e\n$st');
      _setLoading(false);
      return false;
    }
  }

  /// ✅ Tambah data manual
  Future<bool> addAbsen(AbsenModel absen) async {
    try {
      await _absenRef.add(absen.toMap());
      return true;
    } catch (e) {
      debugPrint('addAbsen error: $e');
      return false;
    }
  }

  /// ✅ Stream semua absen (misal untuk admin)
  Stream<List<AbsenModel>> streamAll() {
    return _absenRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AbsenModel.fromFirestore(doc)).toList();
    });
  }

  /// ✅ Ambil semua user dan nama panggilan
Future<Map<String, String>> getUserNames() async {
  final snap = await _userRef.get();
  return {
    for (var doc in snap.docs)
      doc.id: (doc.data() as Map<String, dynamic>?)?['panggilan']?.toString() ?? '-'
  };
}
 

  /// ✅ Stream absen hanya milik user tertentu
  Stream<List<AbsenModel>> streamByUser(String userId) {
    return _absenRef
        .where('idUser', isEqualTo: userId)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AbsenModel.fromFirestore(doc)).toList());
  }

  /// ✅ Update (misalnya koreksi waktu)
  Future<bool> updateAbsen(String docId, Map<String, dynamic> data) async {
    try {
      await _absenRef.doc(docId).update(data);
      return true;
    } catch (e) {
      debugPrint('updateAbsen error: $e');
      return false;
    }
  }

  /// ✅ Delete data absen
  Future<bool> deleteAbsen(String docId) async {
    try {
      await _absenRef.doc(docId).delete();
      return true;
    } catch (e) {
      debugPrint('deleteAbsen error: $e');
      return false;
    }
  }

  /// ✅ Ambil 1 dokumen berdasarkan ID
  Future<AbsenModel?> getAbsenById(String docId) async {
    try {
      final doc = await _absenRef.doc(docId).get();
      if (doc.exists) return AbsenModel.fromFirestore(doc);
      return null;
    } catch (e) {
      debugPrint('getAbsenById error: $e');
      return null;
    }
  }
}
