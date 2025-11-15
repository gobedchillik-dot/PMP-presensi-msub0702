import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:tes_flutter/auth/auth_service.dart';
import 'package:tes_flutter/database/model/absen.dart';
import 'package:tes_flutter/database/model/absen_detail.dart';


class KaryawanHomeController extends ChangeNotifier {
  // --- State Variables ---
  String _userName = 'Memuat...';
  bool _isLoading = true; 
  // DIPERBAIKI: Tipe data sekarang List<int>
  List<int> _monthAttendance = []; 
  String? _userId;
  AbsenModel? _todayAttendance; 

  // Constants
  static const int maxAbsencesPerDay = 3; 
  static const double _officeLat = -6.763314;
  static const double _officeLong = 108.480080;
  static const double _allowedRadius = 1000000.0; 
  static const String _apiKey = 'vLyZVMDR_GzfyZrBrg-c1079Wcu4Iamw';
  static const String _apiSecret = 'kG8h1bie531eS5lQ4aV6vEDcynPZpWBC';

  // --- Getters ---
  String get userName => _userName;
  bool get isLoading => _isLoading;
  // DIPERBAIKI: Getter sekarang mengembalikan List<int>
  List<int> get monthAttendance => _monthAttendance; 
  
  // DIPERBAIKI: Hitung Hari Hadir dari List<int>
  // Hadir = count > 0 (setidaknya 1 sesi)
  int get totalPresentDays => _monthAttendance.where((count) => count > 0).length; 
  
  int get daysInMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  bool get isPresentToday => _todayAttendance?.status ?? false;
  int get currentAbsenceCount => _todayAttendance?.count ?? 0;
  String get nextAbsenceSession {
    final count = currentAbsenceCount;
    if (count == 0) return "Sesi 1";
    if (count == 1) return "Sesi 2";
    if (count == 2) return "Sesi 3";
    return "Selesai";
  }

  String get isToday {
    final count = currentAbsenceCount;
    switch (count) {
      case 0:
        return "Belum absen hari ini";
      case 1:
        return "Absen Sesi 1 berhasil";
      case 2:
        return "Absen Sesi 2 berhasil";
      case 3:
        return "Kewajiban 3 Sesi terpenuhi";
      default:
        return "Absensi selesai ($count sesi)";
    }
  }

  // --- Constructor dan Inisialisasi ---
  KaryawanHomeController() {
    _userId = AuthService.currentUser?.uid;
    _loadUserName();
    if (_userId != null) {
      _listenToAttendance();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Data Loading & Listening ---
  Future<void> _loadUserName() async {
    final user = AuthService.currentUser;
    if (user == null) {
      _userName = "Tidak ada pengguna aktif";
      return; 
    }
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_user')
          .doc(user.uid)
          .get();
      _userName = userDoc.data()?['name'] ?? user.email ?? "Pengguna";
    } catch (e) {
      _userName = "Gagal memuat user";
    } 
  }

  // Cari dokumen absensi hari ini
  Future<DocumentSnapshot<Map<String, dynamic>>?> _getTodayAttendanceDoc(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);

    final snapshot = await FirebaseFirestore.instance
        .collection('tbl_absen')
        .where('idUser', isEqualTo: userId)
        .where('tanggal', isEqualTo: Timestamp.fromDate(startOfDay))
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
  }

  // Stream untuk mendapatkan data absensi bulanan secara real-time
  void _listenToAttendance() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    FirebaseFirestore.instance
        .collection('tbl_absen')
        .where('idUser', isEqualTo: _userId)
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots()
        .listen((snapshot) {
      
      final int daysInCurrentMonth = endOfMonth.day;
      // DIPERBAIKI: Inisialisasi list dengan 0 (count absen)
      List<int> newAttendanceCounts = List.filled(daysInCurrentMonth, 0);

      AbsenModel? latestTodayData;

      for (var doc in snapshot.docs) {
        final AbsenModel model = AbsenModel.fromFirestore(doc);

        final DateTime date = model.tanggal.toDate();
        final int index = date.day - 1;
        
        // Update list absensi bulanan dengan nilai count
        if (index >= 0 && index < newAttendanceCounts.length) {
          // DIPERBAIKI: Simpan nilai count ke dalam list
          newAttendanceCounts[index] = model.count; 
        }

        // Cek apakah ini data hari ini
        if (date.day == now.day && date.month == now.month) {
          latestTodayData = model;
        }
      }
      
      // DIPERBAIKI: Tetapkan _monthAttendance sebagai List<int>
      _monthAttendance = newAttendanceCounts; 
      _todayAttendance = latestTodayData; 
      
      if (_isLoading) {
          _isLoading = false; 
      }
      
      notifyListeners();

    }, onError: (error) {
      debugPrint("Gagal mendengarkan stream absensi: $error");
      if (_isLoading) {
          _isLoading = false; 
      }
      notifyListeners();
    });
  }

  // --- Logic Absensi (Tidak ada perubahan signifikan yang dibutuhkan di sini) ---
  Future<String?> _detectNewFace(String imageBase64) async {
    // ... (Logika deteksi wajah)
    final detectResponse = await http.post(
      Uri.parse('https://api-us.faceplusplus.com/facepp/v3/detect'),
      body: {'api_key': _apiKey, 'api_secret': _apiSecret, 'image_base64': imageBase64},
    );
    final detectData = jsonDecode(detectResponse.body);
    return detectData['faces']?[0]?['face_token'];
  }

  Future<double?> _compareFaces(String faceId, String newFaceToken) async {
    // ... (Logika perbandingan wajah)
    final compareResponse = await http.post(
      Uri.parse('https://api-us.faceplusplus.com/facepp/v3/compare'),
      body: {'api_key': _apiKey, 'api_secret': _apiSecret, 'face_token1': faceId, 'face_token2': newFaceToken},
    );
    final data = jsonDecode(compareResponse.body);
    return data['confidence'];
  }

  Future<void> handleAttendance(BuildContext context) async {
    if (_userId == null) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pengguna tidak terautentikasi.")));
      return;
    }

    _isLoading = true;
    notifyListeners();
    
    try {
      // 0. Cek batasan 3x
      if (currentAbsenceCount >= maxAbsencesPerDay) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kewajiban absen hari ini (3 sesi) telah terpenuhi ✅"),
            backgroundColor: Colors.blueAccent,
          ),
        );
        return;
      }

      // 1. Cek izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Izin lokasi dibutuhkan untuk absen.")));
        return;
      }

      // 2. Ambil lokasi & 3. Deteksi fake GPS & 4. Cek radius
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      if (position.isMocked) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fake GPS terdeteksi! Aksi dibatalkan.")));
        return;
      }
      final distance = Geolocator.distanceBetween(position.latitude, position.longitude, _officeLat, _officeLong);
      if (distance > _allowedRadius) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kamu terlalu jauh dari kantor (${distance.toStringAsFixed(1)} m).")));
        return;
      }

      // 5. Ambil selfie & 6. Kompres gambar
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      final tempDir = await getTemporaryDirectory();
      final targetPath = "${tempDir.path}/selfie_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final compressedResult = await FlutterImageCompress.compressAndGetFile(image.path, targetPath, quality: 60, minWidth: 800, minHeight: 800);
      if (compressedResult == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengompres foto selfie.")));
        return;
      }
      final imageBytes = await File(compressedResult.path).readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      // 7. Ambil data wajah terdaftar
      final userDoc = await FirebaseFirestore.instance.collection('tbl_user').doc(_userId).get();
      final faceId = userDoc.data()?['face_id'];
      if (faceId == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data wajah belum terdaftar di sistem.")));
        return;
      }

      // 8. Deteksi wajah baru & 9. Bandingkan wajah
      final newFaceToken = await _detectNewFace(imageBase64);
      if (newFaceToken == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mendeteksi wajah dari selfie baru.")));
        return;
      }
      final confidence = await _compareFaces(faceId, newFaceToken);
      
      // 10. Jika confidence cukup tinggi
      if (confidence != null && confidence >= 70) {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
        
        // Buat model detail absensi sesi ini
        final newDetail = AbsenDetailModel(
          timestamp: Timestamp.now(),
          latitude: position.latitude,
          longitude: position.longitude,
          confidence: confidence,
          selfieUrl: null, 
          time: "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
        );

        // Ambil dokumen hari ini
        final todayDoc = await _getTodayAttendanceDoc(_userId!);

        if (todayDoc == null) {
          // Kasus: Absen Sesi 1 (Buat dokumen baru)
          final newAbsenModel = AbsenModel(
            id: '', 
            idUser: _userId!,
            tanggal: Timestamp.fromDate(startOfDay),
            count: 1,
            status: true,
            lastUpdate: Timestamp.now(),
            times: [newDetail],
          );
          await FirebaseFirestore.instance.collection('tbl_absen').add(newAbsenModel.toMap());

        } else {
          // Kasus: Absen Sesi 2 atau 3 (Update dokumen yang sudah ada)
          final existingModel = AbsenModel.fromFirestore(todayDoc);
          final updatedTimes = List<AbsenDetailModel>.from(existingModel.times)..add(newDetail);

          final updateData = {
            'count': FieldValue.increment(1),
            'status': true,
            'lastUpdate': Timestamp.now(),
            'times': updatedTimes.map((e) => e.toMap()).toList(),
          };
          await FirebaseFirestore.instance.collection('tbl_absen').doc(todayDoc.id).update(updateData);
        }
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Absensi Sesi ${currentAbsenceCount + 1} berhasil disimpan ✅"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Verifikasi wajah gagal ❌"),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error absensi: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal absen: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}