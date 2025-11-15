import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import 'package:provider/provider.dart'; // <-- Import Provider
import '../../../database/controller/karyawan/profil_controller.dart';
import '../../base_page.dart';
import '../../../utils/animated_fade_slide.dart'; 
import 'index.dart';
import '../../../auth/auth_service.dart';
// Import Controller Absensi yang berisi status isToday
import '../../../database/controller/absen/homepage_karyawan_controller.dart'; 

class ProfilUpdatePage extends StatefulWidget {
  const ProfilUpdatePage({super.key});

  @override
  State<ProfilUpdatePage> createState() => _ProfilUpdatePageState();
}

class _ProfilUpdatePageState extends State<ProfilUpdatePage> {
  String? userName;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final ProfilController _profilController = ProfilController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _panggilanController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _norekController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadCurrentUser();
  }

  // Jangan lupa membuang (dispose) controller saat widget dibuang
  @override
  void dispose() {
    _nameController.dispose();
    _panggilanController.dispose();
    _alamatController.dispose();
    _norekController.dispose();
    _bankController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        // Karena data profil dimuat secara terpisah, kita bisa menggunakan
        // email sebagai fallback nama jika Firestore belum selesai.
        setState(() {
          userName = user.email ?? 'Pengguna';
          isLoading = false;
        });
        
        // Memuat nama asli (name) dari Firestore untuk title
        final doc = await FirebaseFirestore.instance
            .collection('tbl_user')
            .doc(user.uid)
            .get();
        
        if (mounted) {
          setState(() {
            userName = doc.data()?['name'] ?? user.email ?? 'Pengguna';
          });
        }
      } else {
        setState(() {
          userName = 'Tidak ada pengguna aktif';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error load current user: $e');
      if(mounted) {
        setState(() {
          userName = 'Gagal memuat user';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProfileData() async {
    final user = await _profilController.getCurrentUserProfileOnce();
    if (user != null) {
      _nameController.text = user.name;
      _panggilanController.text = user.panggilan;
      _alamatController.text = user.alamat;
      _norekController.text = user.norek;
      _bankController.text = user.bank;
      _phoneController.text = user.nohp;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedData = {
      'name': _nameController.text.trim(),
      'panggilan': _panggilanController.text.trim(),
      'alamat': _alamatController.text.trim(),
      'norek': _norekController.text.trim(),
      'bank': _bankController.text.trim(),
      'nohp': _phoneController.text.trim(),
    };

    await _profilController.updateUserProfile(updatedData);
    
    if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigasi kembali ke halaman index setelah berhasil menyimpan
        Navigator.push(
          context,
          reverseCreateRoute(const ProfilIndexPage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tambahkan ChangeNotifierProvider di sini untuk KaryawanHomeController
    return ChangeNotifierProvider<KaryawanHomeController>(
      create: (context) => KaryawanHomeController(),
      child: Consumer<KaryawanHomeController>(
        builder: (context, homeController, child) {
          // 2. Gunakan BasePage, meneruskan nilai isToday dari homeController
          return BasePage(
            title: userName ?? "Memuat...",
            todayStatusMessage: homeController.isToday, // <-- STATUS ABSENSI DI SINI
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
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
                                reverseCreateRoute(const ProfilIndexPage()),
                              );
                            },
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Edit Profil",
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

                    // Input Fields
                    AnimatedFadeSlide(delay: 0.2, child: _buildInputField("Nama Lengkap", _nameController)),
                    AnimatedFadeSlide(delay: 0.3, child: _buildInputField("Panggilan", _panggilanController)),
                    AnimatedFadeSlide(delay: 0.4, child: _buildInputField("Alamat", _alamatController, maxLines: 2)),
                    const SizedBox(height: 12),
                    AnimatedFadeSlide(delay: 0.5, child: _buildInputField("Nomor Rekening", _norekController)),
                    AnimatedFadeSlide(delay: 0.6, child: _buildInputField("Bank", _bankController)),
                    AnimatedFadeSlide(delay: 0.7, child: _buildInputField("Nomor HP", _phoneController, keyboard: TextInputType.phone)),

                    const SizedBox(height: 32),

                    // Tombol Simpan
                    AnimatedFadeSlide(
                      delay: 0.8,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00ADB5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Simpan Perubahan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF152A46),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}