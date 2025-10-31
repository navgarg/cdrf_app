import '../../services/admin/admin_analytics_service.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../models/product_item.dart';
import '../api/transaction_service.dart';
import '../api/inventory_service.dart';
import '../general/messenger.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

final excelServiceProvider = Provider((ref) => ExcelService(ref));

class ExcelService {
  final Ref _ref;

  ExcelService(this._ref);

  Future<bool> _requestStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted ||
        await Permission.storage.isGranted) {
      return true;
    }

    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;

    status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<String> _saveExcelToDownloads(
      Uint8List excelBytes, String fileName) async {
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      throw Exception('Storage permission not granted');
    }

    // Public Downloads folder path
    final downloadsDir = Directory('/storage/emulated/0/Download');

    // Ensure it exists
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final filePath = '${downloadsDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(excelBytes);

    return filePath;
  }

  Future<void> exportTransactionsToExcel() async {
    final transactions =
        await _ref.read(transactionServiceProvider).streamTransactions().first;

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Daily Sales Transactions'];

    final firstTransaction =
        transactions.isNotEmpty ? transactions.first : null;
    if (firstTransaction != null) {
      final headers = firstTransaction.toMap().keys.toList();
      sheetObject
          .appendRow(headers.map((h) => TextCellValue(h.toString())).toList());
    }

    for (var transaction in transactions) {
      ProductItem? item;
      try {
        item = await _ref
            .read(inventoryServiceProvider)
            .streamProductItem(transaction.productId)
            .first;
      } catch (e) {
        _ref.read(messengerProvider).showError(
            'Error fetching inventory item for product ID ${transaction.productId}: $e');
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
        if (value is DateTime) {
          return TextCellValue(value.toIso8601String().split('T').first);
        }
        if (value is int) return IntCellValue(value);
        if (value is double) return DoubleCellValue(value);
        return TextCellValue(value.toString());
      }).toList();

      sheetObject.appendRow(rowData);
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final filePath = await _saveExcelToDownloads(
        Uint8List.fromList(fileBytes),
        'Daily_Sales_Transactions.xlsx',
      );
      _ref.read(messengerProvider).showSuccess(
            'Excel file saved to Downloads: $filePath',
          );
    } else {
      _ref.read(messengerProvider).showError('Failed to save Excel file.');
    }
  }

  Future<void> exportAdminAnalyticsToExcel() async {
    final analytics =
        await _ref.read(adminAnalyticsServiceProvider).getDashboardStats();

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Admin Dashboard Analytics'];

    // Add headers
    final headers = analytics.keys.toList();
    sheetObject
        .appendRow(headers.map((h) => TextCellValue(h.toString())).toList());

    // Add data
    final rowData = analytics.values.map((value) {
      if (value == null) return TextCellValue('N/A');
      if (value is DateTime) {
        return TextCellValue(value.toIso8601String().split('T').first);
      }
      if (value is int) return IntCellValue(value);
      if (value is double) return DoubleCellValue(value);
      return TextCellValue(value.toString());
    }).toList();
    sheetObject.appendRow(rowData);

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final filePath = await _saveExcelToDownloads(
        Uint8List.fromList(fileBytes),
        'Admin_Dashboard_Analytics.xlsx',
      );
      _ref.read(messengerProvider).showSuccess(
            'Admin analytics Excel file saved to Downloads: $filePath',
          );
    } else {
      _ref
          .read(messengerProvider)
          .showError('Failed to save admin analytics Excel file.');
    }
  }
}
