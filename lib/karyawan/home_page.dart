import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';


import 'package:tes_flutter/auth/auth_service.dart';
import '../karyawan/base_page.dart';
import 'package:tes_flutter/admin/widget/animated_fade_slide.dart';

// Data simulasi absensi
final List<bool> currentUserAttendance = List.generate(
  31,
  (day) => day < 30 ? day % 3 != 0 : true,
);

class KaryawanHomePage extends StatefulWidget {
  const KaryawanHomePage({super.key});

  @override
  State<KaryawanHomePage> createState() => _KaryawanHomePageState();
}

class _KaryawanHomePageState extends State<KaryawanHomePage> {
  String? userName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.checkUserProfileCompleteness(context);
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('tbl_user')
            .doc(user.uid)
            .get();

        setState(() {
          userName = doc.data()?['name'] ?? user.email ?? 'Pengguna';
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'Tidak ada pengguna aktif';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = 'Gagal memuat user';
        isLoading = false;
      });
      debugPrint('Error load current user: $e');
    }
  }

Future<void> _handleAttendance(BuildContext context) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin lokasi dibutuhkan untuk absen.")),
      );
      setState(() => isLoading = false);
      return;
    }

    // 2. Ambil lokasi
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 3. Deteksi fake GPS
    if (position.isMocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fake GPS terdeteksi! Aksi dibatalkan.")),
      );
      setState(() => isLoading = false);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Kamu terlalu jauh dari kantor (${distance.toStringAsFixed(1)} m).",
          ),
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    // 5. Ambil selfie dari kamera
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) {
      setState(() => isLoading = false);
      return;
    }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengompres foto selfie.")),
      );
      setState(() => isLoading = false);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data wajah belum terdaftar di sistem.")),
      );
      setState(() => isLoading = false);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mendeteksi wajah dari selfie baru.")),
      );
      setState(() => isLoading = false);
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
        'selfie_url': null, // tidak disimpan
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Absensi berhasil disimpan ✅"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Gagal absen: $e"),
        backgroundColor: Colors.redAccent,
      ),
    );
  } finally {
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1E33),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return BasePage(
      title: userName ?? "Tidak Diketahui",
      isPresentToday: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedFadeSlide(
                  delay: 0.2,
                  child: _StatCard(
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
                  child: _StatCard(
                    title: "Status Kehadiran Hari Ini",
                    subtitle: "Hadir (Pukul 07:45)",
                    color: Colors.blueAccent.shade400,
                    icon: Iconsax.user_tick,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedFadeSlide(
                  delay: 0.4,
                  child: _StatCard(
                    title: "Total Hari Kerja",
                    subtitle: "22 Hari dari 30 Hari",
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
              delay: 0.8,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.shade400,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async => await _handleAttendance(context),
                icon: const Icon(Iconsax.camera, color: Colors.white),
                label: const Text(
                  "Ambil Selfie & Absen",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            AnimatedFadeSlide(
              delay: 0.9,
              child: Text(
                "Rekap Absensi Anda",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            AnimatedFadeSlide(
              delay: 0.5,
              child: _AttendanceCalendar(attendanceData: currentUserAttendance),
            ),
            const SizedBox(height: 24),

            AnimatedFadeSlide(
              delay: 0.9,
              child: Text(
                "Progress Absensi Anda",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            AnimatedFadeSlide(
              delay: 1.0,
              child: _ProgressItem(name: "Kehadiran Bulan Ini", value: 22 / 30),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// === Widget Kalender dan Komponen Pendukung ===
// =================================================================

class _AttendanceCalendar extends StatelessWidget {
  final List<bool> attendanceData;
  const _AttendanceCalendar({required this.attendanceData});

  Widget _buildDateBox(int day, bool isAttended) {
    return Container(
      width: 50,
      height: 40,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isAttended ? Colors.green.shade400 : Colors.blueGrey.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        day.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const int startDayOfWeek = 3;
    final int totalDays = attendanceData.length;
    final List<Widget> calendarBoxes = List.generate(
      startDayOfWeek - 1,
      (index) => const SizedBox(width: 50, height: 40),
    );

    for (int day = 1; day <= totalDays; day++) {
      final bool isAttended = attendanceData[day - 1];
      calendarBoxes.add(_buildDateBox(day, isAttended));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF152A46),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayHeader(text: 'S', isWeekend: false),
              _DayHeader(text: 'S', isWeekend: false),
              _DayHeader(text: 'R', isWeekend: false),
              _DayHeader(text: 'K', isWeekend: false),
              _DayHeader(text: 'J', isWeekend: false),
              _DayHeader(text: 'S', isWeekend: true),
              _DayHeader(text: 'M', isWeekend: true),
            ],
          ),
          const Divider(color: Colors.white30, height: 16),
          Wrap(children: calendarBoxes),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _Legend(color: Colors.green, label: "Hadir"),
              SizedBox(width: 8),
              _Legend(color: Color(0xFF546E7A), label: "Absen/Libur"),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String text;
  final bool isWeekend;
  const _DayHeader({required this.text, required this.isWeekend});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isWeekend ? Colors.red.shade300 : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2A3A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String name;
  final double value;

  const _ProgressItem({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blueAccent.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
