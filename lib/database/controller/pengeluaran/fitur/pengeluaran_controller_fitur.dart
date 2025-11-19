import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:tes_flutter/database/controller/pengeluaran/crud/pengeluaran_controller.dart';
import 'package:tes_flutter/database/model/pengeluaran.dart';

class PengeluaranController extends ChangeNotifier {
  final PengeluaranRepository _repository = PengeluaranRepository();
  
  StreamSubscription<List<Pengeluaran>>? _expenseSubscription; 

  List<Pengeluaran> _allExpenses = [];
  bool _isLoading = false; 

  List<Pengeluaran> get allExpenses => _allExpenses;
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
  
  // Computed Property 3: Total Pengeluaran Lainnya (Misal: 'Pajak', 'Marketing')
  double get totalOtherExpenses {
    return _allExpenses
        .where((e) => e.kategori != 'Operasional')
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
    _expenseSubscription = _repository.fetchAllExpensesByMonthStream().listen(
      (dataList) {
        _allExpenses = dataList;
        
        if (_isLoading) {
          _isLoading = false;
        }

        notifyListeners(); 
      },
      onError: (e) {
        print("Error in expense stream: $e");
        _isLoading = false;
        notifyListeners();
      },
      onDone: () {
        print("Expense stream closed.");
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
      print("Error saving expense: $e");
      throw Exception("Gagal menyimpan pengeluaran."); 
    }
  }

  // ⭐️ FUNGSI BARU: UPDATE
  Future<void> updateExpense(Pengeluaran expense) async {
    // Perlu ada fungsi update di Repository: _repository.updatePengeluaran(expense);
    // Asumsi sudah ada, jika tidak, tolong tambahkan
    try {
      await _repository.updatePengeluaran(expense);
    } catch (e) {
      print("Error updating expense: $e");
      throw Exception("Gagal memperbarui pengeluaran.");
    }
  }

  // ⭐️ FUNGSI BARU: DELETE
  Future<void> deleteExpense(String id) async {
    // Perlu ada fungsi delete di Repository: _repository.deletePengeluaran(id);
    // Asumsi sudah ada, jika tidak, tolong tambahkan
    try {
      await _repository.deletePengeluaran(id);
    } catch (e) {
      print("Error deleting expense: $e");
      throw Exception("Gagal menghapus pengeluaran.");
    }
  }
}