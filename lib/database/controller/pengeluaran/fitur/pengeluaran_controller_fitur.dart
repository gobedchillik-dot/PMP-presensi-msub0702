import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:tes_flutter/database/controller/pengeluaran/crud/pengeluaran_controller.dart';
// Asumsi ini adalah path ke file Repository
import 'package:tes_flutter/database/model/pengeluaran.dart';

class PengeluaranController extends ChangeNotifier {
  // Asumsi PengeluaranRepository berada di path yang terpisah
  final PengeluaranRepository _repository = PengeluaranRepository();
  
  StreamSubscription<List<Pengeluaran>>? _expenseSubscription; 

  List<Pengeluaran> _allExpenses = [];
  bool _isLoading = false; 

  List<Pengeluaran> get allExpenses => _allExpenses;
  
  // Getter ini bisa digunakan sebagai list detail cashflow untuk PDF
  List<Pengeluaran> get expenses => _allExpenses; 

  bool get isLoading => _isLoading;

  // Computed Property 1: Total Biaya Operasional (Hanya kategori 'Operasional')
  double get totalOperationalCost {
    return _allExpenses
        .where((e) => e.kategori == 'Operasional')
        .fold(0.0, (sum, expense) => sum + expense.nominal);
  }

  // Computed Property 2: Total Biaya Gaji (Hanya kategori 'Gaji')
  double get totalSalaryCost {
    return _allExpenses
        .where((e) => e.kategori == 'Gaji')
        .fold(0.0, (sum, expense) => sum + expense.nominal);
  }
  
  // 🔥 PERBAIKAN LOGIKA: Hanya hitung pengeluaran yang bukan Operasional dan bukan Gaji.
  // Ini menghindari double counting Gaji di KeuanganIndexPage.
  double get totalOtherExpenses {
    return _allExpenses
        .where((e) => e.kategori != 'Operasional' && e.kategori != 'Gaji') 
        .fold(0.0, (sum, expense) => sum + expense.nominal);
  }


  PengeluaranController() {
    _subscribeToExpenses(); 
  }

  void _subscribeToExpenses() {
    _isLoading = true;
    notifyListeners();
    
    _expenseSubscription?.cancel();

    // Pastikan Stream dari Repository sudah memfilter data berdasarkan bulan berjalan
    // Asumsi: fetchAllExpensesByMonthStream() sudah didefinisikan di Repository
    _expenseSubscription = _repository.fetchAllExpensesByMonthStream().listen(
      (dataList) {
        _allExpenses = dataList;
        
        if (_isLoading) {
          _isLoading = false;
        }

        notifyListeners(); 
      },
      onError: (e) {
        debugPrint("Error in expense stream: $e");
        _isLoading = false;
        notifyListeners();
      },
      onDone: () {
        debugPrint("Expense stream closed.");
      }
    );
  }
  
  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }


  // --- Metode CRUD ---

  Future<void> addExpense(Pengeluaran expense) async {
    try {
      await _repository.savePengeluaran(expense);
      // Stream akan update otomatis
    } catch (e) {
      debugPrint("Error saving expense: $e");
      throw Exception("Gagal menyimpan pengeluaran."); 
    }
  }

  // ⭐️ FUNGSI BARU: UPDATE
  Future<void> updateExpense(Pengeluaran expense) async {
    try {
      // Pastikan objek expense memiliki ID untuk diupdate
      if (expense.id == null) {
        throw Exception("ID pengeluaran tidak ditemukan untuk diperbarui.");
      }
      await _repository.updatePengeluaran(expense);
    } catch (e) {
      debugPrint("Error updating expense: $e");
      throw Exception("Gagal memperbarui pengeluaran.");
    }
  }

  // ⭐️ FUNGSI BARU: DELETE
  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deletePengeluaran(id);
    } catch (e) {
      debugPrint("Error deleting expense: $e");
      throw Exception("Gagal menghapus pengeluaran.");
    }
  }
}