import 'package:flutter/foundation.dart';
import 'gmv/gmv_controller.dart';
import 'pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'absen/payroll_controller.dart';

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
    //          CASH IN
    // ============================

    // Hitung total GMV mingguan
    double weeklyTotal = 0.0;
    try {
      weeklyTotal = weekly.fold(0.0, (sum, item) {
        final val = (item is Map ? item['total'] : item.total);
        return sum + ((val is num) ? val.toDouble() : 0.0);
      });
    } catch (_) {}

    _cashIn = (weeklyTotal*5)/100;

    // ============================
    //          CASH OUT
    // ============================

    _cashOut = pengeluaranController!.totalOperationalCost +
        pengeluaranController!.totalSalaryCost +
        pengeluaranController!.totalOtherExpenses +
        payrollController!.totalUnpaidSalary;

    // ============================
    //          NET
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
