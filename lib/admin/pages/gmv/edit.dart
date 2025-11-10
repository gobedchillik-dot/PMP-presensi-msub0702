// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/admin/pages/gmv/update.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/database/model/gmv.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import '../../../database/controller/gmv/gmv_controller.dart';
import '../../base_page.dart';
import 'index.dart';

class EditGmvPage extends StatefulWidget {
  const EditGmvPage({super.key});

  @override
  State<EditGmvPage> createState() => _EditGmvPageState();
}

class _EditGmvPageState extends State<EditGmvPage> {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Edit data GMV",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== CUSTOM TITLE & BACK BUTTON =====
            AnimatedFadeSlide(
              delay: 0.1,
              child: CustomAppTitle( // ⭐️ MENGGANTIKAN Row yang berulang
                title: "Edit Data GMV",
                backToPage: const GmvIndexPage(),
              ),
            ),
            const SizedBox(height: 24),

            // ===== INFORMASI =====
            AnimatedFadeSlide(
              delay: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CustomSubtitle(text: "Data GMV"),
                  CustomInfo(text: "Periode : 20 Oktober - 30 Oktober 2025"),
                  SizedBox(height: 8),
                ],
              ),
            ),

            // ===== CARD DATA GMV =====
            AnimatedFadeSlide(
              delay: 0.6,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF152A46),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Tanggal",
                            style: TextStyle(color: Colors.white)),
                        Text("GMV", style: TextStyle(color: Colors.white)),
                        Text("Aksi", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    const Divider(color: Colors.white30),

                    // STREAMBUILDER FIRESTORE
                    StreamBuilder<List<GmvModel>>(
                      stream: context.watch<GmvController>().gmvStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Belum ada data GMV",
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        }

                        final data = snapshot.data!;
                        final dateFormat = DateFormat('dd-MM-yyyy');
                        final numberFormat = NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        );

                        return Column(
                          children: List.generate(data.length, (index) {
                            final gmv = data[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // === Tanggal ===
                                  Text(
                                    dateFormat.format(gmv.tanggal.toDate()),
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),

                                  // === Nilai GMV ===
                                  Text(
                                    numberFormat.format(gmv.gmv),
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),

                                  // === Tombol Aksi ===
                                  Row(
                                    children: [
                                      // Tombol edit
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            createRoute(GmvEditPage(gmv: gmv)),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                      ),
                                      // Tombol hapus
                                      IconButton(
                                        onPressed: () async {
                                          final confirm = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor:
                                                  const Color(0xFF0D1B2A),
                                              title: const Text(
                                                'Hapus Data',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              content: const Text(
                                                'Apakah kamu yakin ingin menghapus data ini?',
                                                style: TextStyle(
                                                    color: Colors.white70),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text(
                                                    'Batal',
                                                    style: TextStyle(
                                                        color: Colors.white70),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                  ),
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await context
                                                .read<GmvController>()
                                                .destroy(gmv.id);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
