// File: lib/models/pengeluaran_model.dart

class Pengeluaran {
  final String? id; // ID Dokumen Firestore
  final String deskripsi;
  final String kategori;
  final double nominal;
  final DateTime tanggal;
  final bool isPaid;

  Pengeluaran({
    this.id,
    required this.deskripsi,
    required this.kategori,
    required this.nominal,
    required this.tanggal,
    required this.isPaid,
  });

  // Konstruktor untuk membuat objek dari Map (dari Firestore)
  factory Pengeluaran.fromMap(String id, Map<String, dynamic> map) {
    // Asumsi: Jika nominal disimpan sebagai int di DB, kita konversi ke double
    final double nominalValue = (map['nominal'] as num?)?.toDouble() ?? 0.0;
    
    // Asumsi: tanggal disimpan sebagai Timestamp atau string yang bisa di-parse
    final dynamic rawDate = map['tanggal'];
    DateTime parsedDate;

    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      // Jika menggunakan Firestore Timestamp, logika konversinya berbeda, 
      // tapi untuk simulasi, kita gunakan DateTime.now() jika gagal
      parsedDate = DateTime.now(); 
    }

    return Pengeluaran(
      id: id,
      deskripsi: map['deskripsi'] as String? ?? 'N/A',
      kategori: map['kategori'] as String? ?? 'N/A',
      nominal: nominalValue,
      tanggal: parsedDate,
      isPaid: map['isPaid'] as bool? ?? false,
    );
  }

  // Metode untuk mengkonversi objek menjadi Map (untuk disimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'deskripsi': deskripsi,
      'kategori': kategori,
      'nominal': nominal,
      'tanggal': tanggal.toIso8601String(), // Simpan sebagai String ISO untuk simulasi
    };
  }
}