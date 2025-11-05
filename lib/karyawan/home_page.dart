import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes_flutter/auth/auth_service.dart'; // ✅ Tambahkan ini
import '../karyawan/base_page.dart';
import 'package:tes_flutter/admin/widget/animated_fade_slide.dart';

final List<bool> currentUserAttendance = List.generate(31, (day) => day < 30 ? day % 3 != 0 : true); // Data simulasi 31 hari const int totalDaysInMonth = 31; const double rowHeight = 35.0; const double boxWidth = 24.0;

class karyawanHomePage extends StatefulWidget {
  const karyawanHomePage({super.key});

  @override
  State<karyawanHomePage> createState() => _karyawanHomePageState();
}

class _karyawanHomePageState extends State<karyawanHomePage> {
  String? userName; // ✅ nama user yang akan ditampilkan
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      // ✅ Ambil current user dari AuthService (FirebaseAuth)
      final user = AuthService.currentUser;
      if (user != null) {
        // ✅ Ambil data user dari Firestore
        final doc = await FirebaseFirestore.instance
            .collection('tbl_user') // pastikan nama koleksi sesuai
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
      title: userName ?? "Tidak Diketahui", // ✅ tampilkan nama login
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
                    subtitle: "Hadir (Pukul 07:45)", // Data harusnya dinamis
                    color: Colors.blueAccent.shade400,
                    icon: Iconsax.user_tick,
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedFadeSlide(
                  delay: 0.4,
                  child: _StatCard(
                    title: "Total Hari Kerja",
                    subtitle: "22 Hari dari 30 Hari", // Data harusnya dinamis
                    color: Colors.amberAccent.shade400,
                    icon: Iconsax.video_tick,
                    onTap: () {},
                  ),
                ),
              ],
            ),

                        const SizedBox(height: 24),

            // ===== Absen Tracker Judul (Delay: 0.9s) =====
            AnimatedFadeSlide(
              delay: 0.9,
              child: Text(
                "rekap Absensi Anda",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            // ----------------------------------------------------------------
            // === KALENDER ABSENSI BULANAN (Tampilan Karyawan) ===
            // ----------------------------------------------------------------
            AnimatedFadeSlide(
              delay: 0.5,
              child: _AttendanceCalendar(
                attendanceData: currentUserAttendance,
              ),
            ),

            const SizedBox(height: 24),

            // ===== Absen Tracker Judul (Delay: 0.9s) =====
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
            
            // Item Absen Tracker 1 (Delay: 1s)
            AnimatedFadeSlide(
                delay: 1.0,
                child: _ProgressItem(name: "Kehadiran Bulan Ini", value: 22 / 30)), // Simulasi 22 hari hadir
          ],
        ),
      ),
    );
  }
}

// =================================================================
// === WIDGET KALENDER BARU ===
// =================================================================

class _AttendanceCalendar extends StatelessWidget {
  final List<bool> attendanceData; // Data absensi bulanan (true = hadir)


  const _AttendanceCalendar({
    required this.attendanceData,

  });

  // Fungsi pembantu untuk membuat kotak tanggal
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
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Asumsi bulan dimulai pada hari Rabu (1 Oktober 2025 adalah Rabu)
    const int startDayOfWeek = 3; // 1=Senin, 2=Selasa, 3=Rabu...
    final int totalDays = attendanceData.length;
    
    // Buat daftar kotak kosong (padding) sebelum tanggal 1
    final List<Widget> calendarBoxes = List.generate(
      startDayOfWeek - 1,
      (index) => const SizedBox(width: 50, height: 40),
    );

    // Tambahkan kotak tanggal
    for (int day = 1; day <= totalDays; day++) {
      // Index array dimulai dari 0, sedangkan hari dimulai dari 1
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
          // Nama Hari
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayHeader(text: 'S', isWeekend: false), // Senin
              _DayHeader(text: 'S', isWeekend: false), // Selasa
              _DayHeader(text: 'R', isWeekend: false), // Rabu
              _DayHeader(text: 'K', isWeekend: false), // Kamis
              _DayHeader(text: 'J', isWeekend: false), // Jumat
              _DayHeader(text: 'S', isWeekend: true),  // Sabtu
              _DayHeader(text: 'M', isWeekend: true),  // Minggu
            ],
          ),
          const Divider(color: Colors.white30, height: 16),
          
          // Grid Kalender
          Wrap(
            spacing: 0, 
            runSpacing: 0,
            children: calendarBoxes,
          ),

          const SizedBox(height: 16),
          
          // Keterangan Legenda
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

// Widget Pembantu untuk Header Hari
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

// Widget Pembantu untuk Legenda
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


// =================================================================
// === WIDGET LAIN (TIDAK BERUBAH) ===
// =================================================================

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
                        color: Colors.white, fontWeight: FontWeight.bold),
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

  const _ProgressItem({
    required this.name,
    required this.value,
  });

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
                color: Colors.white, fontWeight: FontWeight.w500),
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