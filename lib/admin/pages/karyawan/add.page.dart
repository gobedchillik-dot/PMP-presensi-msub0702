import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../db/controller/karyawan_controller.dart';
import '../../widget/animated_fade_slide.dart';
import '../../base_page.dart';
import '../../home_page.dart';

class KaryawanAddPage extends StatefulWidget {
  const KaryawanAddPage({super.key});

  @override
  State<KaryawanAddPage> createState() => _KaryawanAddPageState();
}

class _KaryawanAddPageState extends State<KaryawanAddPage> {
  final _controller = KaryawanController();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _panggilanController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _norekController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();

  bool _loading = false;

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 🔹 Buat akun Auth Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 🔹 Simpan data tambahan ke Firestore via Controller
      await _controller.addKaryawan(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        namaLengkap: _namaController.text.trim(),
        panggilan: _panggilanController.text.trim(),
        alamat: _alamatController.text.trim(),
        norek: _norekController.text.trim(),
        bank: _bankController.text.trim(),
        noTelp: _noTelpController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Akun karyawan berhasil dibuat")),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan";
      if (e.code == 'email-already-in-use') {
        message = "Email sudah digunakan.";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid.";
      } else if (e.code == 'weak-password') {
        message = "Password terlalu lemah.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ $message"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("❌ Gagal menambah data: $e"),
      ));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Tambah Data Karyawan",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: 600, // lebar form biar pas di tengah (responsive)
            decoration: BoxDecoration(
              color: const Color(0xFF152A46), // warna sama seperti topbar
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== TITLE BODY DENGAN BACK BUTTON =====
                  AnimatedFadeSlide(
                    delay: 0.1,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const adminHomePage(),
                                transitionsBuilder:
                                    (context, animation, _, child) {
                                  final fade = Tween(begin: 0.0, end: 1.0)
                                      .animate(animation);
                                  final slide = Tween<Offset>(
                                    begin: const Offset(-0.2, 0),
                                    end: Offset.zero,
                                  ).animate(animation);
                                  return FadeTransition(
                                    opacity: fade,
                                    child: SlideTransition(
                                        position: slide, child: child),
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Tambah Data Karyawan",
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

                  // ===== FORM INPUT =====
                  AnimatedFadeSlide(
                    delay: 0.2,
                    child: Column(
                      children: [
                        _buildInputField(
                            controller: _namaController,
                            label: "Nama Lengkap",
                            validator: (v) => v!.isEmpty
                                ? "Nama lengkap wajib diisi"
                                : null),
                        _buildInputField(
                            controller: _panggilanController,
                            label: "Nama Panggilan",
                            validator: (v) => v!.isEmpty
                                ? "Nama panggilan wajib diisi"
                                : null),
                        _buildInputField(
                            controller: _emailController,
                            label: "Email",
                            validator: (v) =>
                                v!.isEmpty ? "Email wajib diisi" : null),
                        _buildInputField(
                          controller: _passwordController,
                          label: "Password",
                          obscure: true,
                          validator: (v) =>
                              v!.isEmpty ? "Password wajib diisi" : null,
                        ),
                        _buildInputField(
                            controller: _noTelpController,
                            label: "No. Telepon",
                            validator: (v) => v!.isEmpty
                                ? "Nomor telepon wajib diisi"
                                : null),
                        _buildInputField(
                          controller: _alamatController,
                          label: "Alamat",
                          maxLines: 2,
                        ),
                        _buildInputField(
                            controller: _norekController,
                            label: "Nomor Rekening"),
                        _buildInputField(
                            controller: _bankController, label: "Nama Bank"),
                        const SizedBox(height: 24),

                        // ===== TOMBOL SIMPAN =====
                        AnimatedFadeSlide(
                          delay: 0.4,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _simpanData,
                              icon:
                                  const Icon(Icons.save, color: Colors.black),
                              label: Text(
                                _loading ? "Menyimpan..." : "Simpan Data",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00E676),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Widget pembantu untuk input
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: const Color(0xFF1E3B67),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}
