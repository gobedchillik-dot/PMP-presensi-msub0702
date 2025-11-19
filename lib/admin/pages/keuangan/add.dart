// File: lib/views/admin/keuangan/add.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 IMPORT BARU: Untuk Timestamp
import 'package:tes_flutter/database/controller/pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'package:tes_flutter/database/model/pengeluaran.dart';
import '../../../utils/animated_fade_slide.dart'; 
import '../../base_page.dart'; 
import '../../../admin/widget/tittle_app.dart';


class KeuanganAddPage extends StatefulWidget {
  const KeuanganAddPage({super.key});

  @override
  State<KeuanganAddPage> createState() => _KeuanganAddPageState();
}

class _KeuanganAddPageState extends State<KeuanganAddPage> {
  
  // --- Form Keys dan Controllers ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _lainLainController = TextEditingController();
  
  // --- State untuk Dropdown & Date Picker ---
  String? _selectedKategori;
  DateTime _selectedDate = DateTime.now(); // Tetap menggunakan DateTime untuk UI Picker

  // Daftar Kategori Statis
  final List<String> _kategoriList = [
    'Operasional',
    'Konsumsi',
    'Akomodasi & Transport',
    'Lain-lain',
  ];

  // --- Helper Functions ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- Fungsi Submit Form ---
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 1. Dapatkan Kategori Akhir
      String finalKategori = _selectedKategori ?? 'Lain-lain';
      if (_selectedKategori == 'Lain-lain') {
        // PERINGATAN: Harus divalidasi juga bahwa _lainLainController.text tidak kosong.
        finalKategori = _lainLainController.text.trim();
      }
      
      // 2. 🔥 KONVERSI TANGGAL: Konversi DateTime ke Timestamp
      final finalTimestamp = Timestamp.fromDate(_selectedDate); 
      
      // 3. Buat objek Pengeluaran
      final newExpense = Pengeluaran(
        id: null, // Menggunakan null lebih eksplisit daripada string kosong
        tanggal: finalTimestamp, // 🔥 Menggunakan Timestamp yang sudah dikonversi
        deskripsi: _deskripsiController.text.trim(),
        // Membersihkan input nominal dari karakter non-angka sebelum parsing
        nominal: double.tryParse(_nominalController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0,
        kategori: finalKategori,
      );
      
      // 4. Panggil Controller untuk menyimpan data
      final controller = Provider.of<PengeluaranController>(context, listen: false);
      
      try {
        // Saya asumsikan metode addExpense Anda menerima objek Pengeluaran yang sudah lengkap
        await controller.addExpense(newExpense); 
        
        // Tampilkan notifikasi sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengeluaran berhasil ditambahkan!')),
          );
          // Kembali ke halaman sebelumnya
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan pengeluaran: $e')),
          );
        }
      }
    }
  }

  // --- Widget Build ---
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Tambah Pengeluaran",
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('keuanganAddScroll'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedFadeSlide(delay: 0.1, child: CustomAppTitle(title: "Tambah Pengeluaran", backToPage: null)),
            
            const SizedBox(height: 16),
            
            // --- Form Input Pengeluaran ---
            AnimatedFadeSlide(
              delay: 0.3,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF152A46),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      
                      // 1. Input Tanggal
                      _buildDateField(context),
                      const SizedBox(height: 16),
                      
                      // 2. Input Deskripsi
                      _buildTextFormField(
                        controller: _deskripsiController,
                        label: 'Deskripsi Pengeluaran',
                        icon: Icons.description,
                        validator: (value) => value == null || value.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),

                      // 3. Input Nominal
                      _buildTextFormField(
                        controller: _nominalController,
                        label: 'Nominal (Rp)',
                        icon: Icons.payments,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Nominal tidak boleh kosong';
                          // Lakukan validasi pada nilai yang sudah dibersihkan dari non-angka
                          if (double.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) == null) return 'Input harus berupa angka';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 4. Dropdown Kategori
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),

                      // 5. Input Lain-lain (Conditional)
                      if (_selectedKategori == 'Lain-lain')
                        _buildTextFormField(
                          controller: _lainLainController,
                          label: 'Nama Kategori Lainnya',
                          icon: Icons.category,
                          validator: (value) => value == null || value.isEmpty ? 'Nama kategori tidak boleh kosong' : null,
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // 6. Tombol Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: const Icon(Icons.check, color: Colors.black),
                          label: const Text("Simpan Pengeluaran"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // --- Private Widgets (Tidak ada perubahan) ---
  
  Widget _buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tanggal Pengeluaran", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C385C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.white),
            title: Text(
              DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate),
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.arrow_drop_down, color: Colors.white),
            onTap: () => _selectDate(context),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: const Color(0xFF00BCD4)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFF1C385C),
      ),
      validator: validator,
    );
  }
  
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Kategori Pengeluaran", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1C385C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              icon: Icon(Icons.list, color: Color(0xFF00BCD4)),
            ),
            value: _selectedKategori,
            hint: const Text("Pilih Kategori", style: TextStyle(color: Colors.white54)),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            dropdownColor: const Color(0xFF152A46),
            items: _kategoriList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedKategori = newValue;
                // Kosongkan field 'Lain-lain' jika kategori berubah
                if (newValue != 'Lain-lain') {
                  _lainLainController.clear();
                }
              });
            },
            validator: (value) => value == null ? 'Kategori harus dipilih' : null,
          ),
        ),
      ],
    );
  }
}