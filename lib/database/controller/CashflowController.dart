import 'package:flutter/foundation.dart';
import 'gmv/gmv_controller.dart';
import 'pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'absen/payroll_controller.dart';

// Asumsi: Anda memiliki model class untuk data cashflow jika ingin lebih rapi.
// Untuk saat ini, kita akan menggunakan Map<String, dynamic> seperti yang Anda siapkan untuk PDF.

class CashflowController extends ChangeNotifier {
  GmvController? gmvController;
  PengeluaranController? pengeluaranController;
  PayrollController? payrollController;

  double _cashIn = 0.0;
  double _cashOut = 0.0;
  double _netCashflow = 0.0;

  double get cashIn => _cashIn;
  double get cashOut => _cashOut;
  double get netCashflow => _netCashflow;

  /// GMV mingguan
  List get weekly => gmvController?.weeklySummary ?? [];

  CashflowController();

  // =============================================
  // === GETTER: HISTORI CASHFLOW GABUNGAN
  // =============================================
  List<Map<String, dynamic>> get cashflowHistory {
    final historyList = <Map<String, dynamic>>[];

    // 1. GMV/Income (IN)
    // PENTING: Gunakan data GMV harian/transaksi jika ada,
    // Jika hanya ada summary mingguan, kita gunakan itu sebagai representasi.
    // Jika item.total adalah GMV Harian/Mingguan, asumsikan ini adalah 'Cash In'.
    for (final w in gmvController?.weeklySummary ?? []) {
      // Pastikan data yang digunakan untuk GMV konsisten dengan total GMV mingguan
      try {
        historyList.add({
          // Karena ini summary mingguan, kita gunakan rentang tanggal atau tanggal akhir minggu
          'tanggal': w.dateRange, 
          'deskripsi': 'Pemasukan GMV Minggu ke-${w.mingguKe}',
          'kategori': 'GMV',
          'nominal': w.total as double,
          'tipe': 'IN',
        });
      } catch (_) {}
    }

    // 2. Operational & Other Expenses (OUT)
    if (pengeluaranController?.allExpenses != null) {
      for (final e in pengeluaranController!.allExpenses) {
        historyList.add({
          // Asumsi: 'e' memiliki properti tanggal, deskripsi, kategori, dan nominal
          'tanggal': e.tanggal,
          'deskripsi': e.deskripsi,
          'kategori': e.kategori,
          'nominal': e.nominal,
          'tipe': 'OUT',
        });
      }
    }

    // 3. Unpaid Salaries (OUT)
    final Iterable<dynamic> unpaidSalaryRecords =
        payrollController?.totalUnpaidSalary is Iterable
            ? payrollController!.totalUnpaidSalary as Iterable<dynamic>
            : [];

    if (unpaidSalaryRecords.isNotEmpty) {
      for (final s in unpaidSalaryRecords) {
        historyList.add({
          // Asumsi: 's' memiliki properti tanggal, employeeName, salaryAmount
          'tanggal': s.tanggal,
          'deskripsi': 'Gaji: ${s.employeeName}',
          'kategori': 'Gaji Karyawan',
          'nominal': s.salaryAmount as double,
          'tipe': 'OUT',
        });
      }
    }

    // Sortir berdasarkan tanggal (Descending)
    // PENTING: Jika 'tanggal' adalah String, Anda perlu parsing ke DateTime untuk sorting yang benar.
    // Asumsi: Data memiliki properti 'tanggal' yang bisa dibandingkan (String format ISO/DateTime Object).
    historyList.sort((a, b) {
      final dateA = a['tanggal'] is String ? DateTime.parse(a['tanggal']) : (a['tanggal'] as DateTime);
      final dateB = b['tanggal'] is String ? DateTime.parse(b['tanggal']) : (b['tanggal'] as DateTime);
      return dateB.compareTo(dateA); // Terbaru di atas
    });

    return historyList;
  }
  // =============================================

  /// Dipanggil dengan ProxyProvider.update
  void updateSources(
    GmvController gmv,
    PengeluaranController pengeluaran,
    PayrollController payroll,
  ) {
    // Remove listener lama
    gmvController?.removeListener(_recalculate);
    pengeluaranController?.removeListener(_recalculate);
    payrollController?.removeListener(_recalculate);

    // Assign controller baru
    gmvController = gmv;
    pengeluaranController = pengeluaran;
    payrollController = payroll;

    // Pasang listener baru
    gmvController?.addListener(_recalculate);
    pengeluaranController?.addListener(_recalculate);
    payrollController?.addListener(_recalculate);

    _recalculate();
  }

  void _recalculate() {
    if (gmvController == null ||
        pengeluaranController == null ||
        payrollController == null) {
      return;
    }

    // ============================
    //          CASH IN
    // ============================

    // Hitung total GMV mingguan (Digunakan sebagai Est. Pemasukan Net Profit 5%)
    double weeklyTotal = 0.0;
    try {
      weeklyTotal = weekly.fold(0.0, (sum, item) {
        final val = (item is Map ? item['total'] : item.total);
        return sum + ((val is num) ? val.toDouble() : 0.0);
      });
    } catch (_) {}

    _cashIn = (weeklyTotal * 5) / 100; // Est. Profit Margin

    // ============================
    //          CASH OUT
    // ============================

    // Total pengeluaran yang sudah dihitung di PengeluaranController
    _cashOut = pengeluaranController!.totalOperationalCost +
        pengeluaranController!.totalSalaryCost +
        pengeluaranController!.totalOtherExpenses +
        payrollController!.totalUnpaidSalary;

    // ============================
    //          NET
    // ============================

    _netCashflow = _cashIn - _cashOut;

    notifyListeners();
  }

  @override
  void dispose() {
    gmvController?.removeListener(_recalculate);
    pengeluaranController?.removeListener(_recalculate);
    payrollController?.removeListener(_recalculate);
    super.dispose();
  }
}