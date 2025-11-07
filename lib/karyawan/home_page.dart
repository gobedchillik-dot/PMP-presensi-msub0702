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
                    subtitle: "Hadir (Pukul 07:45)",
                    color: Colors.blueAccent.shade400,
                    icon: Iconsax.user_tick,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedFadeSlide(
                  delay: 0.4,
                  child: StatCard(
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
                    attendanceData: currentUserAttendance,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

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
                    value: 22 / 30,
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