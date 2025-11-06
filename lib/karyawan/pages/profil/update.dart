import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../db/controller/profil_controller.dart';
import '../../base_page.dart';
import '../../../utils/animated_fade_slide.dart'; // Pastikan path ini benar
import 'index.dart';
import '../../../auth/auth_service.dart';

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

  Future<void> _loadCurrentUser() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('tbl_user')
            .doc(user.uid)
            .get();

        setState(() {
          userName = doc.data()?['name'] ?? user.email ?? 'Pengguna';
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'Tidak ada pengguna aktif';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = 'Gagal memuat user';
        isLoading = false;
      });
      debugPrint('Error load current user: $e');
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
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfilIndexPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: userName ?? "Tidak Diketahui",
      isPresentToday: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AnimatedFadeSlide(
                delay: 0.1,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilIndexPage()),
                      ),
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

              // Setiap field dibuat animasi terpisah
              AnimatedFadeSlide(delay: 0.2, child: _buildInputField("Nama Lengkap", _nameController)),
              AnimatedFadeSlide(delay: 0.3, child: _buildInputField("Panggilan", _panggilanController)),
              AnimatedFadeSlide(delay: 0.4, child: _buildInputField("Alamat", _alamatController, maxLines: 2)),
              const SizedBox(height: 12),
              AnimatedFadeSlide(delay: 0.5, child: _buildInputField("Nomor Rekening", _norekController)),
              AnimatedFadeSlide(delay: 0.6, child: _buildInputField("Bank", _bankController)),
              AnimatedFadeSlide(delay: 0.7, child: _buildInputField("Nomor HP", _phoneController, keyboard: TextInputType.phone)),

              const SizedBox(height: 32),

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
