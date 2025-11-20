import 'package:flutter/material.dart';
import 'package:tes_flutter/admin/widget/data_row.dart';
import 'package:tes_flutter/admin/widget/profil_selection.dart';
import 'package:tes_flutter/admin/widget/simple_card.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';

import '../../home_page.dart';
import '../../base_page.dart';
import '../../../utils/animated_fade_slide.dart';

class ProfilIndexPage extends StatelessWidget {
  const ProfilIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Profil',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const AnimatedFadeSlide(
              delay: 0.1,
              child: CustomAppTitle(
                title: "Profil",
                backToPage: AdminHomePage(),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: AnimatedFadeSlide(
                delay: 0.2,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white12,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: const Icon(Icons.person, size: 80, color: Colors.white54),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Msub0702 Official",
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("Admin", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            const AnimatedFadeSlide(
              delay: 0.3,
              child: ProfileSectionWrapper(
                title: "Bio data",
                children: [
                  ProfileDataRow(label: "Nama lengkap", value: "Admin"),
                  ProfileDataRow(label: "Panggilan", value: "Admin"),
                  ProfileDataRow(
                    label: "Alamat",
                    value: "Bojong, cilimus, kuningan",
                    isMultiLine: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const AnimatedFadeSlide(
              delay: 0.4,
              child: ProfileSectionWrapper(
                title: "Perbankan",
                children: [
                  ProfileDataRow(label: "Nomor rekening", value: "xxxxxxxxx"),
                  ProfileDataRow(label: "Bank", value: "BCA"),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const AnimatedFadeSlide(
              delay: 0.5,
              child: ProfileSectionWrapper(
                title: "Kontak",
                isSimple: true,
                children: [
                  ProfileSimpleCard(
                    label: "Nomor hp",
                    value: "089765885",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            AnimatedFadeSlide(
              delay: 0.6,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anda telah keluar.'),
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Keluar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
