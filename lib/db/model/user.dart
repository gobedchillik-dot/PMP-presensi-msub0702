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
  final String? faceId;     // 🔹 Token dari Face++
  final String? faceImage;  // 🔹 URL gambar wajah (bukan base64)

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
    this.faceId,
    this.faceImage,
  });

  // 🔹 Factory dari Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      nohp: data['nohp'] ?? '',
      role: data['role'] ?? 'karyawan',
      norek: data['norek'] ?? '',
      bank: data['bank'] ?? '',
      panggilan: data['panggilan'] ?? '',
      alamat: data['alamat'] ?? '',
      faceId: data['face_id'],
      faceImage: data['face_image'],
    );
  }

  // 🔹 Konversi ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'nohp': nohp,
      'role': role,
      'norek': norek,
      'bank': bank,
      'panggilan': panggilan,
      'alamat': alamat,
      'face_id': faceId ?? '',
      'face_image': faceImage ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
