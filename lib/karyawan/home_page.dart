import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../base_page.dart';

// IMPORT BARU: Impor widget animasi yang telah Anda buat
import 'package:tes_flutter/admin/widget/animated_fade_slide.dart'; // Pastikan path ini benar

final List<String> employeeNames = [
  'Karyawan A',
  'Karyawan B',
  'Karyawan C',
  'Karyawan D',
  'Karyawan E',
];

final List<List<bool>> attendanceData = [
  List.generate(30, (day) => day % 3 != 0), 
  List.generate(30, (day) => day % 5 != 0), 
  List.generate(30, (day) => day % 2 == 0), 
  List.generate(30, (day) => day % 4 != 0), 
  List.generate(30, (day) => true), 
];

const int totalDays = 30;
const double rowHeight = 35.0;
const double boxWidth = 24.0; // Dibuat const

class karyawanHomePage extends StatefulWidget {
  const karyawanHomePage({super.key});

  @override
  State<karyawanHomePage> createState() => _karyawanHomePageState();
}

class _karyawanHomePageState extends State<karyawanHomePage> {
  // DEKLARASI ScrollController DI DALAM STATE
  late ScrollController _headerScrollController;
  late ScrollController _dataScrollController;

   @override
  void initState() {
    super.initState();
    // INISIALISASI DI DALAM initState()
    _headerScrollController = ScrollController();
    _dataScrollController = ScrollController();

    // Tambahkan Listener untuk menyinkronkan kedua controller
    // Listener data -> header
    _dataScrollController.addListener(() {
      if (_dataScrollController.offset != _headerScrollController.offset) {
        if (_headerScrollController.hasClients) {
          _headerScrollController.jumpTo(_dataScrollController.offset);
        }
      }
    });

    // Listener header -> data
    _headerScrollController.addListener(() {
      if (_headerScrollController.offset != _dataScrollController.offset) {
        if (_dataScrollController.hasClients) {
          _dataScrollController.jumpTo(_headerScrollController.offset);
        }
      }
    });
  }

  @override
  void dispose() {
    // Pastikan controller di-dispose
    _headerScrollController.dispose();
    _dataScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return BasePage(
      title: 'Hi, karyawan',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Header (Delay: 0.1s, Mulai dari Y=0.3) =====
            AnimatedFadeSlide(
              delay: 0.1,
              beginY: 0.3,
              child: Text(
                "Dashboard",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),

            // **Increment Delay**
            Builder(builder: (context) {
              return const SizedBox.shrink();
            }),

            // ===== Statistik Cards (Vertikal - Staggered) =====
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // StatCard 1 (Delay: 0.25s)
                AnimatedFadeSlide(
                  delay: 0.2,
                  child: _StatCard(
                    title: "Estimasi penghasilan",
                    subtitle: "Rp 1.234.567,89",
                    color: Colors.greenAccent.shade400,
                    icon: Iconsax.money_4,
                    onTap: () {
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // **Increment Delay**
                Builder(builder: (context) {
                  return const SizedBox.shrink();
                }),

                // StatCard 2 (Delay: 0.40s)
                AnimatedFadeSlide(
                  delay: 0.3,
                  child: _StatCard(
                    title: "Absensi Kehadiran",
                    subtitle: " ",
                    color: Colors.blueAccent.shade400,
                    icon: Iconsax.user_tick,
                  ),
                ),
                const SizedBox(height: 12),

                // **Increment Delay**
                Builder(builder: (context) {
                  return const SizedBox.shrink();
                }),

                // StatCard 3 (Delay: 0.55s)
                AnimatedFadeSlide(
                  delay: 0.4,
                  child: _StatCard(
                    title: "Riwayat absen",
                    subtitle: " ",
                    color: Colors.amberAccent.shade400,
                    icon: Iconsax.video_tick,
                    onTap: () {
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedFadeSlide(
              delay: 0.9,
              child: Text(
                "Rekap kehadiran anda",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),

            const SizedBox(height: 12),

            // ----------------------------------------------------------------
            // === TABEL DATA ABSEN (Bagian Sinkronisasi Scroll) ===
            // ----------------------------------------------------------------
            AnimatedFadeSlide(
              delay: 0.4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF152A46),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === HEADER UTAMA & HEADER TANGGAL ===
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Kolom No & Panggilan (2/5 lebar)
                        const Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("No", style: TextStyle(color: Colors.white)),
                              Text("Panggilan", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Header Tanggal yang Sinkron (3/5 lebar)
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: _headerScrollController, // Controller SINKRONISASI 1
                            child: Row(
                              children: List.generate(
                                totalDays,
                                (index) => Container(
                                  width: boxWidth, // Lebar yang konsisten
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white30),

                    // === ISI TABEL DUA KOLOM DENGAN GULIR VERTIKAL ===
                    // Gunakan SingleChildScrollView terpisah untuk gulir vertikal
                    SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Kolom Nama Karyawan (Tabel Kiri)
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(employeeNames.length, (index) {
                                return SizedBox(
                                  height: rowHeight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${index + 1}.",
                                          style: const TextStyle(color: Colors.white)),
                                      Text(employeeNames[index],
                                          style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // 2. Kolom Grid Kehadiran (Tabel Kanan yang dapat digulir horizontal)
                          Expanded(
                            flex: 3,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _dataScrollController, // Controller SINKRONISASI 2
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C2A3A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: List.generate(attendanceData.length, (row) {
                                    return SizedBox(
                                      height: rowHeight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 2.0),
                                        child: Row(
                                          children: List.generate(totalDays, (col) {
                                            final bool hadir =
                                                attendanceData[row][col];
                                            return Container(
                                              width: 20,
                                              height: 20,
                                              margin: const EdgeInsets.all(2.0),
                                              decoration: BoxDecoration(
                                                color: hadir
                                                    ? Colors.green
                                                    : Colors.blueGrey.shade700,
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // **Increment Delay**
            Builder(builder: (context) {
              return const SizedBox.shrink();
            }),

            // ===== Absen Tracker Judul (Delay: 1.20s) =====
            AnimatedFadeSlide(
              delay: 0.9,
              child: Text(
                "Absen Tracker anda",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            // **Increment Delay**
            Builder(builder: (context) {
              return const SizedBox.shrink();
            }),
            
            // Item Absen Tracker 1 (Delay: 1.25s)
            AnimatedFadeSlide(
                delay: 1,
                child: _ProgressItem(name: "50/100", value: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ===== Widget Card Statistik (Tidak ada perubahan) =====
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

// ===== Filter Bar (Tidak ada perubahan) =====
class _FilterBar extends StatefulWidget {
  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  int selected = 3; // default: 1 Bulan

  final filters = ["Semua", "Hari ini", "7 Hari", "1 Bulan"];

  @override
  Widget build(BuildContext context) {
    // Kami menggunakan Builder di HomePage untuk mengemas _FilterBar,
    // jadi animasi keseluruhan sudah dikerjakan di sana.
    // Animasi internal untuk tombol-tombol di sini dapat dipertahankan.
    return Row(
      children: filters.asMap().entries.map((entry) {
        final i = entry.key;
        final text = entry.value;
        final active = selected == i;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? Colors.blueAccent.shade400
                    : Colors.transparent,
                border: Border.all(color: Colors.blueAccent.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: active ? Colors.white : Colors.blueAccent.shade200,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ===== Progress Tracker Item (Tidak ada perubahan) =====
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

// ===== Fungsi Route Fleksibel (Tidak diubah) =====
Route createRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // slide dari kanan
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}
