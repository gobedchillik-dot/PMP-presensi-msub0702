// File: lib/admin/pages/keuangan/update.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:tes_flutter/database/controller/pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'package:tes_flutter/database/model/pengeluaran.dart';
import '../../../utils/animated_fade_slide.dart'; 
import '../../base_page.dart'; 
import '../../../admin/widget/tittle_app.dart';


class KeuanganUpdatePage extends StatefulWidget {
  // 🔥 Properti wajib: Menerima data Pengeluaran yang akan diedit
  final Pengeluaran existingExpense;

  const KeuanganUpdatePage({super.key, required this.existingExpense});

  @override
  State<KeuanganUpdatePage> createState() => _KeuanganUpdatePageState();
}

class _KeuanganUpdatePageState extends State<KeuanganUpdatePage> {
  
  // --- Form Keys dan Controllers ---
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _deskripsiController;
  late final TextEditingController _nominalController;
  final TextEditingController _lainLainController = TextEditingController();
  
  // --- State untuk Dropdown & Date Picker ---
  String? _selectedKategori;
  late DateTime _selectedDate;
  
  // Daftar Kategori Statis
  final List<String> _kategoriList = [
    'Operasional',
    'Konsumsi',
    'Akomodasi & Transport',
    'Lain-lain',
  ];

  @override
  void initState() {
    super.initState();
    // 🔥 INISIALISASI CONTROLLER DENGAN DATA YANG ADA (EXISTING DATA)
    
    // Konversi nominal kembali ke format yang mudah diedit (misal: 25000)
    // PENTING: Anda mungkin perlu menggunakan mask/formatter jika Anda ingin format "Rp 25.000"
    _nominalController = TextEditingController(text: widget.existingExpense.nominal.toStringAsFixed(0));
    _deskripsiController = TextEditingController(text: widget.existingExpense.deskripsi);
    _selectedDate = widget.existingExpense.dateTime; // Menggunakan getter dateTime
    
    // Cek apakah kategori adalah salah satu dari kategori statis
    final String currentKategori = widget.existingExpense.kategori;
    if (_kategoriList.contains(currentKategori)) {
      _selectedKategori = currentKategori;
    } else {
      // Jika kategori di luar daftar statis, anggap itu 'Lain-lain' dan masukkan nilainya ke _lainLainController
      _selectedKategori = 'Lain-lain';
      _lainLainController.text = currentKategori;
    }
  }

  @override
  void dispose() {
    _deskripsiController.dispose();
    _nominalController.dispose();
    _lainLainController.dispose();
    super.dispose();
  }


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

  // 🔥 Fungsi Submit Form (Diubah menjadi UPDATE)
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 1. Dapatkan Kategori Akhir
      String finalKategori = _selectedKategori ?? 'Lain-lain';
      if (_selectedKategori == 'Lain-lain') {
        finalKategori = _lainLainController.text.trim();
      }
      
      // 2. Konversi Tanggal dan Nominal
      final finalTimestamp = Timestamp.fromDate(_selectedDate); 
      // Membersihkan input nominal dari karakter non-angka sebelum parsing
      final finalNominal = double.tryParse(_nominalController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0;
      
      // 3. Buat objek Pengeluaran (PENTING: ID harus sama dengan ID yang diedit)
      final updatedExpense = Pengeluaran(
        id: widget.existingExpense.id, // 🔥 Mempertahankan ID yang sudah ada!
        tanggal: finalTimestamp, 
        deskripsi: _deskripsiController.text.trim(),
        nominal: finalNominal,
        kategori: finalKategori,
      );
      
      // 4. Panggil Controller untuk UPDATE data
      final controller = Provider.of<PengeluaranController>(context, listen: false);
      
      try {
        await controller.updateExpense(updatedExpense); // Asumsi Anda punya fungsi updateExpense
        
        // Tampilkan notifikasi sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengeluaran berhasil diperbarui!')),
          );
          // Kembali ke halaman sebelumnya (Halaman Edit)
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui pengeluaran: $e')),
          );
        }
      }
    }
  }

  // --- Widget Build (Sama persis dengan add.dart) ---
  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Edit Pengeluaran",
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('keuanganUpdateScroll'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedFadeSlide(delay: 0.1, child: CustomAppTitle(title: "Edit Pengeluaran", backToPage: null)),
            
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
                          icon: const Icon(Icons.save, color: Colors.black), // Ubah icon menjadi save
                          label: const Text("Simpan Perubahan"),
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
  
  // --- Private Widgets (Sama persis dengan add.dart) ---
  
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