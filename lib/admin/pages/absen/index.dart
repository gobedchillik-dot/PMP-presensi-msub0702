import 'package:flutter/material.dart';
import '../../base_page.dart';
import '../../widget/animated_fade_slide.dart';
import '../../home_page.dart';

// Data dan Konstanta Global (Boleh tetap di sini, karena ini hanya data dan konstanta)
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

class AbsenIndexPage extends StatefulWidget {
  const AbsenIndexPage({super.key});

  @override
  State<AbsenIndexPage> createState() => _AbsenIndexPageState();
}

class _AbsenIndexPageState extends State<AbsenIndexPage> {
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
      title: "Data Absen",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Tombol Kembali dan Judul ===
            AnimatedFadeSlide(
              delay: 0.1,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const adminHomePage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            final fade = Tween(begin: 0.0, end: 1.0).animate(animation);
                            final slide = Tween<Offset>(
                              begin: const Offset(-0.2, 0),
                              end: Offset.zero,
                            ).animate(animation);
                            return FadeTransition(
                              opacity: fade,
                              child: SlideTransition(position: slide, child: child),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const Text(
                    "Data absensi karyawan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // === Tombol Edit & Tambah ===
            AnimatedFadeSlide(
              delay: 0.2,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, color: Colors.black),
                      label: const Text("Edit data"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle, color: Colors.black),
                      label: const Text("Tambah data"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
            
            // ----------------------------------------------------------------
            // === Absen Tracker ===
            // ----------------------------------------------------------------

            const SizedBox(height: 24),
            AnimatedFadeSlide(
              delay: 0.6,
              child: const Text(
                "Absen tracker",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedFadeSlide(
              delay: 0.8,
              child: const _AbsenProgress(name: "Karyawan 1", value: 0.5),
            ),
            AnimatedFadeSlide(
              delay: 1.0,
              child: const _AbsenProgress(name: "Karyawan 2", value: 0.75),
            ),
            AnimatedFadeSlide(
              delay: 1.2,
              child: const _AbsenProgress(name: "Karyawan 3", value: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbsenProgress extends StatelessWidget {
  final String name;
  final double value;

  const _AbsenProgress({required this.name, required this.value});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500)),
              Text("${(value * 100).toInt()}/100",
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.lightBlueAccent.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}