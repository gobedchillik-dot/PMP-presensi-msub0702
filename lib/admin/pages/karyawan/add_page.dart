// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../database/controller/karyawan/karyawan_controller.dart';
import '../../../utils/animated_fade_slide.dart';
import '../../../utils/route_generator.dart';
import '../../base_page.dart';
import '../../widget/form_verifikasi.dart';
import 'index.dart';

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
  bool _loading = false;

  Future<void> _showVerifikasiDialog() async {
    await showDialog(
      context: context,
      builder: (_) => FormVerifikasi(
        onVerify: (adminPassword) async {
          Navigator.pop(context); // Tutup dialog

          // Cek sandi admin dulu
          try {
            final currentUser = FirebaseAuth.instance.currentUser;
            final credential = EmailAuthProvider.credential(
              email: currentUser!.email!,
              password: adminPassword,
            );
            await currentUser.reauthenticateWithCredential(credential);

            // Jika benar → lanjut simpan data
            await _simpanData();
          } on FirebaseAuthException catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ Verifikasi gagal: ${e.message}"),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _controller.addKaryawan(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("✅ Akun karyawan berhasil dibuat")),
        );
                    Navigator.push(
                        context,
                        reverseCreateRoute(const KaryawanIndexPage()),
                    );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Gagal menambah data: $e")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Tambah Akun Karyawan",
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Tombol Back di luar Box
            AnimatedFadeSlide(
              delay: 0.1,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                                          Navigator.push(
                        context,
                        reverseCreateRoute(const KaryawanIndexPage()),
                    );
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Buatkan akun untuk karyawan",
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

            Center(
              child: Container(
                width: 600,
                decoration: BoxDecoration(
                  color: const Color(0xFF152A46),
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
                  child: AnimatedFadeSlide(
                    delay: 0.2,
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _emailController,
                          label: "Email",
                          validator: (v) =>
                              v!.isEmpty ? "Email wajib diisi" : null,
                        ),
                        _buildInputField(
                          controller: _passwordController,
                          label: "Password",
                          obscure: true,
                          validator: (v) =>
                              v!.isEmpty ? "Password wajib diisi" : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _showVerifikasiDialog,
                            icon: const Icon(Icons.person_add_alt_1,
                                color: Colors.black),
                            label: Text(
                              _loading
                                  ? "Menyimpan..."
                                  : "Buat Akun untuk Karyawan",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w500),
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
