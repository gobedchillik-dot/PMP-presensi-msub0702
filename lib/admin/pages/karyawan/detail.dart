// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tes_flutter/admin/pages/karyawan/index.dart';
import 'package:tes_flutter/admin/widget/tittle_app.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import '../../../admin/base_page.dart';
import '../../../utils/animated_fade_slide.dart';
import '../../../database/controller/karyawan/karyawan_controller.dart';
import '../../../database/model/user.dart';

class DetailKaryawanPage extends StatefulWidget {
  final UserModel user;

  const DetailKaryawanPage({super.key, required this.user});

  @override
  State<DetailKaryawanPage> createState() => _DetailKaryawanPageState();
}

class _DetailKaryawanPageState extends State<DetailKaryawanPage> {
  late Stream<UserModel?> userStream;
  final KaryawanController profilController = KaryawanController();

  @override
  void initState() {
    super.initState();
    userStream = profilController.streamUserByUid(widget.user.uid);
  }

  // ==============================================================
  // 🔹 FUNGSI: Upload foto wajah ke Face++
  // ==============================================================
  Future<void> _uploadFaceToFacePlus(BuildContext context, String uid) async {
    const String apiKey = 'vLyZVMDR_GzfyZrBrg-c1079Wcu4Iamw';
    const String apiSecret = 'kG8h1bie531eS5lQ4aV6vEDcynPZpWBC';
    final picker = ImagePicker();

    try {
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked == null) return;

      final originalFile = File(picked.path);
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          "${tempDir.path}/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final compressedResult = await FlutterImageCompress.compressAndGetFile(
        originalFile.path,
        targetPath,
        quality: 90,
        minWidth: 1000,
        minHeight: 1000,
      );

      if (compressedResult == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengompres gambar.')),
        );
        return;
      }

      final bytes = await compressedResult.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse("https://api-us.faceplusplus.com/facepp/v3/detect"),
        body: {
          'api_key': apiKey,
          'api_secret': apiSecret,
          'image_base64': base64Image,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['faces'] != null && data['faces'].isNotEmpty) {
          final faceToken = data['faces'][0]['face_token'];

          await FirebaseFirestore.instance
              .collection('tbl_user')
              .doc(uid)
              .update({'face_id': faceToken, 'face_image': base64Image});

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wajah berhasil disimpan ke Face++ dan Firestore!'),
            ),
          );
          setState(() {}); // Refresh tampilan
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mendeteksi wajah dari foto.')),
          );
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload ke Face++: ${response.body}')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  // ==============================================================
  // 🔹 UI
  // ==============================================================
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Detail Data - ${widget.user.panggilan}",
      child: StreamBuilder<UserModel?>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final user = snapshot.data ?? widget.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                AnimatedFadeSlide(
                  delay: 0.1,
                  child: CustomAppTitle(
                    title: "Detail profil",
                    backToPage: const KaryawanIndexPage(),
                  ),
                ),

                const SizedBox(height: 24),

                // Foto Profil
                Center(
                  child: AnimatedFadeSlide(
                    delay: 0.2,
                    child: Column(
                      children: [
                        // ✅ Foto wajah dari Face++
                        if (user.faceImage != null &&
                            user.faceImage!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.memory(
                              base64Decode(user.faceImage!),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white12,
                              border: Border.all(
                                color: Colors.white24,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white54,
                            ),
                          ),

                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _uploadFaceToFacePlus(context, user.uid),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Upload Wajah"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.headlineSmall!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          user.role,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
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
                      _DataRow(
                        label: "Alamat",
                        value: user.alamat,
                        isMultiLine: true,
                      ),
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

                // Tombol Aktif/Nonaktif + Hapus
                AnimatedFadeSlide(
                  delay: 0.6,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFF1F3B5B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  user.isActive
                                      ? 'Non-aktifkan Karyawan?'
                                      : 'Aktifkan Karyawan?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  user.isActive
                                      ? 'Karyawan tidak akan bisa login lagi.'
                                      : 'Karyawan akan dapat login kembali.',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      user.isActive
                                          ? 'Non-aktifkan'
                                          : 'Aktifkan',
                                      style: TextStyle(
                                        color: user.isActive
                                            ? Colors.redAccent
                                            : Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await profilController.updateStatus(
                                user.uid,
                                !user.isActive,
                              );
                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                reverseCreateRoute(const KaryawanIndexPage()),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    user.isActive
                                        ? 'Karyawan dinon-aktifkan'
                                        : 'Karyawan diaktifkan kembali',
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: user.isActive
                                ? Colors.red
                                : Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            user.isActive ? "Non-aktifkan" : "Aktifkan",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: const Color(0xFF1F3B5B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text(
                                'Hapus Karyawan?',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Data karyawan ini akan dihapus dari daftar karyawan.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmDelete == true) {
                            await profilController.deleteUserFirestore(
                              user.uid,
                            );
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              reverseCreateRoute(const KaryawanIndexPage()),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Karyawan berhasil dihapus'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ====================================================================
// WIDGET PEMBANTU
// ====================================================================

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
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
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
              overflow: isMultiLine ? TextOverflow.ellipsis : TextOverflow.clip,
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
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
