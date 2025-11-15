// lib/karyawan/home_page.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/karyawan/widget/kalender_kehadiran.dart';
import 'package:tes_flutter/karyawan/widget/kartu_statis.dart';
import 'package:tes_flutter/karyawan/widget/progres_absen.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';
import 'package:tes_flutter/ui_page/shimmer_page_loader.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/auth/auth_service.dart';
import 'base_page.dart';
import 'package:tes_flutter/database/controller/absen/homepage_karyawan_controller.dart'; 

class KaryawanHomePage extends StatefulWidget {
  const KaryawanHomePage({super.key});

  @override
  State<KaryawanHomePage> createState() => _KaryawanHomePageState();
}

class _KaryawanHomePageState extends State<KaryawanHomePage> {
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
      create: (context) => KaryawanHomeController(),
      child: Consumer<KaryawanHomeController>(
        builder: (context, controller, child) {
          if (AuthService.currentUser == null) {
            return const Center(child: Text("Tidak ada pengguna aktif"));
          }
          
          // --- KONDISI LOADING DENGAN SKELETON ---
          if (controller.isLoading) {
             return BasePage(
               title: controller.userName, 
               todayStatusMessage: "Memuat data...", 
               child: _buildSkeletonLoading(), 
             );
          }

          final int count = controller.currentAbsenceCount;
          final bool isComplete = count >= KaryawanHomeController.maxAbsencesPerDay;
          
          return BasePage(
            title: controller.userName,
            todayStatusMessage: controller.isToday,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedFadeSlide(
                    delay: 0.1,
                    beginY: 0.3,
                    child: Text(
                      "Dashboard Karyawan",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildStatCards(controller, count),
                  
                  const SizedBox(height: 24),

                  if (!isComplete) 
                    ...[
                      _buildAttendanceButton(context, controller, count, isComplete),
                      const SizedBox(height: 24),
                    ],
                  
                  // --- Kalender Absensi ---
                  AnimatedFadeSlide(
                    delay: 0.5,
                    child: CustomSubtitle(text: "Rekap absensi anda")
                  ),
                  const SizedBox(height: 12),
                  AnimatedFadeSlide(
                    delay: 0.6,
                    child: AttendanceCalendar(
                      attendanceData: controller.monthAttendance,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Progres Absensi ---
                  AnimatedFadeSlide(
                    delay: 0.7,
                    child: CustomSubtitle(text: "Progres absensi anda")
                  ),
                  const SizedBox(height: 12),
                  AnimatedFadeSlide(
                    delay: 0.8,
                    child: ProgressItem(
                      name: "Kehadiran Bulan Ini",
                      value: controller.daysInMonth > 0
                          ? controller.totalPresentDays / controller.daysInMonth
                          : 0,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET SKELETON LOADING ---
  Widget _buildSkeletonLoading() {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 24, width: 200, borderRadius: 4),
          const SizedBox(height: 16),
          
          // Kartu Statistik
          SkeletonBox(height: 80, width: double.infinity),
          const SizedBox(height: 12),
          SkeletonBox(height: 80, width: double.infinity),
          const SizedBox(height: 12),
          SkeletonBox(height: 80, width: double.infinity),
          const SizedBox(height: 24),

          // Tombol Absen Placeholder
          SkeletonBox(height: 50, width: double.infinity),
          const SizedBox(height: 24),

          // Subtitle Kalender
          SkeletonBox(height: 20, width: 150, borderRadius: 4),
          const SizedBox(height: 12),
          
          // Kalender
          SkeletonBox(height: 300, width: double.infinity),

          const SizedBox(height: 24),

          // Subtitle Progres
          SkeletonBox(height: 20, width: 150, borderRadius: 4),
          const SizedBox(height: 12),
          
          // Progress Item
          SkeletonBox(height: 50, width: double.infinity),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- WIDGET STAT CARDS (Tidak Berubah) ---
  Widget _buildStatCards(KaryawanHomeController controller, int count) {
    final bool isComplete = count >= KaryawanHomeController.maxAbsencesPerDay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedFadeSlide(
          delay: 0.2,
          child: StatCard(
            title: "Estimasi penghasilan",
            subtitle: "Rp 1.234.567,89",
            color: Colors.greenAccent.shade400,
            icon: Iconsax.money_4,
            onTap: () {},
          ),
        ),
        const SizedBox(height: 12),
        AnimatedFadeSlide(
          delay: 0.3,
          child: StatCard(
            title: "Sesi Absen Hari Ini",
            subtitle: "$count dari ${KaryawanHomeController.maxAbsencesPerDay} Sesi",
            color: isComplete
                ? Colors.blueAccent.shade400
                : (count > 0 ? Colors.amberAccent.shade400 : Colors.redAccent.shade200),
            icon: isComplete
                ? Iconsax.task_square
                : Iconsax.timer,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedFadeSlide(
          delay: 0.4,
          child: StatCard(
            title: "Total Hari Hadir",
            subtitle:
                "${controller.totalPresentDays} Hari dari ${controller.daysInMonth} Hari",
            color: Colors.purpleAccent.shade400,
            icon: Iconsax.video_tick,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  // --- WIDGET ATTENDANCE BUTTON (Tidak Berubah) ---
  Widget _buildAttendanceButton(BuildContext context, KaryawanHomeController controller, int count, bool isComplete) {
    final buttonColor = isComplete ? const Color.fromARGB(255, 255, 255, 255) : const Color(0xFF00E676);
    final buttonText = isComplete 
        ? "Kewajiban Absen Selesai" 
        : "Absen ${controller.nextAbsenceSession}";
        
    return AnimatedFadeSlide(
      delay: 0.2,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: controller.isLoading || isComplete ? null : () => controller.handleAttendance(context),
          icon: Icon(
            isComplete ? Icons.check_circle : Icons.add_circle, 
            color: controller.isLoading ? Colors.grey : Colors.black,
          ),
          label: controller.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}