import 'dart:async'; // Tambahkan ini
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// =========================================================================
// ASUMSI MODEL
// =========================================================================

/// Model sederhana untuk mewakili dokumen payroll (tbl_payroll).
class AbsenPayrollModel {
  final Timestamp periodEndDate;

  AbsenPayrollModel({required this.periodEndDate});

  factory AbsenPayrollModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return AbsenPayrollModel(
      periodEndDate: data?['periodEndDate'] ?? Timestamp.now(), 
    );
  }
}

// =========================================================================
// KELAS UTAMA: GMV CONTROLLER EXTRA (REAL-TIME AWARE)
// =========================================================================

class GmvControllerExtra extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tbl_gmv';
  final String _absenCollection = 'tbl_absen';
  final String _payrollCollection = 'tbl_payroll'; 

  // --- REAL-TIME STATE DAN SUBSCRIPTIONS ---
  String? _currentUserId;
  int _unpaidCounts = 0;
  
  /// Nilai yang didengarkan oleh widget melalui context.watch
  int get unpaidCounts => _unpaidCounts; 

  StreamSubscription? _absenSubscription;
  StreamSubscription? _payrollSubscription;
  // ------------------------------------------


  /// -----------------------------------------------------------------------
  /// INI PENTING: Menginisialisasi listener real-time untuk pembaruan UI
  /// -----------------------------------------------------------------------
  void initializeRealTimeListeners(String userId) {
    if (_currentUserId == userId) return; // Hindari inisialisasi ganda
    _currentUserId = userId;

    // Batalkan subscription lama sebelum membuat yang baru
    _absenSubscription?.cancel();
    _payrollSubscription?.cancel();
    
    // 1a. Listen pada perubahan di tbl_absen
    _absenSubscription = _firestore
        .collection(_absenCollection)
        .where('idUser', isEqualTo: userId)
        .snapshots() // Mendengarkan secara real-time
        .listen((_) {
      debugPrint("Perubahan terdeteksi di tbl_absen. Memuat ulang Unpaid Counts...");
      _fetchAndUpdateCounts(userId);
    });

    // 1b. Listen pada perubahan di tbl_payroll
    _payrollSubscription = _firestore
        .collection(_payrollCollection)
        .where('idUser', isEqualTo: userId)
        .snapshots() // Mendengarkan secara real-time
        .listen((_) {
      debugPrint("Perubahan terdeteksi di tbl_payroll. Memuat ulang Unpaid Counts...");
      _fetchAndUpdateCounts(userId);
    });

    // Panggil sekali saat inisialisasi agar data segera muncul
    _fetchAndUpdateCounts(userId);
  }

  /// Memuat data Unpaid Counts dan memicu notifyListeners jika ada perubahan.
  Future<void> _fetchAndUpdateCounts(String userId) async {
    final lastEndDate = await getLastPayrollEndDate(userId);
    final newCounts = await calculateUnpaidCounts(userId, lastEndDate);

    if (_unpaidCounts != newCounts) {
      _unpaidCounts = newCounts;
      notifyListeners(); // Memberi tahu widget untuk rebuild
    }
  }
  
  // JANGAN LUPA CANCEL SUBSCRIPTIONS saat Controller dibuang
  @override
  void dispose() {
    _absenSubscription?.cancel();
    _payrollSubscription?.cancel();
    super.dispose();
  }


  // -----------------------------------------------------------------------
  // 1. FUNGSI GMV ASLI (Tidak Berubah)
  // -----------------------------------------------------------------------

  /// Menghitung total keseluruhan nilai GMV dari koleksi 'tbl_gmv'.
  Future<double> getTotalGmv() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('gmv')) {
          final value = data['gmv'];
          if (value is num) {
            total += value.toDouble();
          }
        }
      }
      return total;
    } catch (e) {
      debugPrint("Error getting total GMV: $e");
      return 0.0;
    }
  }

  // -----------------------------------------------------------------------
  // 2. FUNGSI UNPAID COUNTS (Logika Tetap Sama)
  // -----------------------------------------------------------------------

  /// Menghitung Total Jumlah Count Absensi yang Belum Dibayar.
  Future<int> calculateUnpaidCounts(String idUser, DateTime? lastEndDate) async {
    DateTime startDate;
    
    if (lastEndDate == null) {
      final firstAbsenDate = await _getFirstAbsenceDate(idUser);
      if (firstAbsenDate == null) {
        return 0;
      }
      startDate = firstAbsenDate;
    } else {
      startDate = lastEndDate.add(const Duration(days: 1));
    }

    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    try {
        final absenSnapshot = await _firestore.collection(_absenCollection)
            .where('idUser', isEqualTo: idUser)
            .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .where('count', isGreaterThan: 0)     
            .where('count', isLessThanOrEqualTo: 3) 
            .get();

        int totalUnpaidCounts = 0;
        for (var doc in absenSnapshot.docs) {
            final count = (doc.data()['count'] as num?)?.toInt() ?? 0;
            totalUnpaidCounts += count; 
        }

        return totalUnpaidCounts;
    } catch (e) {
        debugPrint("Error calculating unpaid counts for $idUser: $e");
        return 0;
    }
  }

  // -----------------------------------------------------------------------
  // 3. FUNGSI UTILITAS (Logika Tetap Sama)
  // -----------------------------------------------------------------------

  /// Mengambil Tanggal Akhir Pembayaran Gaji Terakhir.
  Future<DateTime?> getLastPayrollEndDate(String idUser) async {
    try {
      final snapshot = await _firestore.collection(_payrollCollection)
          .where('idUser', isEqualTo: idUser)
          .orderBy('periodEndDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null; 
      }

      final payrollDoc = AbsenPayrollModel.fromFirestore(snapshot.docs.first);
      final lastEndDate = payrollDoc.periodEndDate.toDate();

      return DateTime(lastEndDate.year, lastEndDate.month, lastEndDate.day);

    } catch (e) {
      debugPrint("Error fetching last payroll end date for $idUser: $e");
      return null;
    }
  }

  /// Fungsi Pembantu untuk mendapatkan tanggal absen paling awal.
  Future<DateTime?> _getFirstAbsenceDate(String idUser) async {
    try {
      final firstAbsenSnapshot = await _firestore.collection(_absenCollection)
          .where('idUser', isEqualTo: idUser)
          .orderBy('tanggal', descending: false)
          .limit(1)
          .get();
      
      if (firstAbsenSnapshot.docs.isEmpty) return null;

      final date = firstAbsenSnapshot.docs.first.data()['tanggal']?.toDate();
      if (date == null) return null;
      
      return DateTime(date.year, date.month, date.day);

    } catch (e) {
        debugPrint("Error fetching first absence date: $e");
        return null;
    }
  }
}