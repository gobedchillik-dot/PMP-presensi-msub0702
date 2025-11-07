import 'package:flutter/material.dart';
import 'package:tes_flutter/admin/pages/karyawan/index.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import '../../../admin/base_page.dart';
import '../../../utils/animated_fade_slide.dart';
import '../../../db/controller/karyawan_controller.dart';
import '../../../db/model/user.dart';

class detailKaryawanPage extends StatefulWidget {
  final UserModel user; // ✅ Data user yang dipilih

  const detailKaryawanPage({super.key, required this.user});

  @override
  State<detailKaryawanPage> createState() => _detailKaryawanPageState();
}


class _detailKaryawanPageState extends State<detailKaryawanPage> {
  late Stream<UserModel?> userStream;
  final KaryawanController profilController = KaryawanController();

  @override
  void initState() {
    super.initState();
    userStream = profilController.streamUserByUid(widget.user.uid); // ✅ ambil data dari karyawan yang dipilih
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Detail Data - ${widget.user.panggilan}", // ✅ title = nama karyawan yang dipilih
      child: StreamBuilder<UserModel?>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }



          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Header
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

                // Foto Profil & Email
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
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.user.email,
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          widget.user.role,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Bio Data
                AnimatedFadeSlide(
                  delay: 0.3,
                  child: _ProfileSection(
                    title: "Bio data",
                    children: [
                      _DataRow(label: "Nama lengkap", value: widget.user.name),
                      _DataRow(label: "Panggilan", value: widget.user.panggilan),
                      _DataRow(label: "Alamat", value: widget.user.alamat, isMultiLine: true),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Perbankan
                AnimatedFadeSlide(
                  delay: 0.4,
                  child: _ProfileSection(
                    title: "Perbankan",
                    children: [
                      _DataRow(label: "Nomor rekening", value: widget.user.norek),
                      _DataRow(label: "Bank", value: widget.user.bank),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Kontak
                AnimatedFadeSlide(
                  delay: 0.5,
                  child: _ProfileSection(
                    title: "Kontak",
                    isSimple: true,
                    children: [
                      _SimpleCard(label: "Nomor hp", value: widget.user.nohp),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Tombol Keluar
                AnimatedFadeSlide(
                  delay: 0.6,
                  child: Row(
                    children: [
                      // Tombol Aktif / Non-aktif
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: const Color(0xFF1F3B5B),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                title: Text(
                                  widget.user.isActive ? 'Non-aktifkan Karyawan?' : 'Aktifkan Karyawan?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  widget.user.isActive
                                      ? 'Karyawan tidak akan bisa login lagi.'
                                      : 'Karyawan akan dapat login kembali.',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Batal', style: TextStyle(color: Colors.white70)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(
                                      widget.user.isActive ? 'Non-aktifkan' : 'Aktifkan',
                                      style: TextStyle(
                                        color: widget.user.isActive ? Colors.redAccent : Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await profilController.updateStatus(widget.user.uid, !widget.user.isActive);

                    Navigator.push(
                        context,
                        reverseCreateRoute(const KaryawanIndexPage()),
                    );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(widget.user.isActive
                                      ? 'Karyawan dinon-aktifkan'
                                      : 'Karyawan diaktifkan kembali'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.user.isActive ? Colors.red : Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            widget.user.isActive ? "Non-aktifkan" : "Aktifkan",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Tombol Hapus (Icon)
                      ElevatedButton(
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: const Color(0xFF1F3B5B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              title: const Text('Hapus Karyawan?', style: TextStyle(color: Colors.white)),
                              content: const Text(
                                'Data karyawan ini akan dihapus dari daftar karyawan.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Batal', style: TextStyle(color: Colors.white70)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child:
                                      const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );

                          if (confirmDelete == true) {
                            await profilController.deleteUserFirestore(widget.user.uid);

                    Navigator.push(
                        context,
                        reverseCreateRoute(const KaryawanIndexPage()),
                    );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Karyawan berhasil dihapus')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// ====================================================================
// Widget Pembantu (tidak berubah)
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
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
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
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
