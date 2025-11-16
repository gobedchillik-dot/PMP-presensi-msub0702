import 'package:cloud_firestore/cloud_firestore.dart';

class AbsenPayrollModel {
  final String? id; // ID Dokumen Firestore
  final String idUser;
  final Timestamp periodStartDate;
  final Timestamp periodEndDate;
  final bool isPaid;
  final Timestamp paymentDate;
  final double amountPaid;
  final int totalDaysPresent;

  AbsenPayrollModel({
    this.id,
    required this.idUser,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.isPaid,
    required this.paymentDate,
    required this.amountPaid,
    required this.totalDaysPresent,
  });

  // Factory Constructor untuk membuat model dari dokumen Firestore
  factory AbsenPayrollModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Safety check untuk memastikan semua field ada dan bertipe benar
    return AbsenPayrollModel(
      id: doc.id,
      idUser: data['idUser'] as String,
      periodStartDate: data['periodStartDate'] as Timestamp,
      periodEndDate: data['periodEndDate'] as Timestamp,
      isPaid: data['isPaid'] as bool,
      paymentDate: data['paymentDate'] as Timestamp,
      // Karena Firestore bisa menyimpan Number sebagai int atau double, 
      // kita konversi ke double untuk konsistensi
      amountPaid: (data['amountPaid'] as num).toDouble(), 
      // totalDaysPresent harus dijamin sebagai int
      totalDaysPresent: (data['totalDaysPresent'] as num).toInt(),
    );
  }

  // Method untuk mengubah model menjadi Map (untuk menyimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'periodStartDate': periodStartDate,
      'periodEndDate': periodEndDate,
      'isPaid': isPaid,
      'paymentDate': paymentDate,
      'amountPaid': amountPaid,
      'totalDaysPresent': totalDaysPresent,
    };
  }
}