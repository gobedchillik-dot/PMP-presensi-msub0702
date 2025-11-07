import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tes_flutter/admin/base_page.dart';
import 'package:tes_flutter/db/model/gmv.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import '../../../db/controller/gmv_controller.dart';

class GmvEditPage extends StatefulWidget {
  final GmvModel gmv; // Data GMV yang akan diedit
  const GmvEditPage({super.key, required this.gmv});

  @override
  State<GmvEditPage> createState() => _GmvEditPageState();
}

class _GmvEditPageState extends State<GmvEditPage> {
  final _formKey = GlobalKey<FormState>();
  final GmvController _gmvController = GmvController();

  late TextEditingController _gmvControllerField;
  late TextEditingController _tanggalController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _gmvControllerField =
        TextEditingController(text: widget.gmv.gmv.toStringAsFixed(0));

    final initialDate = widget.gmv.tanggal.toDate();
    _selectedDate = initialDate;
    _tanggalController =
        TextEditingController(text: DateFormat('dd-MM-yyyy').format(initialDate));
  }

  @override
  void dispose() {
    _gmvControllerField.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  // === PICK TANGGAL ===
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  // === SIMPAN PERUBAHAN ===
  Future<void> _updateData() async {
    if (!_formKey.currentState!.validate()) return;

    final gmvValue = double.tryParse(_gmvControllerField.text);
    if (gmvValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nilai GMV tidak valid")),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tanggal harus diisi")),
      );
      return;
    }

    final updatedGmv = GmvModel(
      id: widget.gmv.id,
      gmv: gmvValue,
      tanggal: Timestamp.fromDate(_selectedDate!),
      createdAt: widget.gmv.createdAt,
    );

    final success = await _gmvController.update(updatedGmv);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data GMV berhasil diperbarui")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memperbarui data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Edit GMV",
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER (Judul & Tombol Kembali) ===
              AnimatedFadeSlide(
                delay: 0.1,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Edit Data GMV",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // === FORM INPUT ===
              AnimatedFadeSlide(
                delay: 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input GMV
                    TextFormField(
                      controller: _gmvControllerField,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "GMV (Rp)",
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "GMV tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Input Tanggal
                    TextFormField(
                      controller: _tanggalController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: const InputDecoration(
                        labelText: "Tanggal",
                        suffixIcon:
                            Icon(Icons.calendar_today, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Tanggal tidak boleh kosong";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Simpan Perubahan",
                          style: TextStyle(fontSize: 16),
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
    );
  }
}
