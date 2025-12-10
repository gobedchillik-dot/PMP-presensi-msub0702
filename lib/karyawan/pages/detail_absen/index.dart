// lib/karyawan/home_page/detail_absen_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/karyawan/home_page.dart';
import 'package:tes_flutter/ui_page/shimmer_page_loader.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/auth/auth_service.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import '../../base_page.dart';
import 'package:tes_flutter/database/controller/absen/homepage_karyawan_controller.dart';


class DetailAbsenPage extends StatefulWidget {
  const DetailAbsenPage({super.key});

  @override
  State<DetailAbsenPage> createState() => _DetailAbsenPageState();
}

class _DetailAbsenPageState extends State<DetailAbsenPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthService.checkUserProfileCompleteness(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KaryawanHomeController(),
      child: Consumer<KaryawanHomeController>(
        builder: (context, controller, child) {
          
          if (AuthService.currentUser == null) {
            return const Center(child: Text("Tidak ada pengguna aktif"));
          }

          // 🔥 Ambil data absensi real dari Controller
          // final absensiData = controller.convertedMonthlyAbsences;

          if (controller.isLoading) {
            return BasePage(
              title: controller.userName,
              todayStatusMessage: "Memuat data...",
              child: _buildSkeletonLoading(),
            );
          }
          
          // 🔥 TAMPILAN JIKA DATA ABSENSI KOSONG
          // if (absensiData.isEmpty) {
          //    return BasePage(
          //     title: controller.userName,
          //     todayStatusMessage: controller.isToday,
          //     child: const Center(
          //       child: Padding(
          //         padding: EdgeInsets.all(20.0),
          //         child: Text(
          //           "Tidak ada data absensi yang tercatat di bulan ini.", 
          //           style: TextStyle(color: Colors.white70, fontSize: 16),
          //           textAlign: TextAlign.center,
          //         ),
          //       ),
          //     ),
          //   );
          // }


          return BasePage(
            title: controller.userName,
            todayStatusMessage: controller.isToday,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedFadeSlide(
                    delay: 0.1,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            reverseCreateRoute(const KaryawanHomePage()),
                          ),
                          icon:
                              const Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Detail Absensi",
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
                    delay: 0.2,
                    child: Row(
                      children: const [
                        Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Detail absensi anda bulan ini",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- LIST ABSENSI MENGGUNAKAN DATA REAL ---
                  // Column(
                  //   children: List.generate(absensiData.length, (index) {
                  //     final data = absensiData[index];
                  //     // 🔥 Update status isExpanded berdasarkan state lokal
                  //     data.isExpanded = _expansionStates[data.tanggal] ?? false; 
                      
                  //     return AnimatedFadeSlide(
                  //       delay: 0.2 + (index * 0.1), // Delay sedikit dipercepat
                  //       child: AbsenDailyCard(
                  //         data: data,
                  //         // 🔥 Kirimkan tanggal sebagai key untuk toggle
                  //         onTap: () => _toggleExpansion(data.tanggal), 
                  //       ),
                  //     );
                  //   }),
                  // ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -------- SKELETON ----------
  Widget _buildSkeletonLoading() {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 24, width: 200, borderRadius: 4),
          SizedBox(height: 16),
          SkeletonBox(height: 80, width: double.infinity),
          SizedBox(height: 12),
          SkeletonBox(height: 80, width: double.infinity),
          SizedBox(height: 12),
          SkeletonBox(height: 80, width: double.infinity),
          SizedBox(height: 24),
          SkeletonBox(height: 50, width: double.infinity),
          SizedBox(height: 24),
          SkeletonBox(height: 20, width: 150),
          SizedBox(height: 12),
          SkeletonBox(height: 300, width: double.infinity),
          SizedBox(height: 24),
          SkeletonBox(height: 20, width: 150),
          SizedBox(height: 12),
          SkeletonBox(height: 50, width: double.infinity),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}