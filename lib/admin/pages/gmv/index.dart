import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:provider/provider.dart'; 
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
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';

class GmvIndexPage extends StatefulWidget {
  const GmvIndexPage({super.key});

  @override
  State<GmvIndexPage> createState() => _GmvIndexPageState();
}

class _GmvIndexPageState extends State<GmvIndexPage> {
  @override
  Widget build(BuildContext context) {
    final gmvController = context.watch<GmvController>();
    final startDate = gmvController.startDate;
    final endDate = gmvController.endDate;
    final weeklySummaryData = gmvController.weeklySummary;

    String dateRangeText;
    if (startDate != null && endDate != null) {
      final formatter = DateFormat('dd MMMM yyyy');
      dateRangeText = 'Periode : ${formatter.format(startDate)} - ${formatter.format(endDate)}';
    } else {
      dateRangeText = 'Periode : Semua Data';
    }

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
              delay: 0.8,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, createRoute(const EditGmvPage()));
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
                        Navigator.push(context, createRoute(const AddGmvPage()));
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
              delay: 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomSubtitle(text: "Filter Grafik GMV"),
                  const CustomInfo(text: "Pilih periode untuk grafik GMV."),
                  const SizedBox(height: 8),
                  const FilterBar(),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            AnimatedFadeSlide(
              delay: 0.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSubtitle(text: "Grafik GMV"),
                  CustomInfo(text: dateRangeText),
                ],
              ),
            ),
            const AnimatedFadeSlide(
              delay: 0.4,
              child: SalesChartSection(),
            ),
            const SizedBox(height: 24),

            AnimatedFadeSlide(
              delay: 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSubtitle(text: "Data GMV"),
                  CustomInfo(text: dateRangeText),
                  const SizedBox(height: 8),
                  const AnimatedFadeSlide(
                    delay: 0.6,
                    child: TabelGmv(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            AnimatedFadeSlide(
              delay: 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSubtitle(
                    text: "Kuartal GMV Mingguan Bulan ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now())}",
                  ),
                  const SizedBox(height: 12),

                  if (gmvController.isLoading && weeklySummaryData.isEmpty)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else if (weeklySummaryData.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "Tidak ada data GMV untuk bulan ini.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildWeeklyCard(weeklySummaryData, 0)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildWeeklyCard(weeklySummaryData, 1)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildWeeklyCard(weeklySummaryData, 2)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildWeeklyCard(weeklySummaryData, 3)),
                          ],
                        ),
                      ],
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

  Widget _buildWeeklyCard(List<WeeklyGmvSummary> data, int index) {
    if (data.length > index) {
      final summary = data[index];
      return GmvWeeklyCard(
        mingguKe: summary.mingguKe,
        total: summary.total,
        isUp: summary.isUp,
      );
    }
    return GmvWeeklyCard(
      mingguKe: index + 1,
      total: 0.0,
      isUp: false,
    );
  }
}
