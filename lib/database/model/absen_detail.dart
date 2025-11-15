import 'package:cloud_firestore/cloud_firestore.dart';

class AbsenDetailModel {
  final Timestamp timestamp;
  final double latitude;
  final double longitude;
  final double? confidence;
  final String? selfieUrl;
  final String time; // Waktu format string (HH:mm:ss)

  AbsenDetailModel({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.confidence,
    this.selfieUrl,
    required this.time,
  });

  factory AbsenDetailModel.fromMap(Map<String, dynamic> data) {
    // Fungsi helper untuk mengambil double dengan aman
    double getDouble(String key) {
      final value = data[key];
      if (value is num) return value.toDouble();
      return 0.0;
    }

    return AbsenDetailModel(
      timestamp: data['timestamp'] ?? Timestamp.now(),
      latitude: getDouble('latitude'),
      longitude: getDouble('longitude'),
      // Confidence bersifat opsional
      confidence: data.containsKey('confidence') ? getDouble('confidence') : null, 
      selfieUrl: data['selfie_url'],
      time: data['time'] ?? '00:00:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'confidence': confidence,
      'selfie_url': selfieUrl,
      'time': time,
    };
  }
}