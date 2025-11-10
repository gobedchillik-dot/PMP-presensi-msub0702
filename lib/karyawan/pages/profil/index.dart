import 'package:flutter/material.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import '../../home_page.dart';
import '../../base_page.dart';
import '../../../utils/animated_fade_slide.dart'; // Pastikan path ini benar
import '../../../db/controller/profil_controller.dart';
import '../../../db/model/user.dart';
import '../../../auth/auth_service.dart';
import '../../../auth/login_page.dart';
import 'update.dart';

class ProfilIndexPage extends StatefulWidget {
  const ProfilIndexPage({super.key});

  @override
  State<ProfilIndexPage> createState() => _ProfilIndexPageState();
}

class _ProfilIndexPageState extends State<ProfilIndexPage> {
  late ProfilController profilController;

  @override
  void initState() {
    super.initState();
    profilController = ProfilController(); // ✅ Dibuat sekali
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: profilController.streamCurrentUserProfile(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return BasePage(
          title: user?.name ?? "Profil",
          isPresentToday: true,
          child: _buildContent(snapshot, user),
        );
      },
    );
  }

  Widget _buildContent(AsyncSnapshot<UserModel?> snapshot, UserModel? user) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (user == null) {
      return const Center(
        child: Text(
          'Data profil tidak ditemukan.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          AnimatedFadeSlide(
            delay: 0.1,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                                        Navigator.push(
                        context,
                        reverseCreateRoute(const KaryawanHomePage()),
                    );
                  },
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Profil",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Foto + Nama + Role + Edit
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
                    child: const Icon(Icons.person,
                        size: 80, color: Colors.white54),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.email,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(user.role,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                                          Navigator.push(
                        context,
                        createRoute(const ProfilUpdatePage()),
                    );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ADB5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text("Sesuaikan profil",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          AnimatedFadeSlide(
            delay: 0.3,
            child: _ProfileSection(
              title: "Bio data",
              children: [
                _DataRow(label: "Nama lengkap", value: user.name),
                _DataRow(label: "Panggilan", value: user.panggilan),
                _DataRow(label: "Alamat", value: user.alamat, isMultiLine: true),
              ],
            ),
          ),

          const SizedBox(height: 32),

          AnimatedFadeSlide(
            delay: 0.4,
            child: _ProfileSection(
              title: "Perbankan",
              children: [
                _DataRow(label: "Nomor rekening", value: user.norek),
                _DataRow(label: "Bank", value: user.bank),
              ],
            ),
          ),

          const SizedBox(height: 32),

          AnimatedFadeSlide(
            delay: 0.5,
            child: _ProfileSection(
              title: "Kontak",
              isSimple: true,
              children: [
                _SimpleCard(label: "Nomor hp", value: user.nohp),
              ],
            ),
          ),

          const SizedBox(height: 48),

          AnimatedFadeSlide(
            delay: 0.6,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Keluar",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isSimple;

  const _ProfileSection({
    required this.title,
    required this.children,
    this.isSimple = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        isSimple
            ? Column(children: children)
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF152A46),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: children),
              ),
      ],
    );
  }
}
class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiLine;

  const _DataRow({
    required this.label,
    required this.value,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          const Text(" : ", style: TextStyle(color: Colors.white)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              maxLines: isMultiLine ? 3 : 1,
              overflow:
                  isMultiLine ? TextOverflow.ellipsis : TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
class _SimpleCard extends StatelessWidget {
  final String label;
  final String value;

  const _SimpleCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF152A46),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
Future<void> _handleLogout(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1F3B5B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Konfirmasi Logout', style: TextStyle(color: Colors.white)),
      content: const Text('Apakah Anda yakin ingin keluar?',
          style: TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal', style: TextStyle(color: Colors.white70)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Keluar', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await AuthService.signOut();
    if (context.mounted) {
                    Navigator.push(
                        context,
                        reverseCreateRoute(const LoginPage()),
                    );
    }
  }
}

