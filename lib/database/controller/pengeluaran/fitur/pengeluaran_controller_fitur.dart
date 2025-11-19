// File: lib/controllers/pengeluaran_controller.dart

import 'package:flutter/material.dart';
import 'package:tes_flutter/database/controller/pengeluaran/crud/pengeluaran_controller.dart';
import 'package:tes_flutter/database/model/pengeluaran.dart';

class PengeluaranController extends ChangeNotifier {
  
  final PengeluaranRepository _repository = PengeluaranRepository();

  // State BARU: Menyimpan semua pengeluaran yang diambil
  List<Pengeluaran> _allExpenses = [];
  bool _isLoading = false;

  // Getters (Akses data untuk UI)
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
    // Semua yang bukan Operasional atau Gaji
    return _allExpenses
        .where((e) => e.kategori != 'Operasional' && e.kategori != 'Gaji')
        .fold(0.0, (sum, expense) => sum + expense.nominal);
  }


  PengeluaranController() {
    fetchData(); 
  }

  // Logic: Mengambil SEMUA data pengeluaran bulanan
  Future<void> fetchData() async {
    if (_isLoading) return; 

    _isLoading = true;
    notifyListeners(); 

    try {
      // Panggil metode repository yang baru
      final List<Pengeluaran> result = await _repository.fetchAllExpensesByMonth();

      // Simpan semua data di state
      _allExpenses = result;

    } catch (e) {
      print("Error fetching all expenses: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  // --- Metode CRUD (Refresh data setelah operasi) ---

  Future<void> addExpense(Pengeluaran expense) async {
    try {
      await _repository.savePengeluaran(expense);
      await fetchData(); // Refresh data untuk update UI
    } catch (e) {
      print("Error saving expense: $e");
      // throw e; // Lempar error untuk ditangani oleh UI
    }
  }
}