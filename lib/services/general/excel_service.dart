import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:nariudyam/models/product_item.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:nariudyam/providers/fav_customer_providers.dart';
import 'package:nariudyam/providers/inventory_providers.dart';
import 'package:nariudyam/providers/transaction_providers.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:nariudyam/services/interfaces/i_auth_service.dart';
import 'package:nariudyam/services/interfaces/i_favourite_customer_service.dart';
import 'package:nariudyam/services/interfaces/i_transaction_service.dart';

// firebase (previous implementation)
// import 'package:nariudyam/services/api/auth_service.dart';
// import 'package:nariudyam/services/api/fav_customer_service.dart';
// import 'package:nariudyam/services/api/inventory_service.dart';
// import 'package:nariudyam/services/api/transaction_service.dart';

final excelServiceProvider = Provider((ref) => ExcelService(ref));

class ExcelService {
  final Ref _ref;
  final ITransactionService _transactionService;
  final IAuthService _authService;
  final IFavouriteCustomerService _favouriteCustomerService;

  ExcelService(this._ref)
      : _transactionService = _ref.read(transactionServiceProvider),
        _authService = _ref.read(authServiceProvider),
        _favouriteCustomerService = _ref.read(favouriteCustomerServiceProvider(
            _ref.read(authServiceProvider).currentUserId));

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

  Future<String?> _getDownloadDirectory() async {
    if (TargetPlatform.android == defaultTargetPlatform) {
      return '/storage/emulated/0/Download';
    } else if (TargetPlatform.iOS == defaultTargetPlatform) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      // For other platforms, you might need to implement platform-specific logic
      // or use a different directory.
      return null;
    }
  }

  Future<String> _saveExcelToDownloads(
      Uint8List excelBytes, String fileName) async {
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      throw Exception('Storage permission not granted');
    }

    final downloadsDir = await _getDownloadDirectory();
    if (downloadsDir == null) {
      throw Exception('Could not get download directory.');
    }

    // Ensure it exists
    if (!await Directory(downloadsDir).exists()) {
      await Directory(downloadsDir).create(recursive: true);
    }

    final filePath = '${downloadsDir}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(excelBytes);

    return filePath;
  }

  Future<void> exportAllAnalyticsToExcel() async {
    if (!await _requestStoragePermission()) {
      if (kDebugMode) {
        print('Storage permission not granted.');
      }
      return;
    }

    final excel = Excel
        .createExcel(); // Use createExcel() as createStorage() is not defined

    // Customer Analytics Sheet
    await _addCustomerAnalyticsSheet(excel);

    // Daily Sales Transactions Sheet
    await _addDailySalesTransactionsSheet(excel);

    // Admin Dashboard Analytics Sheet
    await _addAdminDashboardAnalyticsSheet(excel);

    final excelBytes = excel.encode();
    if (excelBytes == null) {
      if (kDebugMode) {
        print('Failed to encode Excel file.');
      }
      return;
    }

    try {
      final filePath = await _saveExcelToDownloads(
          Uint8List.fromList(excelBytes), 'Analytics.xlsx');
      if (kDebugMode) {
        print('Excel file saved to: $filePath');
      }
      _ref.read(messengerProvider).showSuccess(
            'All analytics Excel file saved to Downloads: $filePath',
          );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving Excel file: $e');
      }
      _ref
          .read(messengerProvider)
          .showError('Failed to save all analytics Excel file.');
    }
  }

  Future<void> _addCustomerAnalyticsSheet(Excel excel) async {
    final Sheet customerSheet = excel['Customer Analytics'];
    customerSheet.appendRow([
      TextCellValue('Customer ID'),
      TextCellValue('Name'),
      TextCellValue('Phone Number'),
      TextCellValue('Credit Outstanding'),
      TextCellValue('Last Purchase Date'),
      TextCellValue('Avg Monthly Spend'),
      TextCellValue('Loyalty Status'),
    ]);

    final userId = _authService.currentUserId;
    if (userId == null) {
      if (kDebugMode) {
        print('User not logged in.');
      }
      return;
    }

    final customers =
        await _favouriteCustomerService.streamFavouriteCustomers().first;

    for (var customer in customers) {
      customerSheet.appendRow([
        TextCellValue(customer.id),
        TextCellValue(customer.name),
        TextCellValue(customer.phoneNumber ?? 'N/A'),
        DoubleCellValue(customer.creditOutstanding ?? 0.0),
        TextCellValue(customer.lastPurchaseDate != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(customer.lastPurchaseDate!)
            : 'N/A'),
        DoubleCellValue(customer.avgMonthlySpend ?? 0.0),
        TextCellValue(customer.loyaltyStatus ?? 'N/A'),
      ]);
    }
  }

  Future<void> _addDailySalesTransactionsSheet(Excel excel) async {
    final Sheet transactionSheet = excel['Daily Sales Transactions'];
    transactionSheet.appendRow([
      TextCellValue('Transaction ID'),
      TextCellValue('Customer ID'),
      TextCellValue('Product Name'),
      TextCellValue('Quantity'),
      TextCellValue('Price'),
      TextCellValue('Timestamp'),
    ]);

    final userId = _authService.currentUserId;
    if (userId == null) {
      if (kDebugMode) {
        print('User not logged in.');
      }
      return;
    }

    final transactions = await _transactionService.streamTransactions().first;

    for (var transaction in transactions) {
      ProductItem? item;
      try {
        item = await _ref
            .read(inventoryServiceProvider)
            .streamProductItem(transaction.productId)
            .first;
      } catch (e) {
        if (kDebugMode) {
          print(
              'Error fetching inventory item for product ID ${transaction.productId}: $e');
        }
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
          return TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(value));
        }
        if (value is int) return IntCellValue(value);
        if (value is double) return DoubleCellValue(value);
        return TextCellValue(value.toString());
      }).toList();

      transactionSheet.appendRow(rowData);
    }
  }

  Future<void> _addAdminDashboardAnalyticsSheet(Excel excel) async {
    final Sheet adminSheet = excel['Admin Dashboard Analytics'];
    adminSheet.appendRow([
      TextCellValue('Metric'),
      TextCellValue('Value'),
    ]);

    final userId = _authService.currentUserId;
    if (userId == null) {
      if (kDebugMode) {
        print('User not logged in.');
      }
      return;
    }

    // Example: Total Sales (replace with actual calculation)
    final totalSales = await _transactionService
        .streamTransactions()
        .first
        .then((transactions) => transactions.fold(
            0.0,
            (sum, transaction) =>
                sum + (transaction.price * transaction.quantity)));

    adminSheet.appendRow([
      TextCellValue('Total Sales'),
      DoubleCellValue(totalSales),
    ]);

    // Example: Number of Transactions
    final numberOfTransactions = await _transactionService
        .streamTransactions()
        .first
        .then((transactions) => transactions.length);
    adminSheet.appendRow([
      TextCellValue('Number of Transactions'),
      IntCellValue(numberOfTransactions),
    ]);

    // Example: Average Transaction Value
    final averageTransactionValue =
        numberOfTransactions > 0 ? totalSales / numberOfTransactions : 0.0;
    adminSheet.appendRow([
      TextCellValue('Average Transaction Value'),
      DoubleCellValue(averageTransactionValue),
    ]);
  }
}
