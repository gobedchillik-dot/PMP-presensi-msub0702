import 'dart:async';
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
import 'package:tes_flutter/database/model/payroll.dart';

class KaryawanHomeController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _userName = 'Memuat...';
  bool _isLoading = true;

  List<int> _monthAttendance = [];
  String? _idUser;
  AbsenModel? _todayAttendance;
  double _estimatedUnpaidSalary = 0.0;

  StreamSubscription<QuerySnapshot>? _attendanceSubscription;
  StreamSubscription<QuerySnapshot>? _payrollSubscription;

  DateTime? _lastPayrollEndDate; // tanggal akhir pembayaran terakhir
  int _totalUnpaidCounts = 0; // total sesi sejak pembayaran terakhir

  // Konstanta umum
  static const int maxAbsencesPerDay = 3;
  static const double _officeLat = -6.763314;
  static const double _officeLong = 108.480080;
  static const double _allowedRadius = 1000000.0;

  static const String _apiKey = 'vLyZVMDR_GzfyZrBrg-c1079Wcu4Iamw';
  static const String _apiSecret = 'kG8h1bie531eS5lQ4aV6vEDcynPZpWBC';

  static const double maxMonthlySalary = 2500000.0;
  static const int workingDaysInMonth = 30;
  static const int maxCountPerDay = 3;

  static const double valuePerCount =
      maxMonthlySalary / workingDaysInMonth / maxCountPerDay;

  // Getters
  String get userName => _userName;
  bool get isLoading => _isLoading;
  List<int> get monthAttendance => _monthAttendance;

  int get totalPresentDays =>
      _monthAttendance.where((count) => count > 0).length;

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

  double get estimatedUnpaidSalary => _totalUnpaidCounts * valuePerCount;

  // Constructor
  KaryawanHomeController() {
    _idUser = AuthService.currentUser?.uid;
    _loadUserName();

    if (_idUser != null) {
      _listenToAttendance();
      _listenToPayroll();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _attendanceSubscription?.cancel();
    _payrollSubscription?.cancel();
    super.dispose();
  }

  // Load Nama User
  Future<void> _loadUserName() async {
    final user = AuthService.currentUser;
    if (user == null) {
      _userName = "Tidak ada pengguna aktif";
      return;
    }

    try {
      final userDoc =
          await _db.collection('tbl_user').doc(user.uid).get();

      final data = userDoc.data();
      String name = data?['name'] ??
          data?['panggilan'] ??
          user.email ??
          "Pengguna";

      _userName = name;
    } catch (e) {
      _userName = "Gagal memuat user";
    }
  }

  // Ambil dokumen absensi hari ini
  Future<DocumentSnapshot<Map<String, dynamic>>?> _getTodayAttendanceDoc(
      String userId) async {
    final now = DateTime.now();
    final startOfDay =
        DateTime(now.year, now.month, now.day, 0, 0, 0);

    final snapshot = await _db
        .collection('tbl_absen')
        .where('idUser', isEqualTo: userId)
        .where('tanggal', isEqualTo: Timestamp.fromDate(startOfDay))
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
  }

  // Listen absensi bulanan
  void _listenToAttendance() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    _attendanceSubscription = _db
        .collection('tbl_absen')
        .where('idUser', isEqualTo: _idUser)
        .where('tanggal',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(startOfMonth))
        .where('tanggal',
            isLessThanOrEqualTo:
                Timestamp.fromDate(endOfMonth))
        .orderBy('tanggal', descending: true)
        .snapshots()
        .listen((snapshot) async {
      final int daysInCurrentMonth = endOfMonth.day;
      List<int> newAttendanceCounts =
          List.filled(daysInCurrentMonth, 0);

      AbsenModel? latestTodayData;
      int totalCountsSinceLastPayroll = 0;

      for (var doc in snapshot.docs) {
        final AbsenModel model = AbsenModel.fromFirestore(doc);
        final DateTime date = model.tanggal.toDate();
        final int index = date.day - 1;

        if (index >= 0 && index < newAttendanceCounts.length) {
          newAttendanceCounts[index] = model.count;
        }

        if (date.day == now.day && date.month == now.month) {
          latestTodayData = model;
        }

        if (_lastPayrollEndDate == null ||
            date.isAfter(_lastPayrollEndDate!)) {
          totalCountsSinceLastPayroll += model.count;
        }
      }

      _monthAttendance = newAttendanceCounts;
      _todayAttendance = latestTodayData;
      _totalUnpaidCounts = totalCountsSinceLastPayroll;

      if (_isLoading) _isLoading = false;

      notifyListeners();
    }, onError: (error) {
      debugPrint("Gagal mendengarkan stream absensi: $error");
      if (_isLoading) _isLoading = false;
      notifyListeners();
    });
  }

  // Listen perubahan payroll
  void _listenToPayroll() {
    if (_idUser == null) return;

    _payrollSubscription = _db
        .collection('tbl_payroll')
        .where('idUser', isEqualTo: _idUser!)
        .orderBy('periodEndDate', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final payrollDoc =
            AbsenPayrollModel.fromFirestore(snapshot.docs.first);
        final date = payrollDoc.periodEndDate.toDate();
        _lastPayrollEndDate =
            DateTime(date.year, date.month, date.day);
      } else {
        _lastPayrollEndDate = null;
      }

      await _calculateUnpaidCounts(_idUser!, _lastPayrollEndDate);
      notifyListeners();
    }, onError: (error) {
      debugPrint("Gagal mendengarkan stream payroll: $error");
      notifyListeners();
    });
  }

  // Hitung total unpaid counts setelah payroll terakhir
  Future<void> _calculateUnpaidCounts(
      String userId, DateTime? lastEndDate) async {
    DateTime startDate;

    if (lastEndDate == null) {
      final firstAbsenDate = await _getFirstAbsenceDate(userId);
      if (firstAbsenDate == null) {
        _totalUnpaidCounts = 0;
        return;
      }
      startDate = firstAbsenDate;
    } else {
      startDate = lastEndDate.add(const Duration(days: 1));
    }

    final now = DateTime.now();
    final endDate =
        DateTime(now.year, now.month, now.day, 23, 59, 59);

    final absenSnapshot = await _db
        .collection('tbl_absen')
        .where('idUser', isEqualTo: userId)
        .where('tanggal',
            isGreaterThanOrEqualTo:
                Timestamp.fromDate(startDate))
        .where('tanggal',
            isLessThanOrEqualTo:
                Timestamp.fromDate(endDate))
        .get();

    int totalUnpaidCounts = 0;

    for (var doc in absenSnapshot.docs) {
      final count = (doc.data()['count'] as num?)?.toInt() ?? 0;
      totalUnpaidCounts += count;
    }

    _totalUnpaidCounts = totalUnpaidCounts;
    _estimatedUnpaidSalary = _totalUnpaidCounts * valuePerCount;
  }

  // Tanggal absen pertama
  Future<DateTime?> _getFirstAbsenceDate(String userId) async {
    try {
      final firstAbsenSnapshot = await _db
          .collection('tbl_absen')
          .where('idUser', isEqualTo: userId)
          .orderBy('tanggal', descending: false)
          .limit(1)
          .get();

      if (firstAbsenSnapshot.docs.isEmpty) return null;

      final date =
          firstAbsenSnapshot.docs.first.data()['tanggal']?.toDate();
      if (date == null) return null;

      return DateTime(date.year, date.month, date.day);
    } catch (e) {
      debugPrint("Error fetching first absence date: $e");
      return null;
    }
  }

  // Detect wajah baru (Face++)
  Future<String?> _detectNewFace(String imageBase64) async {
    final detectResponse = await http.post(
      Uri.parse('https://api-us.faceplusplus.com/facepp/v3/detect'),
      body: {
        'api_key': _apiKey,
        'api_secret': _apiSecret,
        'image_base64': imageBase64,
      },
    );

    final detectData = jsonDecode(detectResponse.body);
    return detectData['faces']?[0]?['face_token'];
  }

  // Compare wajah (Face++)
  Future<double?> _compareFaces(
      String faceId, String newFaceToken) async {
    final compareResponse = await http.post(
      Uri.parse('https://api-us.faceplusplus.com/facepp/v3/compare'),
      body: {
        'api_key': _apiKey,
        'api_secret': _apiSecret,
        'face_token1': faceId,
        'face_token2': newFaceToken,
      },
    );

    final data = jsonDecode(compareResponse.body);
    return data['confidence'];
  }

  // Fungsi Absensi
  Future<void> handleAttendance(BuildContext context) async {
    if (_idUser == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengguna tidak terautentikasi.")),
        );
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Cek jumlah sesi
      if (currentAbsenceCount >= maxAbsencesPerDay) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Kewajiban absen hari ini (3 sesi) telah terpenuhi ✅"),
            backgroundColor: Colors.blueAccent,
          ),
        );
        return;
      }

      // Izin lokasi
      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin lokasi dibutuhkan untuk absen.")),
        );
        return;
      }

      // Ambil lokasi
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (position.isMocked) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fake GPS terdeteksi! Aksi dibatalkan.")),
        );
        return;
      }

      final distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, _officeLat, _officeLong);

      if (distance > _allowedRadius) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Kamu terlalu jauh dari kantor (${distance.toStringAsFixed(1)} m).",
            ),
          ),
        );
        return;
      }

      // Ambil selfie
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      final tempDir = await getTemporaryDirectory();
      final targetPath =
          "${tempDir.path}/selfie_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final compressedResult =
          await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 60,
        minWidth: 800,
        minHeight: 800,
      );

      if (compressedResult == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengompres foto selfie.")),
        );
        return;
      }

      final imageBytes = await File(compressedResult.path).readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      // Ambil face ID user
      final userDoc =
          await _db.collection('tbl_user').doc(_idUser).get();
      final faceId = userDoc.data()?['face_id'];

      if (faceId == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Data wajah belum terdaftar di sistem.")),
        );
        return;
      }

      final newFaceToken = await _detectNewFace(imageBase64);

      if (newFaceToken == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Gagal mendeteksi wajah dari selfie baru.")),
        );
        return;
      }

      final confidence = await _compareFaces(faceId, newFaceToken);

      if (confidence != null && confidence >= 70) {
        final now = DateTime.now();
        final startOfDay =
            DateTime(now.year, now.month, now.day, 0, 0, 0);

        final newDetail = AbsenDetailModel(
          timestamp: Timestamp.now(),
          latitude: position.latitude,
          longitude: position.longitude,
          confidence: confidence,
          selfieUrl: null,
          time:
              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
        );

        final todayDoc = await _getTodayAttendanceDoc(_idUser!);

        int newCount;

        if (todayDoc == null) {
          newCount = 1;

          final newAbsenModel = AbsenModel(
            id: '',
            idUser: _idUser!,
            tanggal: Timestamp.fromDate(startOfDay),
            count: newCount,
            status: true,
            lastUpdate: Timestamp.now(),
            times: [newDetail],
          );

          await _db.collection('tbl_absen').add(newAbsenModel.toMap());
        } else {
          final existingModel = AbsenModel.fromFirestore(todayDoc);
          newCount = existingModel.count + 1;

          final updatedTimes =
              List<AbsenDetailModel>.from(existingModel.times)
                ..add(newDetail);

          final updateData = {
            'count': newCount,
            'status': true,
            'lastUpdate': Timestamp.now(),
            'times': updatedTimes.map((e) => e.toMap()).toList(),
          };

          await _db
              .collection('tbl_absen')
              .doc(todayDoc.id)
              .update(updateData);
        }

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Absensi Sesi $newCount berhasil disimpan!"),
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
        SnackBar(
          content: Text("Gagal absen: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
