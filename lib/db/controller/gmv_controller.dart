import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/gmv.dart'; 

class GmvController with ChangeNotifier {
  // 1. Inisialisasi Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tbl_gmv';

  // State untuk melacak status loading operasi tulis (store, update, destroy)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- Fungsi READ (Index/Show) Menggunakan STREAM ---

  // Index (REALTIME READ: Mengambil semua data GMV secara REALTIME)
  // Ini setara dengan index() pada Controller Laravel, tetapi bersifat realtime
  Stream<List<GmvModel>> get gmvStream {
    return _firestore.collection(_collectionName)
        // Gunakan withConverter untuk konversi otomatis menggunakan GmvModel.fromFirestore
        .withConverter<GmvModel>(
          fromFirestore: GmvModel.fromFirestore,
          toFirestore: (gmv, _) => gmv.toFirestore(),
        )
        .orderBy('tanggal', descending: true) // Urutkan data terbaru di atas
        .snapshots() // Mengaktifkan mode realtime (Stream)
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
        // .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList()) akan otomatis mengembalikan List<GmvModel>
  }
  
  // Show/Edit (READ ONE: Mengambil satu data GMV, menggunakan Future/GET)
  Future<GmvModel?> show(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return GmvModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching single GMV data: $e');
      return null;
    }
  }


  // --- Fungsi WRITE (Store/Update/Destroy) ---

  // Store (CREATE: Menyimpan data GMV baru)
  Future<bool> store({required double gmv, required DateTime tanggal}) async {
    _setLoading(true);
    try {
      final newGmv = GmvModel(
        id: '', // ID akan diabaikan saat menulis, Firestore akan membuat Document ID
        gmv: gmv,
        tanggal: Timestamp.fromDate(tanggal),
      );

      // Tambahkan dokumen baru ke koleksi
      await _firestore.collection(_collectionName).add(newGmv.toFirestore());
      
      _setLoading(false);
      return true; // Berhasil

    } catch (e) {
      debugPrint('Error creating GMV data: $e');
      _setLoading(false);
      return false; // Gagal
    }
  }

  // Update (UPDATE: Memperbarui data GMV yang sudah ada)
  Future<bool> update(GmvModel gmvToUpdate) async {
    _setLoading(true);
    try {
      // Perbarui dokumen berdasarkan ID-nya
      await _firestore.collection(_collectionName)
          .doc(gmvToUpdate.id)
          .update(gmvToUpdate.toFirestore());
      
      _setLoading(false);
      return true;
      
    } catch (e) {
      debugPrint('Error updating GMV data: $e');
      _setLoading(false);
      return false;
    }
  }

  // Destroy (DELETE: Menghapus data GMV)
  Future<bool> destroy(String id) async {
    _setLoading(true);
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Error deleting GMV data: $e');
      _setLoading(false);
      return false;
    }
  }

  //fungsi untuk ngambil total GMV - kebutuhan halaman index
    // --- Fungsi untuk menghitung total seluruh GMV ---
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

      debugPrint('Total GMV: $total');
      return total;
    } catch (e) {
      debugPrint('Error calculating total GMV: $e');
      return 0.0;
    }
  }



}