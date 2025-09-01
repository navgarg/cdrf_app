import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../models/inventory_item.dart';
import '../api/transaction_service.dart';
import '../api/inventory_service.dart';
import '../general/messenger.dart';

final excelServiceProvider = Provider((ref) => ExcelService(ref));

class ExcelService {
  final Ref _ref;

  ExcelService(this._ref);

  Future<void> exportTransactionsToExcel() async {
    final transactions = await _ref.read(transactionServiceProvider).streamTransactions().first;


    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Daily Sales Transactions'];

    final firstTransaction = transactions.isNotEmpty ? transactions.first : null;
    if (firstTransaction != null) {
      final headers = firstTransaction.toMap().keys.toList();
      sheetObject.appendRow(headers.map((h) => TextCellValue(h.toString())).toList());
    }

    for (var transaction in transactions) {
      InventoryItem? item;
      try {
        item = await _ref.read(inventoryServiceProvider).streamInventoryItem(transaction.productId).first;
      } catch (e) {
        _ref.read(messengerProvider).showError('Error fetching inventory item for product ID ${transaction.productId}: $e');
        item = null;
      }
      final productName = item?.name ?? 'Unknown Product';

      final Map<String, dynamic> transactionMap = transaction.toMap();
      final List<String> keys = transactionMap.keys.toList();
      final int productIdIndex = keys.indexOf('productId');
      if (productIdIndex != -1) {
        keys.insert(productIdIndex + 1, 'productName');
      } else {
        keys.add('productName');
      }

      final List<CellValue?> rowData = keys.map((key) {
        if (key == 'productName') return TextCellValue(productName);
        final value = transactionMap[key];
        if (value == null) return TextCellValue('N/A');
        if (value is DateTime) return TextCellValue(value.toIso8601String().split('T').first);
        if (value is int) return IntCellValue(value);
        if (value is double) return DoubleCellValue(value);
        return TextCellValue(value.toString());
      }).toList();
      
      sheetObject.appendRow(rowData);
    }

    final directory = await path_provider.getApplicationDocumentsDirectory();
    final path = '${directory.path}/Daily_Sales_Transactions.xlsx';
    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      _ref.read(messengerProvider).showSuccess('Excel file saved to: $path');
    } else {
      _ref.read(messengerProvider).showError('Failed to save Excel file.');
    }
  }
}