import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  // Anda bisa menambahkan field lain yang dibutuhkan di sini, seperti 'imageUrl', 'jabatan', dll.

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  // Factory constructor untuk membuat objek dari data Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'pegawai', // Default role jika tidak ditemukan
    );
  }

  // Konversi objek menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(), // Timestamp untuk rekaman waktu
    };
  }
}