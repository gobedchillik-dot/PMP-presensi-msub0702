import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String nohp;
  final String role;
  final String norek;
  final String bank;
  final String panggilan;
  final String alamat;
  final bool isActive;
  // Anda bisa menambahkan field lain yang dibutuhkan di sini, seperti 'imageUrl', 'jabatan', dll.

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.nohp,
    required this.role,
    required this.norek,
    required this.bank,
    required this.panggilan,
    required this.alamat,
    required this.isActive,
  });

  // Factory constructor untuk membuat objek dari data Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      nohp: data['nohp'] ?? '',
      norek: data['norek'] ?? '',
      bank: data['bank'] ?? '',
      panggilan: data['panggilan'] ?? '',
      alamat: data['alamat'] ?? '',
      role: data['role'] ?? 'karyawan', // Default role jika tidak ditemukan
      isActive: data['isActive'] ?? 'true', // Default role jika tidak ditemukan
    );
  }

  // Konversi objek menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'nohp': nohp,
      'norek': norek,
      'bank': bank,
      'panggilan': panggilan,
      'alamat': alamat,
      'isActive': isActive,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(), // Timestamp untuk rekaman waktu
    };
  }
}