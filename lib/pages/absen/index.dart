import 'package:flutter/material.dart';
import '../base_page.dart';
import '../../widget/animated_fade_slide.dart';

class AbsenIndexPage extends StatefulWidget {
  const AbsenIndexPage({super.key});

  @override
  State<AbsenIndexPage> createState() => _AbsenIndexPageState();
}

class _AbsenIndexPageState extends State<AbsenIndexPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Data Absen",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // === TABEL DATA ABSEN ===
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
                  children: [
                    // Header tabel
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("No", style: TextStyle(color: Colors.white)),
                        Text("Panggilan", style: TextStyle(color: Colors.white)),
                        Text(" ", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    const Divider(color: Colors.white30),

                    // Isi tabel
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kolom nomor + nama
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(5, (index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${index + 1}.",
                                        style: const TextStyle(color: Colors.white)),
                                    const Text("Karyawan 1",
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Kolom Grid Absen
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2A3A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                // Header tanggal/hari
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                      6,
                                      (index) => Text(
                                            "${index + 1}",
                                            style: const TextStyle(color: Colors.white70),
                                          )),
                                ),
                                const SizedBox(height: 4),
                                // Kotak grid absen dummy
                                Column(
                                  children: List.generate(5, (row) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(6, (col) {
                                        final bool hadir = (row + col) % 2 == 0;
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
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // === Absen Tracker ===
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
