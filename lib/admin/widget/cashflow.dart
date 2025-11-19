import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

Future<void> generateCashflowPdf({
  required String nama,
  required double estIncome,
  required double totalOperational,
  required double totalOtherExpenses,
  required double netProfit,
  required List<Map<String, dynamic>> weeklySummary, // [{'mingguKe':1,'total':1000000,'isUp':true}, ...]
  required List<Map<String, dynamic>> cashflowList, // Detail pengeluaran/gaji
}) async {
  final pdf = pw.Document();
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: "Rp ", decimalDigits: 0);

  // Hitung total gaji yang belum dibayar dari cashflowList
  double totalUnpaidSalary = 0.0;
  for (var item in cashflowList) {
    final kategori = (item['kategori'] ?? '').toString().toLowerCase();
    final nominal = (item['nominal'] ?? 0.0) as double;
    final isPaid = item['isPaid'] == true;
    if (kategori == 'gaji' && !isPaid) {
      totalUnpaidSalary += nominal;
    }
  }

  pw.Widget buildSummaryRow(String label, double value, {bool isHighlight = false}) {
    final color = value >= 0 ? PdfColors.green800 : PdfColors.red800;
    final bold = isHighlight ? pw.FontWeight.bold : pw.FontWeight.normal;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontWeight: bold)),
        pw.Text(currencyFormat.format(value), style: pw.TextStyle(fontWeight: bold, color: color)),
      ],
    );
  }

  pw.Widget buildWeeklyCard(Map<String, dynamic> data, bool isProfit) {
    final totalValue = (data['total'] ?? 0.0) as double;
    final amount = isProfit ? totalValue * 0.05 : totalValue;
    final isUp = data['isUp'] == true; 
    final mingguKe = data['mingguKe'] ?? '-';

    final color = isUp ? PdfColors.green800 : PdfColors.red800;

    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text("Minggu ke-$mingguKe", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text(isProfit ? "Profit" : "GMV", style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          pw.Text(currencyFormat.format(amount), style: pw.TextStyle(color: color, fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    build: (context) {
      return [
        pw.Text("Laporan Keuangan", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text("Nama: $nama"),
        pw.Text("Dicetak: ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}"),
        pw.SizedBox(height: 16),

        // Summary
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildSummaryRow("Est. Pemasukan", estIncome),
              buildSummaryRow("Gaji Belum Dibayar", totalUnpaidSalary),
              buildSummaryRow("Operasional", totalOperational),
              buildSummaryRow("Pengeluaran Lain", totalOtherExpenses),
              pw.Divider(),
              buildSummaryRow("Total Pengeluaran", totalUnpaidSalary + totalOperational + totalOtherExpenses, isHighlight: true),
              buildSummaryRow("Est. Keuntungan Bersih", netProfit, isHighlight: true),
            ],
          ),
        ),
        pw.SizedBox(height: 16),

        // Weekly GMV
        pw.Text("Weekly GMV", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 8,
          runSpacing: 8,
          children: weeklySummary.map((data) => buildWeeklyCard(data, false)).toList(),
        ),
        pw.SizedBox(height: 12),

        // Weekly Profit
        pw.Text("Weekly Profit (5%)", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 8,
          runSpacing: 8,
          children: weeklySummary.map((data) => buildWeeklyCard(data, true)).toList(),
        ),
        pw.SizedBox(height: 16),

        // Detail Cashflow
        pw.Text("Detail Cashflow", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Table.fromTextArray(
          headers: ["Tanggal", "Kategori", "Tipe", "Nominal", "Status"],
          data: cashflowList.map((item) {
            final tanggal = item['tanggal'] is DateTime
                ? DateFormat('dd/MM/yyyy').format(item['tanggal'])
                : item['tanggal']?.toString() ?? '-';
            final kategori = item['kategori'] ?? '-';
            final tipe = item['tipe'] ?? '-';
            final nominalValue = item['nominal'] ?? 0.0;
            final nominal = currencyFormat.format(nominalValue);

            final isPaid = item['isPaid'] == true; 
            final status = (kategori.toLowerCase() == 'gaji') ? (isPaid ? 'Lunas' : 'Belum Dibayar') : '-';

            return [tanggal, kategori, tipe, nominal, status];
          }).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
          cellAlignments: {
            3: pw.Alignment.centerRight,
            4: pw.Alignment.center,
          },
          cellStyle: const pw.TextStyle(fontSize: 10),
          border: pw.TableBorder.all(color: PdfColors.grey400),
        ),
      ];
    },
  ));

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
