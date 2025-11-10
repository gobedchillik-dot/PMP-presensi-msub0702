import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import '../../base_page.dart';
import '../../../utils/animated_fade_slide.dart';
import '../../home_page.dart';
import '../../../db/controller/absen/absen_controller.dart';
import '../../../db/model/absen.dart';

class AbsenIndexPage extends StatefulWidget {
  const AbsenIndexPage({super.key});

  @override
  State<AbsenIndexPage> createState() => _AbsenIndexPageState();
}

class _AbsenIndexPageState extends State<AbsenIndexPage> {
  late ScrollController _headerScrollController;
  late ScrollController _dataScrollController;

  @override
  void initState() {
    super.initState();
    _headerScrollController = ScrollController();
    _dataScrollController = ScrollController();

    // sinkronisasi scroll horizontal
    _dataScrollController.addListener(() {
      if (_dataScrollController.offset != _headerScrollController.offset) {
        _headerScrollController.jumpTo(_dataScrollController.offset);
      }
    });
    _headerScrollController.addListener(() {
      if (_headerScrollController.offset != _dataScrollController.offset) {
        _dataScrollController.jumpTo(_headerScrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _dataScrollController.dispose();
    super.dispose();
  }

  /// Fungsi menentukan warna berdasarkan count & tanggal
  Color _getColorForCount(int count, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (count == 3) return Colors.greenAccent;
    if (count == 2) return Colors.green;
    if (count == 1) return Colors.green.shade700;

    // kalau tanggal sebelum hari ini dan belum ada data → merah
    if (count == 0 && target.isBefore(today)) return Colors.redAccent;

    // kalau tanggal hari ini belum ada data → abu-abu
    if (count == 0 && target == today) return Colors.grey;

    // default
    return Colors.grey.shade800;
  }

  /// Membuat daftar tanggal dalam 1 bulan ini
  List<DateTime> _getDatesOfCurrentMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final lastDay = nextMonth.subtract(const Duration(days: 1));

    return List.generate(
      lastDay.day,
      (index) => DateTime(now.year, now.month, index + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final absenController = Provider.of<AbsenController>(context, listen: false);
    final datesInMonth = _getDatesOfCurrentMonth();

    return BasePage(
      title: "Data Absen",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            AnimatedFadeSlide(
              delay: 0.1,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        reverseCreateRoute(const adminHomePage()),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const Text(
                    "Data absensi karyawan (bulan ini)",
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

            AnimatedFadeSlide(
              delay: 0.4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF152A46),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FutureBuilder<Map<String, String>>(
                  future: absenController.getUserNames(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final userNames = userSnapshot.data ?? {};

                    return FutureBuilder<Map<String, String>>(
  future: absenController.getUserNames(),
  builder: (context, userSnapshot) {
    if (userSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final userNames = userSnapshot.data ?? {};

    return FutureBuilder<Map<String, String>>(
  future: absenController.getUserNames(),
  builder: (context, userSnapshot) {
    if (userSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final userNames = userSnapshot.data ?? {};

    return StreamBuilder<List<AbsenModel>>(
      stream: absenController.streamAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Belum ada data absensi.",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        const double rowHeight = 35.0;
        const double boxWidth = 28.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER KOLOM
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text("Nama", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _headerScrollController,
                    child: Row(
                      children: List.generate(5, (i) {
                        return Container(
                          width: boxWidth,
                          alignment: Alignment.center,
                          child: Text(
                            "P${i + 1}",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white30),

            // DATA BARIS
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KOLOM NAMA
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.map((absen) {
                        final nama = userNames[absen.idUser] ?? absen.idUser;
                        return SizedBox(
                          height: rowHeight,
                          child: Text(
                            nama,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // KOLOM KEHADIRAN
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _dataScrollController,
                      child: Column(
                        children: data.map((absen) {
                          final times = absen.times ?? [];
                          return SizedBox(
                            height: rowHeight,
                            child: Row(
                              children: List.generate(5, (i) {
                                final hadir = i < times.length;
                                return Container(
                                  width: 20,
                                  height: 20,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: hadir
                                        ? Colors.green
                                        : Colors.grey.shade700,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  },
);
  },
);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
