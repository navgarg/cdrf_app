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

    // Add headers
    sheetObject.appendRow([
        TextCellValue('transaction_id'),
        TextCellValue('date'),
        TextCellValue('product_id'),
        TextCellValue('product_name'),
        TextCellValue('quantity_sold'),
        TextCellValue('unit_price'),
        TextCellValue('total_sale_value'),
        TextCellValue('cost_per_unit'),
        TextCellValue('margin'),
        TextCellValue('payment_mode'),
        TextCellValue('customer_id (opt.)'),
       ]);

    for (var transaction in transactions) {
      InventoryItem? item;
      try {
        item = await _ref.read(inventoryServiceProvider).streamInventoryItem(transaction.productId).first;
      } catch (e) {
        _ref.read(messengerProvider).showError('Error fetching inventory item for product ID ${transaction.productId}: $e');
        item = null; // Handle case where item might not be found
      }

      final productName = item?.name ?? 'Unknown Product';
      final totalSaleValue = transaction.quantity * transaction.price;
      final margin = (transaction.price - transaction.cost) * transaction.quantity;

      sheetObject.appendRow([
        TextCellValue(transaction.id),
        TextCellValue(transaction.timestamp.toIso8601String().split('T').first), // Date only
        TextCellValue(transaction.productId),
        TextCellValue(productName),
        IntCellValue(transaction.quantity),
        DoubleCellValue(transaction.price),
        DoubleCellValue(totalSaleValue),
        DoubleCellValue(transaction.cost),
        DoubleCellValue(margin),
        TextCellValue(transaction.transactionType.toString().split('.').last), // Assuming transactionType can map to payment_mode for now
        TextCellValue(''), // Placeholder for customer_id
      ]);
    }

    // Save the Excel file
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