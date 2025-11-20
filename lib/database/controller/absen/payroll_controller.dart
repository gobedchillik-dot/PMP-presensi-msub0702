// File: lib/database/controller/absen/payroll_controller.dart (Revisi Lengkap)

import 'dart:async'; 
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KOREKSI IMPOR: Menggunakan penamaan yang konsisten
import 'package:tes_flutter/database/model/unpaid_gaji.dart'; 
import 'package:tes_flutter/database/model/payroll.dart'; // Asumsi model payroll Anda bernama ini

class PayrollController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // --- KONSTANTA PERHITUNGAN GAJI ---
  static const double maxMonthlySalary = 2500000.0;
  static const int workingDaysInMonth = 30;
  static const int maxCountPerDay = 3;
  // Perhitungan gaji per count (misal: per jam kerja, jika 1 hari = 3 count)
  static const double valuePerCount = maxMonthlySalary / workingDaysInMonth / maxCountPerDay;

  // --- Stream Subscription ---
  StreamSubscription<QuerySnapshot>? _employeeStreamSubscription; 
  StreamSubscription<QuerySnapshot>? _absenStreamSubscription; 
  StreamSubscription<QuerySnapshot>? _payrollStreamSubscription; // 🚀 BARU: Listener untuk Payroll

  // --- State Variables ---
  List<UnpaidSalaryModel> _unpaidEmployeeList = []; 
  double _totalUnpaidSalary = 0.0; 
  bool _isLoading = false;

  // --- Getters ---
  List<UnpaidSalaryModel> get unpaidEmployeeList => _unpaidEmployeeList; 
  bool get isLoading => _isLoading;
  double get totalUnpaidSalary => _totalUnpaidSalary;

  PayrollController() {
    _listenToUnpaidEmployeeData(); 
    _listenToAbsenChanges(); 
    _listenToPayrollChanges(); // 🚀 BARU: Daftarkan listener Payroll
  }

  // =========================================================================
  // ⭐️ FUNGSI LISTENER (STREAM)
  // =========================================================================

  void _listenToUnpaidEmployeeData() {
    _isLoading = true;
    notifyListeners();
    
    _employeeStreamSubscription?.cancel();

    _employeeStreamSubscription = _db.collection('tbl_user')
        .where('role', isEqualTo: 'karyawan') 
        .snapshots()
        .listen(
          (employeeSnapshot) async { 
            List<UnpaidSalaryModel> results = []; 
            List<Future<void>> calculationFutures = [];
            double tempTotalSalary = 0.0; 

            for (var doc in employeeSnapshot.docs) {
              calculationFutures.add(_calculateEmployeeData(doc, results, (amount) {
                tempTotalSalary += amount; 
              }));
            }

            await Future.wait(calculationFutures);
            
            _totalUnpaidSalary = tempTotalSalary; 
            _unpaidEmployeeList = results;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint("Error listening to unpaid employee data: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void _listenToAbsenChanges() {
    _absenStreamSubscription?.cancel();
    
    _absenStreamSubscription = _db.collection('tbl_absen')
        .snapshots() 
        .listen(
          (_) {
            debugPrint("Perubahan terdeteksi di tbl_absen. Memuat ulang data gaji...");
            _listenToUnpaidEmployeeData(); 
          },
          onError: (error) {
            debugPrint("Error listening to tbl_absen changes: $error");
          },
        );
  }

  // 🚀 FUNGSI BARU: Mendengarkan perubahan di tbl_payroll
  void _listenToPayrollChanges() {
    _payrollStreamSubscription?.cancel();
    
    _payrollStreamSubscription = _db.collection('tbl_payroll')
        .snapshots() 
        .listen(
          (_) {
            debugPrint("Perubahan terdeteksi di tbl_payroll (Pembayaran Baru). Memuat ulang data gaji...");
            // Panggil ulang fungsi utama untuk perhitungan
            _listenToUnpaidEmployeeData(); 
          },
          onError: (error) {
            debugPrint("Error listening to tbl_payroll changes: $error");
          },
        );
  }


  // =========================================================================
  // ⭐️ FUNGSI PERHITUNGAN GAJI
  // =========================================================================

  Future<void> _calculateEmployeeData(
      DocumentSnapshot doc, 
      List<UnpaidSalaryModel> results, 
      void Function(double unpaidAmount) onAmountCalculated, 
    ) async {
    final data = doc.data() as Map<String, dynamic>?; 
    if (data == null) return; 

    final idUser = doc.id; 
    final userName = data['name'] as String? ?? 'Karyawan Tanpa Nama'; 

    final lastEndDate = await getLastPayrollEndDate(idUser);
    
    final totalUnpaidCounts = await _calculateUnpaidCounts(idUser, lastEndDate);
    
    final double unpaidAmount = totalUnpaidCounts * valuePerCount;

    if (totalUnpaidCounts > 0) {
      DateTime? periodStartDate;
      
      if (lastEndDate != null) {
        periodStartDate = lastEndDate.add(const Duration(days: 1)); 
      } else {
        periodStartDate = await _getFirstAbsenceDate(idUser);
      }
      
      final now = DateTime.now();
      final periodEndDate = DateTime(now.year, now.month, now.day); 

      if (periodStartDate != null) { 
        // KONVERSI KE MODEL
        results.add(
          UnpaidSalaryModel(
            idUser: idUser,
            userName: userName,
            totalUnpaidCounts: totalUnpaidCounts,
            unpaidAmount: unpaidAmount,
            periodStartDate: periodStartDate, 
            periodEndDate: periodEndDate,     
          ),
        );
        onAmountCalculated(unpaidAmount);
      }
    }
  }

  // =========================================================================
  // ⭐️ FUNGSI UTILITAS PENDUKUNG
  // =========================================================================

  /// Mendapatkan tanggal akhir periode pembayaran gaji terakhir (isPaid: true)
  Future<DateTime?> getLastPayrollEndDate(String idUser) async {
    try {
      final snapshot = await _db.collection('tbl_payroll')
          .where('idUser', isEqualTo: idUser)
          .where('isPaid', isEqualTo: true) 
          .orderBy('periodEndDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final Timestamp? timestamp = data['periodEndDate'] as Timestamp?;
        
        if (timestamp != null) {
            return timestamp.toDate();
        }
      }
      return null;
    } catch (e) {
      debugPrint("Gagal mendapatkan last payroll end date: $e");
      return null;
    }
  }

  /// Menghitung total count absen (SUM dari field 'count') yang belum dibayar
  Future<int> _calculateUnpaidCounts(String idUser, DateTime? lastEndDate) async {
    Query query = _db.collection('tbl_absen')
        .where('idUser', isEqualTo: idUser);

    if (lastEndDate != null) {
      query = query.where('tanggal', isGreaterThan: lastEndDate);
    }

    try {
      final snapshot = await query.get();
      
      int totalCountSum = 0;
      
      for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final countValue = (data['count'] as num?)?.toInt() ?? 0;
          totalCountSum += countValue;
      }
      
      return totalCountSum;
    } catch (e) {
      debugPrint("Gagal menghitung unpaid counts: $e");
      return 0;
    }
  }

  /// Mendapatkan tanggal absen pertama jika karyawan belum pernah dibayar (lastEndDate == null)
  Future<DateTime?> _getFirstAbsenceDate(String idUser) async {
    try {
      final snapshot = await _db.collection('tbl_absen')
          .where('idUser', isEqualTo: idUser)
          .orderBy('tanggal', descending: false)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final Timestamp? timestamp = data['tanggal'] as Timestamp?;
        
        if (timestamp != null) {
            final DateTime date = timestamp.toDate();
            return DateTime(date.year, date.month, date.day); 
        }
      }
      return null;
    } catch (e) {
      debugPrint("Gagal mendapatkan first absence date: $e");
      return null;
    }
  }


  // =========================================================================
  // ⭐️ FUNGSI Aksi Pembayaran
  // =========================================================================

  Future<void> processPayment({
      required UnpaidSalaryModel payrollData, 
  }) async {
      try {
          final newPayrollRecord = AbsenPayrollModel(
            idUser: payrollData.idUser,
            periodStartDate: Timestamp.fromDate(payrollData.periodStartDate),
            periodEndDate: Timestamp.fromDate(payrollData.periodEndDate),
            isPaid: true, 
            paymentDate: Timestamp.now(),
            amountPaid: payrollData.unpaidAmount,
            totalDaysPresent: payrollData.totalUnpaidCounts, 
          );

          await _db.collection('tbl_payroll').add(newPayrollRecord.toMap());
          
          debugPrint("Pembayaran gaji untuk ${payrollData.userName} berhasil dicatat.");
          
          // ⚠️ KOREKSI: Panggil ulang pembaruan data setelah aksi pembayaran selesai
          // Ini berfungsi sebagai fallback cepat, meskipun stream listener juga akan terpicu
          _listenToUnpaidEmployeeData(); 
          
      } catch (e) {
          throw Exception("Gagal memproses pembayaran: $e");
      }
  }
  
  @override
  void dispose() {
    _employeeStreamSubscription?.cancel();
    _absenStreamSubscription?.cancel(); 
    _payrollStreamSubscription?.cancel(); // 🚀 BARU: Batalkan listener Payroll
    super.dispose();
  }
}