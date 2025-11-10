// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tes_flutter/utils/animated_fade_slide.dart';
import 'package:tes_flutter/utils/route_generator.dart';
import '../../../database/controller/gmv/gmv_controller.dart';
import '../../base_page.dart';
import 'index.dart';

class AddGmvPage extends StatefulWidget {
  const AddGmvPage({super.key});

  @override
  State<AddGmvPage> createState() => _AddGmvPageState();
}

class _AddGmvPageState extends State<AddGmvPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _gmvController = TextEditingController();
  DateTime? _selectedDate;
  final GmvController _gmvControllerDb = GmvController();

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      helpText: 'Pilih tanggal GMV',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal terlebih dahulu')),
      );
      return;
    }

    final gmvValue = double.tryParse(_gmvController.text);
    if (gmvValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai GMV tidak valid')),
      );
      return;
    }

    final success = await _gmvControllerDb.store(
      gmv: gmvValue,
      tanggal: _selectedDate!,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data GMV berhasil disimpan')),
      );
      Navigator.pushReplacement(
        context,
        reverseCreateRoute(const GmvIndexPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data GMV')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Tambah GMV',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER DENGAN BACK & ANIMASI
              AnimatedFadeSlide(
                delay: 0.1,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          reverseCreateRoute(const GmvIndexPage()),
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Tambah Data GMV",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // FIELD GMV
              AnimatedFadeSlide(
                delay: 0.2,
                child: TextFormField(
                  controller: _gmvController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nominal GMV',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'Masukkan nilai GMV (misal: 1500000)',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF1B2A3A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'GMV tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // PICK TANGGAL
              AnimatedFadeSlide(
                delay: 0.3,
                child: GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2A3A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Pilih tanggal'
                                : 'Tanggal: ${DateFormat("dd-MM-yyyy").format(_selectedDate!)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // TOMBOL SIMPAN
              AnimatedFadeSlide(
                delay: 0.4,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676), // warna template tombol
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan Data',
                      style: TextStyle(
                        color: Colors.black,
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
}
