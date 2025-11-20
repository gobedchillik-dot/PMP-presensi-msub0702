// File: lib/database/model/absen/unpaid_salary_model.dart (Disesuaikan)

import 'package:cloud_firestore/cloud_firestore.dart';
// ... (Pastikan Anda mengimpor Timestamp dari cloud_firestore jika menggunakan factory fromMap)

class UnpaidSalaryModel {
  final String idUser; // ⚠️ KOREKSI: Menggunakan idUser
  final String userName;
  final int totalUnpaidCounts;
  final double unpaidAmount;
  final DateTime periodStartDate;
  final DateTime periodEndDate;

  UnpaidSalaryModel({
    required this.idUser, // ⚠️ KOREKSI: idUser
    required this.userName,
    required this.totalUnpaidCounts,
    required this.unpaidAmount,
    required this.periodStartDate,
    required this.periodEndDate,
  });

  // Jika Anda masih menggunakan fromMap (misalnya di admin/widget/employee_salary_card.dart)
  factory UnpaidSalaryModel.fromMap(Map<String, dynamic> map) {
    return UnpaidSalaryModel(
      idUser: map['idUser'] as String, // ⚠️ KOREKSI: Mengambil 'idUser'
      userName: map['userName'] as String,
      totalUnpaidCounts: map['totalUnpaidCounts'] as int,
      unpaidAmount: (map['unpaidAmount'] as num).toDouble(),
      
      // Penanganan tanggal
      periodStartDate: map['newPeriodStartDate'] is Timestamp 
          ? (map['newPeriodStartDate'] as Timestamp).toDate() 
          : map['newPeriodStartDate'] as DateTime, 
      periodEndDate: map['periodEndDate'] is Timestamp
          ? (map['periodEndDate'] as Timestamp).toDate()
          : map['periodEndDate'] as DateTime,
    );
  }

}