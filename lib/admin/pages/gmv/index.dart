import 'package:flutter/material.dart';
import 'package:tes_flutter/admin/base_page.dart';
import 'package:tes_flutter/admin/home_page.dart';
import 'package:tes_flutter/admin/pages/gmv/add.dart';
import 'package:tes_flutter/admin/pages/gmv/edit.dart';
import 'package:tes_flutter/admin/widget/filter_bar.dart';
import 'package:tes_flutter/admin/widget/gmv_mingguan.dart';
import 'package:tes_flutter/admin/widget/sales_chart_section.dart';
import 'package:tes_flutter/admin/widget/tabel_gmv.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/utils/route_generator.dart';

class GmvIndexPage extends StatefulWidget {
  const GmvIndexPage({super.key});

  @override
  State<GmvIndexPage> createState() => _GmvIndexPageState();
}

class _GmvIndexPageState extends State<GmvIndexPage> {
  final List<Map<String, dynamic>> weeklySummary = [
    {'minggu': 1, 'total': 1300000000, 'isUp': true},
    {'minggu': 2, 'total': 1300000000, 'isUp': false},
    {'minggu': 3, 'total': 1300000000, 'isUp': false},
    {'minggu': 4, 'total': 1300000000, 'isUp': true},
  ];

  String selectedPeriod = '1 Bulan';
  String selectedQuarter = 'M4';
  
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
            AnimatedFadeSlide(
              delay: 0.1,
              child: CustomAppTitle(
                title: "Data GMV",
                backToPage: const AdminHomePage(),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedFadeSlide(
              delay: 0.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSubtitle(text: "Grafik GMV"),
                  CustomInfo(text: "Periode : 1 November - 30 November 2025"),
                ],
              ),
            ),
            AnimatedFadeSlide(
              delay: 0.4,
              child: const SalesChartSection(),
            ),
            const SizedBox(height: 24),
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
                            child: GmvWeeklyCard(
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
            AnimatedFadeSlide(
              delay: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSubtitle(text: "Data GMV"),
                  CustomInfo(text: "Periode : 20 Oktober - 30 Oktober 2025"),
                  const SizedBox(height: 8),
                  FilterBar(),
                  const SizedBox(height: 24),
                  AnimatedFadeSlide(
                    delay: 0.4,
                    child: const TabelGmv(),
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