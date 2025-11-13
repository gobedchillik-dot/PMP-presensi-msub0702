import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../db/controller/karyawan_controller.dart';
import '../../../db/model/user.dart';
import '../../widget/animated_fade_slide.dart';
import '../../base_page.dart';
import '../../home_page.dart';
import 'add.page.dart';

class KaryawanIndexPage extends StatefulWidget {
  const KaryawanIndexPage({super.key});

  @override
  State<KaryawanIndexPage> createState() => _KaryawanIndexPageState();
}

class _KaryawanIndexPageState extends State<KaryawanIndexPage> {
  final KaryawanController _controller = KaryawanController();


// =====================================
// === DETAIL POPUP (DENGAN UPLOAD WAJAH)
// =====================================
void _showDetailDialog(UserModel user) {
  final TextEditingController emailController =
      TextEditingController(text: user.email);
  final TextEditingController namaController =
      TextEditingController(text: user.name);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF152A46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Detail Karyawan',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Tampilkan foto wajah dari base64
              if (user.faceImage != null &&
                  user.faceImage!.isNotEmpty)
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(user.faceImage!),
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Foto wajah terdaftar",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              else
                Column(
                  children: const [
                    Icon(Icons.face_retouching_off,
                        size: 80, color: Colors.white54),
                    SizedBox(height: 8),
                    Text(
                      "Belum ada wajah terdaftar",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(height: 16),
                  ],
                ),

              // 🔹 Form edit data
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: namaController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.face),
            label: const Text('Upload Wajah'),
            onPressed: () {
              _uploadFaceToFacePlus(context, user.uid);
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              await _controller.updateKaryawan(
                user.uid,
                {
                  'email': emailController.text.trim(),
                  'name': namaController.text.trim(),
                },
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil diperbarui!')),
                );
              }
            },
            child: const Text('Simpan Perubahan'),
          ),
        ],
      );
    },
  );
}

// =====================================
// === UPLOAD FOTO KE FACE++ (PAKE BASE64)
// =====================================
Future<void> _uploadFaceToFacePlus(BuildContext context, String uid) async {
  const String apiKey = 'vLyZVMDR_GzfyZrBrg-c1079Wcu4Iamw';
  const String apiSecret = 'kG8h1bie531eS5lQ4aV6vEDcynPZpWBC';
  final picker = ImagePicker();

  try {
    // 1️⃣ Ambil foto dari kamera
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final originalFile = File(picked.path);

    // 2️⃣ Kompres foto
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengompres gambar.')),
      );
      return;
    }

    final compressedFile = File(compressedResult.path);

    // 3️⃣ Encode gambar ke base64
    final bytes = await compressedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    // 4️⃣ Kirim ke Face++
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

        // 5️⃣ Simpan ke Firestore (face_id + base64)
        await FirebaseFirestore.instance.collection('tbl_user').doc(uid).update({
          'face_id': faceToken,
          'face_image': base64Image,
        });

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wajah berhasil disimpan ke Face++ dan Firestore!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendeteksi wajah dari foto.')),
        );
      }
    } else {
      debugPrint("Error Face++: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload ke Face++: ${response.body}')),
      );
    }
  } catch (e) {
    debugPrint('Upload error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}




  // =====================================
  // === BUILD PAGE
  // =====================================
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Data Karyawan",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedFadeSlide(
              delay: 0.1,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const adminHomePage()),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Data Karyawan",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== TOMBOL TAMBAH =====
            AnimatedFadeSlide(
              delay: 0.2,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const KaryawanAddPage()),
                    );
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.black),
                  label: const Text(
                    "Buatkan akun untuk karyawan",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== LIST KARYAWAN =====
            AnimatedFadeSlide(
              delay: 0.4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF152A46),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<List<UserModel>>(
                  stream: _controller.streamKaryawan(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Text(
                        'Terjadi kesalahan saat memuat data.',
                        style: TextStyle(color: Colors.redAccent),
                      );
                    }

                    final data = snapshot.data;
                    if (data == null || data.isEmpty) {
                      return const Text(
                        'Belum ada data karyawan.',
                        style: TextStyle(color: Colors.white),
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("No", style: TextStyle(color: Colors.white)),
                            Text("Nama lengkap",
                                style: TextStyle(color: Colors.white)),
                            Text("Detail",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        const Divider(color: Colors.white30),
                        ...List.generate(data.length, (index) {
                          final user = data[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    user.email,
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showDetailDialog(user);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E6AC9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                    ),
                                    child: const Text(
                                      "Detail",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
