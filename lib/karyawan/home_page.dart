import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes_flutter/auth/auth_service.dart';
import 'package:tes_flutter/karyawan/base_page.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/karyawan/widget/progres_absen.dart';
import 'package:tes_flutter/karyawan/widget/kalender_kehadiran.dart';
import 'package:tes_flutter/karyawan/widget/kartu_statis.dart';

class KaryawanHomePage extends StatefulWidget {
  const KaryawanHomePage({super.key});

  @override
  State<KaryawanHomePage> createState() => _KaryawanHomePageState();
}

class _KaryawanHomePageState extends State<KaryawanHomePage> {
  String? userName;
  bool isLoading = true;

  // data absensi user
  List<Map<String, dynamic>> attendanceList = [];
  int totalHadir = 0;
  int totalHari = 30; // bisa ubah sesuai bulan berjalan
  String? statusHariIni;
  String? jamMasukHariIni;

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

        final name = doc.data()?['name'] ?? user.email ?? 'Pengguna';

        // Setelah user berhasil didapat, ambil data absennya
        await _loadUserAttendance(user.uid);

        setState(() {
          userName = name;
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
    }
  }

  Future<void> _loadUserAttendance(String uid) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tbl_absensi')
          .where('userId', isEqualTo: uid)
          .orderBy('tanggal', descending: true)
          .get();

      final now = DateTime.now();
      String todayKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      List<Map<String, dynamic>> list = [];
      int hadirCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        list.add(data);

        if (data['status'] == 'Hadir') hadirCount++;

        if (data['tanggal'] == todayKey) {
          statusHariIni = data['status'];
          jamMasukHariIni = data['jamMasuk'];
        }
      }

      setState(() {
        attendanceList = list;
        totalHadir = hadirCount;
      });
    } catch (e) {
      debugPrint("Gagal memuat absensi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1E33),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return BasePage(
      title: userName ?? "Tidak Diketahui",
      isPresentToday: statusHariIni == 'Hadir',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ==== KARTU ATAS ====
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedFadeSlide(
                  delay: 0.2,
                  child: StatCard(
                    title: "Estimasi penghasilan",
                    subtitle: "Rp ${(totalHadir * 100000).toStringAsFixed(0)}", // contoh per hari 100rb
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
                    subtitle: statusHariIni != null
                        ? "$statusHariIni (Pukul $jamMasukHariIni)"
                        : "Belum Absen",
                    color: Colors.blueAccent.shade400,
                    icon: Iconsax.user_tick,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedFadeSlide(
                  delay: 0.4,
                  child: StatCard(
                    title: "Total Hari Kerja",
                    subtitle: "$totalHadir Hari dari $totalHari Hari",
                    color: Colors.amberAccent.shade400,
                    icon: Iconsax.video_tick,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// ==== KALENDER ABSENSI ====
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  child: AttendanceCalendar(
                    attendanceData: attendanceList,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// ==== PROGRESS ABSEN ====
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  child: ProgressItem(
                    name: "Kehadiran ${userName ?? 'Pengguna'} Bulan Ini",
                    value: totalHadir / totalHari,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
