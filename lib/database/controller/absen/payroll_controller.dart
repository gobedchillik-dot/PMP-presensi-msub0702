// File: lib/database/controller/absen/payroll_controller.dart

import 'dart:async'; 
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes_flutter/database/model/payroll.dart'; // Pastikan model ini ada

class PayrollController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // --- KONSTANTA PERHITUNGAN GAJI ---
  static const double maxMonthlySalary = 2500000.0;
  static const int workingDaysInMonth = 30;
  static const int maxCountPerDay = 3;
  // Rumus: (2.500.000 / 30) / 3
  static const double valuePerCount = maxMonthlySalary / workingDaysInMonth / maxCountPerDay;

  // --- Stream Subscription ---
  StreamSubscription<QuerySnapshot>? _employeeStreamSubscription; 
  StreamSubscription<QuerySnapshot>? _absenStreamSubscription; 

  // --- State Variables ---
  List<Map<String, dynamic>> _unpaidEmployeeList = [];
  
  //   VARIABEL BARU UNTUK MENYIMPAN TOTAL GAJI
  double _totalUnpaidSalary = 0.0; 
  
  bool _isLoading = false;

  // --- Getters ---
  List<Map<String, dynamic>> get unpaidEmployeeList => _unpaidEmployeeList;
  bool get isLoading => _isLoading;
  
  //   GETTER BARU
  double get totalUnpaidSalary => _totalUnpaidSalary;

  // --- Constructor ---
  PayrollController() {
    // Memulai langganan data saat controller dibuat
    _listenToUnpaidEmployeeData(); 
    _listenToAbsenChanges(); 
  }

  // =========================================================================
  // ⭐️ FUNGSI LISTENER (STREAM)
  // =========================================================================

  /// Mendengarkan perubahan pada tbl_user (daftar karyawan)
  void _listenToUnpaidEmployeeData() {
    _isLoading = true;
    notifyListeners();
    
    _employeeStreamSubscription?.cancel();

    _employeeStreamSubscription = _db.collection('tbl_user')
        .where('role', isEqualTo: 'karyawan') 
        .snapshots()
        .listen(
          (employeeSnapshot) async { 
            List<Map<String, dynamic>> results = [];
            List<Future<void>> calculationFutures = [];
            double tempTotalSalary = 0.0; // Inisialisasi penghitung sementara

            for (var doc in employeeSnapshot.docs) {
              calculationFutures.add(_calculateEmployeeData(doc, results, (amount) {
                // Callback untuk menambahkan ke total gaji
                tempTotalSalary += amount; 
              }));
            }

            // Menunggu semua perhitungan selesai secara paralel
            await Future.wait(calculationFutures);
            
            // PERBARUI STATE TOTAL GAJI
            _totalUnpaidSalary = tempTotalSalary; 
            
            _unpaidEmployeeList = results;
            _isLoading = false;
            notifyListeners();
          },
          // Perbaikan ERROR: onError dimasukkan sebagai parameter bernama
          onError: (error) {
            debugPrint("Error listening to unpaid employee data: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Mendengarkan perubahan pada tbl_absen (memicu refresh data gaji)
  void _listenToAbsenChanges() {
    _absenStreamSubscription?.cancel();
    
    _absenStreamSubscription = _db.collection('tbl_absen')
        .snapshots() 
        .listen(
          (_) {
            debugPrint("Perubahan terdeteksi di tbl_absen. Memuat ulang data gaji...");
            // Memanggil ulang logika perhitungan karyawan
            _listenToUnpaidEmployeeData(); 
          },
          // Perbaikan ERROR: onError dimasukkan sebagai parameter bernama
          onError: (error) {
            debugPrint("Error listening to tbl_absen changes: $error");
          },
        );
  }

  // =========================================================================
  // ⭐️ FUNGSI PERHITUNGAN GAJI
  // =========================================================================

  Future<void> _calculateEmployeeData(
      DocumentSnapshot doc, 
      List<Map<String, dynamic>> results,
      // Tambahkan callback untuk mengumpulkan total
      void Function(double unpaidAmount) onAmountCalculated, 
    ) async {
    final data = doc.data() as Map<String, dynamic>?; 
    if (data == null) return; 

    final userId = doc.id;
    final userName = data['name'] ?? 'Karyawan Tanpa Nama';

    final lastEndDate = await getLastPayrollEndDate(userId);
    
    final totalUnpaidCounts = await _calculateUnpaidCounts(userId, lastEndDate);
    
    final double unpaidAmount = totalUnpaidCounts * valuePerCount;

    if (totalUnpaidCounts > 0) {
      results.add({
        'userId': userId,
        'userName': userName,
        'totalUnpaidCounts': totalUnpaidCounts,
        'unpaidAmount': unpaidAmount,
        'newPeriodStartDate': lastEndDate != null 
            ? lastEndDate.add(const Duration(days: 1)) 
            : await _getFirstAbsenceDate(userId), 
      });
      // Panggil callback untuk menambahkan ke total
      onAmountCalculated(unpaidAmount);
    }
  }

  /// Override dispose untuk membersihkan semua stream
  @override
  void dispose() {
    _employeeStreamSubscription?.cancel();
    _absenStreamSubscription?.cancel(); 
    super.dispose();
  }
  
  // =========================================================================
  // FUNGSI UTILITAS
  // =========================================================================

  /// 1. Mengambil Tanggal Akhir Pembayaran Gaji Terakhir
  Future<DateTime?> getLastPayrollEndDate(String userId) async {
    try {
      final snapshot = await _db.collection('tbl_payroll')
          .where('idUser', isEqualTo: userId)
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
      debugPrint("Error fetching last payroll end date for $userId: $e");
      return null;
    }
  }

  /// 2. Menghitung Total Jumlah Count Absensi yang Belum Dibayar
  Future<int> _calculateUnpaidCounts(String userId, DateTime? lastEndDate) async {
    DateTime startDate;
    
    if (lastEndDate == null) {
      final firstAbsenDate = await _getFirstAbsenceDate(userId);
      if (firstAbsenDate == null) {
        return 0;
      }
      startDate = firstAbsenDate;
      
    } else {
      startDate = lastEndDate.add(const Duration(days: 1));
    }

    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final absenSnapshot = await _db.collection('tbl_absen')
        .where('idUser', isEqualTo: userId)
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    int totalUnpaidCounts = 0;
    for (var doc in absenSnapshot.docs) {
        // Perbaikan null safety
      final count = (doc.data()['count'] as num?)?.toInt() ?? 0;
      totalUnpaidCounts += count; 
    }

    return totalUnpaidCounts;
  }
  
  /// 3. Fungsi Pembantu untuk mendapatkan tanggal absen paling awal
  Future<DateTime?> _getFirstAbsenceDate(String userId) async {
    try {
      final firstAbsenSnapshot = await _db.collection('tbl_absen')
          .where('idUser', isEqualTo: userId)
          .orderBy('tanggal', descending: false)
          .limit(1)
          .get();
      
      if (firstAbsenSnapshot.docs.isEmpty) return null;

      // Perbaikan null safety
      final date = firstAbsenSnapshot.docs.first.data()['tanggal']?.toDate();
      if (date == null) return null;
      
      return DateTime(date.year, date.month, date.day);

    } catch (e) {
        debugPrint("Error fetching first absence date: $e");
        return null;
    }
  }


  Future<void> processPayment({
    required String userId,
    required double amount,
    required int totalCounts,
    required DateTime newStartDate,
  }) async {
      // Implementasi akan dilakukan di langkah berikutnya
      return;
  }
}