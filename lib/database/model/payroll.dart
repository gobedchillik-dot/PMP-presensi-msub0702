// File: lib/database/model/absen/absen_payroll_model.dart (Disesuaikan)

import 'package:cloud_firestore/cloud_firestore.dart';

class AbsenPayrollModel {
  final String? id; // ID Dokumen Firestore (id)
  final String idUser; // ⚠️ KOREKSI: Menggunakan idUser
  final Timestamp periodStartDate;
  final Timestamp periodEndDate;
  final bool isPaid;
  final Timestamp? paymentDate; 
  final double amountPaid;
  final int totalDaysPresent;

  AbsenPayrollModel({
    this.id,
    required this.idUser, // ⚠️ KOREKSI: idUser
    required this.periodStartDate,
    required this.periodEndDate,
    required this.isPaid,
    this.paymentDate, 
    required this.amountPaid,
    required this.totalDaysPresent,
  });

  // Factory Constructor untuk membuat model dari dokumen Firestore
  factory AbsenPayrollModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    return AbsenPayrollModel(
      id: doc.id,
      idUser: data['idUser'] as String, // ⚠️ KOREKSI: Mengambil dari field 'idUser'
      periodStartDate: data['periodStartDate'] as Timestamp, 
      periodEndDate: data['periodEndDate'] as Timestamp, 
      isPaid: data['isPaid'] ?? false, 
      paymentDate: data['paymentDate'] as Timestamp?, 
      amountPaid: (data['amountPaid'] as num?)?.toDouble() ?? 0.0, 
      totalDaysPresent: (data['totalDaysPresent'] as num?)?.toInt() ?? 0,
    );
  }

  // Method untuk mengubah model menjadi Map (untuk menyimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser, // ⚠️ KOREKSI: Menyimpan sebagai 'idUser'
      'periodStartDate': periodStartDate,
      'periodEndDate': periodEndDate,
      'isPaid': isPaid,
      'paymentDate': paymentDate, 
      'amountPaid': amountPaid,
      'totalDaysPresent': totalDaysPresent,
    };
  }
}