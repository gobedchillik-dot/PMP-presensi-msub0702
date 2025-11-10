// lib/admin/pages/gmv/gmv_index_page.dart (Setelah Refactoring)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/admin/pages/gmv/add.dart';
import 'package:tes_flutter/admin/pages/gmv/edit.dart';
import 'package:tes_flutter/admin/widget/filter_bar.dart';
import 'package:tes_flutter/admin/widget/gmv_mingguan.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';
import 'package:tes_flutter/database/model/gmv.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import '../../../utils/animated_fade_slide.dart';
import '../../base_page.dart';
import '../../home_page.dart';


class GmvIndexPage extends StatefulWidget {
  const GmvIndexPage({super.key});

  @override
  State<GmvIndexPage> createState() => _GmvIndexPageState();
}

class _GmvIndexPageState extends State<GmvIndexPage> {
  // Dummy Data
  final List<Map<String, dynamic>> weeklySummary = [
    {'minggu': 1, 'total': 1300000000, 'isUp': true},
    {'minggu': 2, 'total': 1300000000, 'isUp': false},
    {'minggu': 3, 'total': 1300000000, 'isUp': false},
    {'minggu': 4, 'total': 1300000000, 'isUp': true},
  ];

  String selectedPeriod = '1 Bulan';
  String selectedQuarter = 'M4';
  
  // Hapus formatMoney, karena sudah ada di GmvWeeklyCard (atau bisa dipindah ke utilitas)

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Data GMV",
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('gmvIndexScroll'),
        child: Column(
          key: const Key('gmvIndexColumn'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 1. CUSTOM TITLE & BACK BUTTON (Di-refactor) =====
            AnimatedFadeSlide(
              delay: 0.1,
              child: CustomAppTitle( // ⭐️ MENGGANTIKAN Row yang berulang
                title: "Data GMV",
                backToPage: const AdminHomePage(),
              ),
            ),
            const SizedBox(height: 20),


            // ===== 3. GRAFIK GMV - MENGGUNAKAN FILTERBAR =====
            AnimatedFadeSlide(
              delay: 0.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSubtitle(text: "Grafik GMV"),
                  CustomInfo(text: "Periode : 1 November - 30 November 2025"),
                  const SizedBox(height: 8),
                  FilterBar(),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2F4D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: CustomInfo(text: "Belum ada data")
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== 4. KUARTAL GMV MINGGUAN - MENGGUNAKAN GMVWEEKLYCARD =====
            AnimatedFadeSlide(
              delay: 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSubtitle(text: "Kuartal GMV Mingguan"),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GmvWeeklyCard( // ⭐️ MENGGANTIKAN _buildSummaryCard
                              mingguKe: weeklySummary[0]['minggu'],
                              total: weeklySummary[0]['total'],
                              isUp: weeklySummary[0]['isUp'],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GmvWeeklyCard(
                              mingguKe: weeklySummary[1]['minggu'],
                              total: weeklySummary[1]['total'],
                              isUp: weeklySummary[1]['isUp'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GmvWeeklyCard(
                              mingguKe: weeklySummary[2]['minggu'],
                              total: weeklySummary[2]['total'],
                              isUp: weeklySummary[2]['isUp'],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GmvWeeklyCard(
                              mingguKe: weeklySummary[3]['minggu'],
                              total: weeklySummary[3]['total'],
                              isUp: weeklySummary[3]['isUp'],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== Tombol Edit dan Tambah Data (Tetap) =====
            AnimatedFadeSlide(
              delay: 0.2,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { 
                        Navigator.push(
                          context,
                          createRoute(const EditGmvPage()),
                        );
                      },
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          createRoute(const AddGmvPage()),
                        );
                      },
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== 5. DATA GMV (DARI FIRESTORE) - MENGGUNAKAN FILTERBAR =====
            AnimatedFadeSlide(
              delay: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSubtitle(text: "Data GMV"),
                  CustomInfo(text: "Periode : 20 Oktober - 30 Oktober 2025"),
                  const SizedBox(height: 8),

                  // ⭐️ MENGGANTIKAN SingleChildScrollView + Row + List.generate filter kuartal
                  FilterBar(),
                  
                  const SizedBox(height: 24),

                  // CARD DATA GMV (StreamBuilder)
                  AnimatedFadeSlide(
                    delay: 0.4,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF152A46),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Tanggal",
                                  style: TextStyle(color: Colors.white)),
                              Text("GMV",
                                  style: TextStyle(color: Colors.white)),
                              Text("Est. Profit",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          const Divider(color: Colors.white30),

                          // === STREAMBUILDER FIRESTORE ===
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

                              if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    "Belum ada data GMV",
                                    style:
                                        TextStyle(color: Colors.white54),
                                  ),
                                );
                              }

                              final data = snapshot.data!;
                              final dateFormat =
                                  DateFormat('dd-MM-yyyy');


                              return Column(
                                children: List.generate(data.length, (index) {
                                  final gmv = data[index];
                                    final formattedGmv = NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 0,
                                    ).format(gmv.gmv);
                                    final profit = (gmv.gmv * 5) / 100;
                                    final formattedProfit = NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 0,
                                    ).format(profit);
                                    
                                    // PENTING: Jika baris data ini sering digunakan, 
                                    // kita bisa ekstrak menjadi GmvDataRow.
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dateFormat
                                                .format(gmv.tanggal.toDate()),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          Text(
                                            formattedGmv,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          Text(
                                            formattedProfit,
                                            style: const TextStyle(
                                                color: Colors.white),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}