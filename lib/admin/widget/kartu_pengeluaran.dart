import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tes_flutter/admin/widget/data_row.dart';
import 'package:tes_flutter/admin/widget/profil_selection.dart';
import 'package:tes_flutter/database/controller/pengeluaran/fitur/pengeluaran_controller_fitur.dart';
import 'package:tes_flutter/database/model/pengeluaran.dart';

const String _kategoriOperasional = 'Operasional';

class OperationalExpenseCard extends StatelessWidget {
  final double initialDelay;

  const OperationalExpenseCard({
    required this.initialDelay,
  });
  
  // Helper untuk format mata uang
  String _formatMoney(double number) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0, 
    );
    return currencyFormatter.format(number).replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Selector untuk mendapatkan hanya data Pengeluaran Operasional dan status loading
    return Selector<PengeluaranController, (List<Pengeluaran>, double, bool)>(
      selector: (_, controller) => (
        controller.allExpenses.where((e) => e.kategori == _kategoriOperasional).toList(), // Filter di sini
        controller.totalOperationalCost, 
        controller.isLoading
      ),
      builder: (context, data, child) {
        final List<Pengeluaran> operationalExpenses = data.$1;
        final double total = data.$2;
        final bool isLoading = data.$3;

        final String formattedTotal = _formatMoney(total);

        return ProfileSectionWrapper(
          title: "Pengeluaran Operasional (Bulan Ini)",
          subtitle: "Total : $formattedTotal",
          children: [
            if (isLoading && operationalExpenses.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: Color(0xFF00ADB5)),
              ))
            else if (operationalExpenses.isEmpty) 
              const ProfileDataRow(
                label: "Tidak ada data pengeluaran operasional bulan ini.", 
                value: "",
              )
            else
              // Tampilkan data
              ...operationalExpenses.map((expense) { 
                final formattedValue = _formatMoney(expense.nominal);
                
                // 🔥 KOREKSI 1: Deklarasi dan penggunaan formattedDate
                final formattedDate = DateFormat('dd/MM').format(expense.dateTime); 
                
                return ProfileDataRow(
                  // Menggunakan formattedDate yang sudah dideklarasikan
                  label: '${expense.deskripsi} - $formattedDate', 
                  value: formattedValue,
                );
              }),
          ],
        );
      },
    );
  }
}

class OtherExpenseCard extends StatelessWidget {
  final double initialDelay;

  const OtherExpenseCard({
    required this.initialDelay,
  });
  
  String _formatMoney(double number) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0, 
    );
    return currencyFormatter.format(number).replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Selector untuk mendapatkan hanya data Pengeluaran Lainnya dan status loading
    return Selector<PengeluaranController, (List<Pengeluaran>, double, bool)>(
      selector: (_, controller) => (
        controller.allExpenses.where((e) => e.kategori != _kategoriOperasional).toList(), // Filter di sini
        controller.totalOtherExpenses, 
        controller.isLoading
      ),
      builder: (context, data, child) {
        final List<Pengeluaran> otherExpenses = data.$1;
        final double total = data.$2;
        final bool isLoading = data.$3;

        final String formattedTotal = _formatMoney(total);

        return ProfileSectionWrapper(
          title: "Pengeluaran Lainnya (Bulan Ini)",
          subtitle: "Total : $formattedTotal",
          children: [
            if (isLoading && otherExpenses.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: Color(0xFF00ADB5)),
              ))
            else if (otherExpenses.isEmpty) 
              const ProfileDataRow(
                label: "Tidak ada data pengeluaran non-operasional bulan ini.", 
                value: "",
              )
            else
              // Tampilkan data
              ...otherExpenses.map((expense) { 
                final formattedValue = _formatMoney(expense.nominal);
                
                // 🔥 KOREKSI 2: Implementasi DateFormat yang sudah benar
                // Menggunakan getter .dateTime yang mengkonversi Timestamp ke DateTime
                final formattedDate = DateFormat('dd/MM').format(expense.dateTime); 
                
                return ProfileDataRow(
                  // Menghilangkan kategori dari label karena sudah jelas di judul "Pengeluaran Lainnya"
                  label: '${expense.deskripsi} (${expense.kategori}) - $formattedDate', 
                  value: formattedValue,
                );
              }),
          ],
        );
      },
    );
  }
}