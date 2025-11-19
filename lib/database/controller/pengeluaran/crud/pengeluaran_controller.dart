import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes_flutter/database/model/pengeluaran.dart';

class PengeluaranRepository {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tbl_pengeluaran'; 

  /// Metode inti: Mengambil SEMUA pengeluaran untuk periode bulan ini
  /// sebagai **Stream** agar data selalu diperbarui secara real-time.
  Stream<List<Pengeluaran>> fetchAllExpensesByMonthStream() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    // Akhir bulan (Perhatikan: kita tambahkan 1 bulan, lalu gunakan hari ke-0. 
    // Ini adalah cara rapi untuk mendapatkan hari terakhir bulan sebelumnya.)
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59); 
    
    // Perubahan Kunci: Mengganti .get() menjadi .snapshots()
    return _firestore
        .collection(_collectionName)
        .where('tanggal', isGreaterThanOrEqualTo: startOfMonth) // Ambil data mulai tgl 1
        .where('tanggal', isLessThanOrEqualTo: endOfMonth)     // Sampai akhir bulan
        .snapshots() // <<< INI YANG MEMBUATNYA MENJADI STREAM
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          // Mapping data ke List<Pengeluaran> setiap kali ada perubahan di DB
          List<Pengeluaran> expenses = snapshot.docs.map((doc) {
            // Kita juga bisa menambahkan pengurutan di sisi klien jika perlu,
            // tapi pengurutan yang lebih baik dilakukan di query Firestore (e.g., .orderBy('tanggal', descending: true))
            return Pengeluaran.fromMap(doc.id, doc.data());
          }).toList();
          
          return expenses;
        })
        .handleError((e) {
          // Penanganan error pada Stream
          print("FIREBASE ERROR (fetchAllExpensesByMonthStream): $e");
          // Dalam konteks Stream, kita bisa melempar error, namun biasanya 
          // StreamBuilder di UI yang menangani error tersebut.
          throw Exception("Gagal mendapatkan stream data pengeluaran bulanan.");
        });
  }
  
  // Catatan: Fungsi Future<List<Pengeluaran>> yang lama sudah saya hapus
  // atau ganti namanya menjadi fetchAllExpensesByMonthStream() agar tidak ada kebingungan.
  
  /// [DEPRECATED] Hapus atau perbarui jika masih ada yang menggunakannya. 
  @Deprecated('Gunakan fetchAllExpensesByMonthStream() dan lakukan filter di Controller/View Model.')
  Future<List<Pengeluaran>> fetchOperationalExpenses() async {
    throw UnimplementedError("fetchOperationalExpenses sudah usang dan diganti fetchAllExpensesByMonthStream");
  }


  // --- Metode CRUD Tetap Sama (Menggunakan ID dan toMap) ---

  Future<void> savePengeluaran(Pengeluaran expense) async {
    try {
      // Data disimpan, dan Firestore akan otomatis memancarkan data baru
      // melalui stream fetchAllExpensesByMonthStream().
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