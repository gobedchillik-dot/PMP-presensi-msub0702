import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../model/gmv.dart';

// --- (Model WeeklyGmvSummary tetap sama) ---
class WeeklyGmvSummary {
  final int mingguKe;
  final double total;
  final bool isUp;
  final String dateRange;

  WeeklyGmvSummary({
    required this.mingguKe,
    required this.total,
    this.isUp = false,
    required this.dateRange,
  });
}

class GmvController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'tbl_gmv';

  // _selectedFilterIndex = 3 (Bulan Ini) dijadikan default
  int _selectedFilterIndex = 3; 
  int get selectedFilterIndex => _selectedFilterIndex;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  bool get isChartFilterToday => _selectedFilterIndex == 1;

  final _weeklySummaryController = StreamController<List<WeeklyGmvSummary>>.broadcast();
  Stream<List<WeeklyGmvSummary>> get weeklySummaryStream => _weeklySummaryController.stream;

  StreamSubscription<QuerySnapshot>? _gmvSubscription;

  List<WeeklyGmvSummary> _weeklySummary = [];
  List<WeeklyGmvSummary> get weeklySummary => _weeklySummary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GmvController() {
    // ⚠️ KOREKSI: Panggil setFilter saat inisialisasi untuk memicu pengambilan data
    setFilter(_selectedFilterIndex); 
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fungsi utilitas untuk mendapatkan hari terakhir dalam bulan
  DateTime _getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  // ⚠️ KOREKSI: Fungsi pemrosesan sekarang menerima startDate dan endDate
  Future<List<WeeklyGmvSummary>> _processWeeklySummary(
      List<GmvModel> allGmvData, DateTime startPeriod, DateTime endPeriod) async {
    
    // Perhitungan mingguan sekarang didasarkan pada rentang startPeriod - endPeriod
    List<WeeklyGmvSummary> summaries = [];
    List<double> weeklyTotals = [];
    final DateFormat formatter = DateFormat('dd MMM');

    // Asumsi: Kita membagi rentang waktu menjadi 4 bagian (untuk tampilan mingguan)
    // Walaupun logika ini kurang ideal untuk rentang waktu kustom,
    // kita pertahankan untuk memenuhi kebutuhan tampilan 4-minggu pada grafik.
    
    // Hitung durasi total dalam hari
    final totalDays = endPeriod.difference(startPeriod).inDays + 1;
    final daysPerInterval = (totalDays / 4).ceil(); // Pembagian rata

    for (int i = 0; i < 4; i++) {
      DateTime start;
      DateTime end;
      
      start = startPeriod.add(Duration(days: i * daysPerInterval));
      end = start.add(Duration(days: daysPerInterval - 1)).copyWith(hour: 23, minute: 59, second: 59);

      // Pastikan interval akhir tidak melewati batas akhir periode
      if (end.isAfter(endPeriod)) {
        end = endPeriod;
      }

      if (start.isAfter(endPeriod)) break; // Berhenti jika sudah melewati periode

      final gmvDataThisWeek = allGmvData.where((item) {
        final itemDate = item.tanggal.toDate();
        return itemDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
               itemDate.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();

      final totalGmv = gmvDataThisWeek.fold<double>(0.0, (sum, item) => sum + item.gmv);
      weeklyTotals.add(totalGmv);

      bool isUp = false;
      if (i > 0 && weeklyTotals.length > 1) {
        isUp = totalGmv > weeklyTotals[i - 1];
      }

      summaries.add(
        WeeklyGmvSummary(
          mingguKe: i + 1,
          total: totalGmv,
          isUp: isUp,
          dateRange: '${formatter.format(start)} - ${formatter.format(end)}',
        ),
      );
    }

    return summaries;
  }
  
  // ⚠️ FUNGSI BARU: Fungsi untuk memuat data GMV berdasarkan periode tertentu
  void fetchGmvDataForPeriod(DateTime start, DateTime end) {
    _gmvSubscription?.cancel();
    _setLoading(true);

    _gmvSubscription = _firestore
        .collection(_collectionName)
        // Gunakan parameter start dan end yang fleksibel
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .listen((snapshot) async {
          final allGmvData = snapshot.docs.map((doc) {
            // Perlu memastikan casting aman, asumsikan GmvModel.fromFirestore sudah memadai
            return GmvModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null);
          }).toList();

          // Panggil pemrosesan dengan rentang waktu yang sesuai
          final newSummaries = await _processWeeklySummary(allGmvData, start, end); 

          _weeklySummary = newSummaries;
          _weeklySummaryController.sink.add(newSummaries);
          _setLoading(false); // Selesai memuat
          notifyListeners();
        }, onError: (error) {
           _setLoading(false);
           // Tambahkan logging error di sini
        });
  }

  // ⚠️ FUNGSI LAMA DIGANTI
  // void _initializeWeeklySummaryStream() {} // FUNGSI INI DIHAPUS

  Future<bool> store({required double gmv, required DateTime tanggal}) async {
    _setLoading(true);
    try {
      final newGmv = GmvModel(id: '', gmv: gmv, tanggal: Timestamp.fromDate(tanggal));
      await _firestore.collection(_collectionName).add(newGmv.toFirestore());
      _setLoading(false);
      // PENTING: Panggil ulang pengambilan data untuk update real-time
      if (_startDate != null && _endDate != null) {
         fetchGmvDataForPeriod(_startDate!, _endDate!);
      }
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  // --- (update, destroy, filteredGmvStream, allGmvStream, show tetap sama) ---
  
  Future<bool> update(GmvModel gmvToUpdate) async {
    _setLoading(true);
    try {
      await _firestore
          .collection(_collectionName)
          .doc(gmvToUpdate.id)
          .update(gmvToUpdate.toFirestore());
      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  Future<bool> destroy(String id) async {
    _setLoading(true);
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  @override
  void dispose() {
    _gmvSubscription?.cancel();
    _weeklySummaryController.close();
    super.dispose();
  }

  Stream<List<GmvModel>> get filteredGmvStream {
    Query<Map<String, dynamic>> query = _firestore.collection(_collectionName);

    if (_startDate != null && _endDate != null) {
      query = query
          .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!))
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(_endDate!));
    }

    return query
        .orderBy('tanggal', descending: true)
        .withConverter<GmvModel>(
          fromFirestore: (snapshot, options) => GmvModel.fromFirestore(snapshot, options),
          toFirestore: (gmv, options) => gmv.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<GmvModel>> get allGmvStream {
    return _firestore
        .collection(_collectionName)
        .withConverter<GmvModel>(
          fromFirestore: (snapshot, options) => GmvModel.fromFirestore(snapshot, options),
          toFirestore: (gmv, options) => gmv.toFirestore(),
        )
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ⚠️ KOREKSI UTAMA ADA DI FUNGSI INI
  void setFilter(int index) {
    _selectedFilterIndex = index;
    final now = DateTime.now();

    switch (index) {
      case 1: // Hari Ini
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 2: // 7 Hari Terakhir
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 3: // ⬅️ PERUBAHAN UTAMA: Bulan Ini
        _startDate = DateTime(now.year, now.month, 1); // Tanggal 1 Bulan Ini
        _endDate = _getLastDayOfMonth(now);             // Akhir Bulan Ini
        break;
      case 0: 
        final lastMonthStart = DateTime(now.year, now.month - 1, 1); 
        
        _startDate = lastMonthStart; // Rentang Awal
        _endDate = _getLastDayOfMonth(now); // Rentang Akhir (Akhir bulan ini)
        break;
      default:
        break;
    }

    notifyListeners();
    
    // ⚠️ PENTING: Memicu pengambilan data baru jika tanggal telah diatur
    if (_startDate != null && _endDate != null) {
        fetchGmvDataForPeriod(_startDate!, _endDate!);
    } else if (_selectedFilterIndex == 0) {
        // Jika filter 'Semua Data', Anda perlu mekanisme fetch semua data
        // (Namun, untuk grafik 4-mingguan, kita biasanya tetap butuh rentang waktu.
        // Asumsi kita hanya fokus pada 3 filter utama untuk grafik)
    }
  }

  Future<GmvModel?> show(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return GmvModel.fromFirestore(doc, null);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}