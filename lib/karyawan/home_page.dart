import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tes_flutter/karyawan/widget/kalender_kehadiran.dart';
import 'package:tes_flutter/karyawan/widget/kartu_statis.dart';
import 'package:tes_flutter/karyawan/widget/progres_absen.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';
import '../karyawan/base_page.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';


import 'package:tes_flutter/auth/auth_service.dart';

const int totalDaysInMonth = 31;

class KaryawanHomePage extends StatefulWidget {
  const KaryawanHomePage({super.key});

  @override
  State<KaryawanHomePage> createState() => KaryawanHomePageState();
}

class KaryawanHomePageState extends State<KaryawanHomePage> {
  String userName = '';
  bool isPresentToday = false;
  List<bool> attendanceData = List.filled(totalDaysInMonth, false);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Panggil fungsi Anda di sini
      AuthService.checkUserProfileCompleteness(context); 
    });
  }

  Future<void> _loadUserName() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        setState(() => userName = "Tidak ada pengguna aktif");
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('tbl_user')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc.data()?['name'] ?? user.email ?? "Pengguna";
      });
    } catch (e) {
      debugPrint("Gagal memuat nama user: $e");
      setState(() => userName = "Gagal memuat user");
    }
  }

Future<void> _handleAttendance() async {
  String? faceId;
  String? faceImage;

  try {
    setState(() => isLoading = true);

    // 1. Cek izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin lokasi dibutuhkan untuk absen.")),
      );
      return;
    }

    // 2. Ambil lokasi
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // 3. Deteksi fake GPS
    if (position.isMocked) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fake GPS terdeteksi! Aksi dibatalkan.")),
      );
      return;
    }

    // 4. Cek radius kantor
    const officeLat = -6.763314;
    const officeLong = 108.480080;
    const allowedRadius = 10000000.0; // meter
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      officeLat,
      officeLong,
    );

    if (distance > allowedRadius) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Kamu terlalu jauh dari kantor (${distance.toStringAsFixed(1)} m).",
          ),
        ),
      );
      return;
    }

    // 5. Ambil selfie dari kamera
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    // 6. Kompres gambar
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        "${tempDir.path}/selfie_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final compressedResult = await FlutterImageCompress.compressAndGetFile(
      image.path,
      targetPath,
      quality: 60,
      minWidth: 800,
      minHeight: 800,
    );

    if (compressedResult == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengompres foto selfie.")),
      );
      return;
    }

    final imageBytes = await File(compressedResult.path).readAsBytes();
    final imageBase64 = base64Encode(imageBytes);

    // 7. Ambil data wajah dari Firestore
    final user = AuthService.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('tbl_user')
        .doc(user?.uid)
        .get();

    faceId = userDoc.data()?['face_id'];
    faceImage = userDoc.data()?['face_image'];

    if (faceId == null || faceImage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data wajah belum terdaftar di sistem.")),
      );
      return;
    }

    // 8. Deteksi wajah baru via Face++
    final detectResponse = await http.post(
      Uri.parse('https://api-us.faceplusplus.com/facepp/v3/detect'),
      body: {
        'api_key': 'vLyZVMDR_GzfyZrBrg-c1079Wcu4Iamw',
        'api_secret': 'kG8h1bie531eS5lQ4aV6vEDcynPZpWBC',
        'image_base64': imageBase64,
      },
    );

    final detectData = jsonDecode(detectResponse.body);
    final newFaceToken = detectData['faces']?[0]?['face_token'];
    if (newFaceToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mendeteksi wajah dari selfie baru.")),
      );
      return;
    }

    // 9. Bandingkan wajah
    final compareResponse = await http.post(
      Uri.parse('https://api-us.faceplusplus.com/facepp/v3/compare'),
      body: {
        'api_key': 'vLyZVMDR_GzfyZrBrg-c1079Wcu4Iamw',
        'api_secret': 'kG8h1bie531eS5lQ4aV6vEDcynPZpWBC',
        'face_token1': faceId,
        'face_token2': newFaceToken,
      },
    );

    final data = jsonDecode(compareResponse.body);
    debugPrint("Compare result: $data");

    // 10. Jika confidence cukup tinggi
    if (data['confidence'] != null && data['confidence'] >= 70) {
      final now = DateTime.now();

      await FirebaseFirestore.instance.collection('tbl_absen').add({
        'userId': user?.uid,
        'name': userName,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': Timestamp.now(),
        'date':
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
        'time':
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
        'status': 'hadir',
        'confidence': data['confidence'],
        'selfie_url': null,
        'created_at': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Absensi berhasil disimpan ✅"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verifikasi wajah gagal ❌"),
          backgroundColor: Colors.orangeAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    debugPrint("Face ID: $faceId");
    debugPrint("Face Image length: ${faceImage?.length}");
    debugPrint("Error absensi: $e");

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Gagal absen: $e"),
        backgroundColor: Colors.redAccent,
      ),
    );
  } finally {
    if (mounted) setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      return const Center(child: Text("Tidak ada pengguna aktif"));
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Stream untuk absensi bulanan
    final Stream<QuerySnapshot> attendanceStream = FirebaseFirestore.instance
        .collection('tbl_absen')
        .where('idUser', isEqualTo: user.uid)
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('tanggal',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: attendanceStream,
      builder: (context, snapshot) {
        List<bool> monthAttendance =
            List.filled(endOfMonth.day, false); // default

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final Timestamp ts = doc['tanggal'];
            final bool status = doc['status'] ?? false;
            final int index = ts.toDate().day - 1;
            if (index >= 0 && index < monthAttendance.length) {
              monthAttendance[index] = status;
            }
          }
        }

        final todayIndex = now.day - 1;
        bool hadirHariIni = monthAttendance[todayIndex];

        return BasePage(
          title: userName,
          isPresentToday: hadirHariIni,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedFadeSlide(
                  delay: 0.1,
                  beginY: 0.3,
                  child: Text(
                    "Dashboard Karyawan",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedFadeSlide(
                      delay: 0.2,
                      child: StatCard(
                        title: "Estimasi penghasilan",
                        subtitle: "Rp 1.234.567,89",
                        color: Colors.greenAccent.shade400,
                        icon: Iconsax.money_4,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedFadeSlide(
                      delay: 0.3,
                      child: StatCard(
                        title: "Status Kehadiran Hari Ini",
                        subtitle: hadirHariIni
                            ? "Hadir (Data Terekam)"
                            : "Belum Hadir",
                        color: hadirHariIni
                            ? Colors.blueAccent.shade400
                            : Colors.redAccent.shade200,
                        icon: hadirHariIni
                            ? Iconsax.user_tick
                            : Iconsax.user_remove,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedFadeSlide(
                      delay: 0.4,
                      child: StatCard(
                        title: "Total Hari Kerja",
                        subtitle:
                            "${monthAttendance.where((e) => e).length} Hari dari $totalDaysInMonth Hari",
                        color: Colors.amberAccent.shade400,
                        icon: Iconsax.video_tick,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                                // Tombol Absen
                AnimatedFadeSlide(
                  delay: 0.5,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _handleAttendance,
                      icon: const Icon(Icons.edit),
                      label: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Absen Sekarang"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedFadeSlide(
                  delay: 0.5,
                  child: CustomSubtitle(text: "Rekap absensi anda")
                ),
                const SizedBox(height: 12),

                AnimatedFadeSlide(
                  delay: 0.6,
                  child: AttendanceCalendar(
                    attendanceData: monthAttendance,
                  ),
                ),

                const SizedBox(height: 24),

                AnimatedFadeSlide(
                  delay: 0.7,
                  child: CustomSubtitle(text: "Progres absensi anda")
                ),
                const SizedBox(height: 12),
                AnimatedFadeSlide(
                  delay: 0.8,
                  child: ProgressItem(
                    name: "Kehadiran Bulan Ini",
                    value: monthAttendance.where((e) => e).length /
                        totalDaysInMonth,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


// ======================== Widget Public ========================













