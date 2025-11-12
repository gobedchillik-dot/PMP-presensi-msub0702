// lib/admin/widget/sales_chart_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tes_flutter/database/controller/gmv/gmv_controller.dart';
import 'package:tes_flutter/database/model/gmv.dart';
import 'package:tes_flutter/ui_page/shimmer_page_loader.dart';
import 'filter_bar.dart'; // Import FilterBar yang baru dipisah

class SalesChartSection extends StatelessWidget {
  const SalesChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        FilterBar(), 
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2A3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: StreamBuilder<List<GmvModel>>(
            stream: context.read<GmvController>().gmvStream,
            builder: (context, snapshot) {
                // ... (Logika Chart Anda, diimpor ke sini)
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: SkeletonBox(),
                );
              }

              final data = snapshot.data!;
              data.sort((a, b) => a.tanggal.toDate().compareTo(b.tanggal.toDate()));

              return SfCartesianChart(
                backgroundColor: Colors.transparent,
                primaryXAxis: DateTimeAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                series: <LineSeries<GmvModel, DateTime>>[
                  LineSeries<GmvModel, DateTime>(
                    dataSource: data,
                    xValueMapper: (gmv, _) => gmv.tanggal.toDate(),
                    yValueMapper: (gmv, _) => gmv.gmv,
                    width: 2,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}