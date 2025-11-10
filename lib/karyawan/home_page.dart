import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../karyawan/base_page.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes_flutter/auth/auth_service.dart';

const int totalDaysInMonth = 31;

class karyawanHomePage extends StatefulWidget {
  const karyawanHomePage({super.key});

  @override
  State<karyawanHomePage> createState() => karyawanHomePageState();
}

class karyawanHomePageState extends State<karyawanHomePage> {
  String userName = '';
  bool isPresentToday = false;
  List<bool> attendanceData = List.filled(totalDaysInMonth, false);

  @override
  void initState() {
    super.initState();
    _loadUserName();
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
            padding: const EdgeInsets.all(16),
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
                  delay: 0.9,
                  child: Text(
                    "Rekap Absensi Anda",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                AnimatedFadeSlide(
                  delay: 0.5,
                  child: AttendanceCalendar(
                    attendanceData: monthAttendance,
                  ),
                ),

                const SizedBox(height: 24),

                AnimatedFadeSlide(
                  delay: 0.9,
                  child: Text(
                    "Progress Absensi Anda",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedFadeSlide(
                  delay: 1.0,
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

class AttendanceCalendar extends StatelessWidget {
  final List<bool> attendanceData;

  const AttendanceCalendar({required this.attendanceData});

  Widget _buildDateBox(int day, bool isAttended, double size) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(2),
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
    final now = DateTime.now();
    final monthName = "${_getMonthName(now.month)} ${now.year}";
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = 4.0;
    final totalColumns = 9;
    final boxSize = (screenWidth - 32 - (spacing * (totalColumns - 1))) / totalColumns;

    final int totalDays = attendanceData.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF152A46),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan grid
        children: [
          Text(
            monthName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Wrap di tengah
          Center(
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(totalDays, (index) {
                return _buildDateBox(index + 1, attendanceData[index], boxSize);
              }),
            ),
          ),

          const SizedBox(height: 16),

          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Legend(color: Colors.green, label: "Hadir"),
              SizedBox(width: 8),
              Legend(color: Color(0xFF546E7A), label: "Absen/Libur"),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return monthNames[month];
  }
}




class DayHeader extends StatelessWidget {
  final String text;
  final bool isWeekend;
  const DayHeader({required this.text, required this.isWeekend});

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

class Legend extends StatelessWidget {
  final Color color;
  final String label;
  const Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const StatCard({required this.title, required this.subtitle, required this.icon, required this.color, this.onTap});

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
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressItem extends StatelessWidget {
  final String name;
  final double value;
  const ProgressItem({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1C2A3A), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent.shade400),
            ),
          ),
        ],
      ),
    );
  }
}
