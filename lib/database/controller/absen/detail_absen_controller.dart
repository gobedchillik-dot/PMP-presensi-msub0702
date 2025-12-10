import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../model/absen.dart'; // Sesuaikan path model Anda

class DetailAbsenController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tbl_absen'; 
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  AbsenModel? _absenData;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  StreamSubscription<DocumentSnapshot>? _absenSubscription;

  // --- GETTERS ---
  AbsenModel? get absenData => _absenData;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  DetailAbsenController() {
    // Pastikan user ID tersedia sebelum melakukan fetch
    if (_userId == null) {
      // debugPrint("⚠️ User ID is null. Cannot fetch attendance data.");
      _isLoading = false;
    } else {
      _fetchDataForSelectedDate();
    }
  }

  // --- FUNGSI UTAMA: Mengubah Tanggal dan Memuat Ulang Data ---
  void setSelectedDate(DateTime newDate) {
    if (_selectedDate.day == newDate.day && 
        _selectedDate.month == newDate.month && 
        _selectedDate.year == newDate.year) {
      return; // Tidak ada perubahan tanggal, abaikan
    }
    
    _selectedDate = newDate;
    notifyListeners(); 
    _fetchDataForSelectedDate();
  }

  // --- FUNGSI FETCH DATA DENGAN REALTIME LISTENER ---
  void _fetchDataForSelectedDate() {
    if (_userId == null) return;
    
    _isLoading = true;
    _absenData = null;
    notifyListeners();

    // 1. Batalkan langganan lama (PENTING untuk mencegah memory leak)
    _absenSubscription?.cancel();

    // 2. Format tanggal menjadi kunci dokumen Firestore (YYYY-MM-DD-UID)
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final docId = '$formattedDate-$_userId';

    // 3. Buat langganan stream baru
    _absenSubscription = _firestore
        .collection(_collectionName)
        .doc(docId)
        .snapshots()
        .listen((documentSnapshot) {
      
      _isLoading = false;

      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        try {
          // Konversi DocumentSnapshot ke AbsenModel
          _absenData = AbsenModel.fromFirestore(documentSnapshot);
        } catch (e) {
          // Hanya gunakan debugPrint jika Anda ingin melihat error di konsol debug
          // debugPrint("🔴 Error parsing AbsenModel: $e"); 
          _absenData = null;
        }
      } else {
        _absenData = null; // Data tidak ditemukan
      }
      
      notifyListeners();
    }, onError: (error) {
      // debugPrint("🔴 Firestore listen error: $error");
      _isLoading = false;
      _absenData = null;
      notifyListeners();
    });
  }

  // --- PEMBERSIHAN SUMBER DAYA ---
  @override
  void dispose() {
    _absenSubscription?.cancel();
    super.dispose();
  }
}