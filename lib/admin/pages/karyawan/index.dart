import 'package:flutter/material.dart';
import 'package:tes_flutter/admin/pages/karyawan/detail.dart';
import '../../../db/controller/karyawan_controller.dart';
import '../../../db/model/user.dart';
import '../../../utils/animated_fade_slide.dart';
import '../../../utils/route_generator.dart';
import '../../base_page.dart';
import '../../home_page.dart';
import 'add_page.dart'; 

class KaryawanIndexPage extends StatefulWidget {
  const KaryawanIndexPage({super.key});

  @override
  State<KaryawanIndexPage> createState() => _KaryawanIndexPageState();
}

class _KaryawanIndexPageState extends State<KaryawanIndexPage> {
  final KaryawanController _controller = KaryawanController();

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Data Karyawan",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TITLE BODY DENGAN TOMBOL BACK =====
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
                  const SizedBox(width: 8),
                  const Text(
                    "Data Karyawan",
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

            // ===== TOMBOL TAMBAH DATA SAJA =====
            AnimatedFadeSlide(
              delay: 0.2,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                                        Navigator.push(
                        context,
                        createRoute(const KaryawanAddPage()),
                    );
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.black),
                  label: const Text(
                    "Buatkan akun untuk karyawan",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== CARD DATA KARYAWAN (REALTIME DARI FIREBASE) =====
            AnimatedFadeSlide(
              delay: 0.3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF152A46),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<List<UserModel>>(
                  stream: _controller.streamKaryawan(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Text(
                        'Terjadi kesalahan saat memuat data.',
                        style: TextStyle(color: Colors.redAccent),
                      );
                    }

                    final data = snapshot.data;

                    if (data == null || data.isEmpty) {
                      return const Text(
                        'Belum ada data karyawan.',
                        style: TextStyle(color: Colors.white),
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("No", style: TextStyle(color: Colors.white)),
                            Text("Nama lengkap",
                                style: TextStyle(color: Colors.white)),
                            Text("Status",
                                style: TextStyle(color: Colors.white)),
                            Text("Detail",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        const Divider(color: Colors.white30),
                        AnimatedFadeSlide(
                          delay: 0.4,
                          child: Column( // ganti Container menjadi Column
                            children: [
                              ...List.generate(data.length, (index) {
                                final user = data[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Kolom No
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "${index + 1}",
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),

                                      // Kolom Email
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          user.email,
                                          style: const TextStyle(color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // Kolom Status Aktif
                                      Expanded(
                                        flex: 4,
                                        child: Center(
                                          child: Text(
                                            user.isActive ? "Aktif" : "Non-Aktif",
                                            style: TextStyle(
                                              color: user.isActive ? Colors.greenAccent : Colors.redAccent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),

                                      // Kolom Tombol Detail
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                    Navigator.push(
                        context,
                        createRoute(detailKaryawanPage(user:user)),
                    );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF2E6AC9),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                            ),
                                            child: const Text(
                                              "Detail",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
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
