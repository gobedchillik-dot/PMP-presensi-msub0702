import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tes_flutter/karyawan/widget/kalender_kehadiran.dart';
import 'package:tes_flutter/karyawan/widget/kartu_statis.dart';
import 'package:tes_flutter/karyawan/widget/progres_absen.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';
import '../karyawan/base_page.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_service.dart';

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













