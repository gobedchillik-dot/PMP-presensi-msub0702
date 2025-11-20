import 'package:flutter/material.dart';
import 'package:tes_flutter/admin/base_page.dart';
import 'package:tes_flutter/admin/home_page.dart';
import 'package:tes_flutter/admin/widget/attendance_tracker_section.dart';
import 'package:tes_flutter/admin/widget/tabel_absensi.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/ui_page/font_size_patern.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';

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

  @override
  Widget build(BuildContext context) {

    return BasePage(
      title: "Data Absen",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedFadeSlide(
              delay: 0.1,
              child: CustomAppTitle(
                title: "Data absensi",
                backToPage: const AdminHomePage(),
              ),
            ),

            const SizedBox(height: 20),

            AnimatedFadeSlide(
              delay:0.2,
              child: CustomSubtitle(text: "Tabel absensi")
            ),
            const SizedBox(height: 12),

            AnimatedFadeSlide(
              delay: 0.3,
              child: TabelAbsensi(
                headerScrollController: _headerScrollController,
                dataScrollController: _dataScrollController,
              ),
            ),

            const SizedBox(height: 24),
            AnimatedFadeSlide(
              delay:0.4,
              child: CustomSubtitle(text: "Absen tracker")
            ),
            AnimatedFadeSlide(
              delay: 0.5,
              child: const AttendanceTrackerSection(employeeData: [],),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
