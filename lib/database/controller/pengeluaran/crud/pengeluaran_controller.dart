// File: lib/database/repository/pengeluaran_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes_flutter/database/model/pengeluaran.dart';

class PengeluaranRepository {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tbl_pengeluaran'; 

  /// Metode inti: Mengambil SEMUA pengeluaran untuk periode bulan ini.
  Future<List<Pengeluaran>> fetchAllExpensesByMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59); // Akhir bulan
    
    try {
      // Menggunakan Range Query pada Timestamp (Filter Firestore yang Efisien)
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(_collectionName)
        .where('tanggal', isGreaterThanOrEqualTo: startOfMonth) // Ambil data mulai tgl 1
        .where('tanggal', isLessThanOrEqualTo: endOfMonth)     // Sampai akhir bulan
        .get();
        
      List<Pengeluaran> expenses = snapshot.docs.map((doc) {
        return Pengeluaran.fromMap(doc.id, doc.data());
      }).toList();

      return expenses;

    } catch (e) {
      print("FIREBASE ERROR (fetchAllExpensesByMonth): $e");
      throw Exception("Gagal mengambil data pengeluaran bulanan."); 
    }
  }

  /// [DEPRECATED] Ganti logika fetchOperationalExpenses untuk menggunakan fetchAllExpensesByMonth
  // Hapus atau perbarui jika masih ada yang menggunakannya. 
  // Untuk saat ini kita buat deprecated dan dilempar (throw error) jika dipanggil
  @Deprecated('Gunakan fetchAllExpensesByMonth() dan lakukan filter di Controller.')
  Future<List<Pengeluaran>> fetchOperationalExpenses() async {
    throw UnimplementedError("fetchOperationalExpenses sudah usang dan diganti fetchAllExpensesByMonth");
  }


  // --- Metode CRUD Tetap Sama (Menggunakan ID dan toMap) ---

  Future<void> savePengeluaran(Pengeluaran expense) async {
    try {
      await _firestore.collection(_collectionName).add(expense.toMap()); 
    } catch (e) {
      throw Exception("Gagal menyimpan pengeluaran: $e");
    }
  }
  
  Future<void> updatePengeluaran(Pengeluaran expense) async {
    if (expense.id == null || expense.id!.isEmpty) {
      throw Exception("ID pengeluaran tidak boleh kosong untuk pembaruan.");
    }
    try {
      await _firestore.collection(_collectionName).doc(expense.id).update(expense.toMap());
    } catch (e) {
      throw Exception("Gagal memperbarui pengeluaran: $e");
    }
  }
  
  Future<void> deletePengeluaran(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception("Gagal menghapus pengeluaran: $e");
    }
  }
}