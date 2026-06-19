import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'messenger.dart';

final onboardingExcelServiceProvider =
    Provider((ref) => OnboardingExcelService(ref));

class OnboardingExcelService {
  final Ref _ref;

  OnboardingExcelService(this._ref);

  Future<void> exportOnboardingDataToExcel(
      List<Map<String, dynamic>> data) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Onboarding Data'];

    if (data.isNotEmpty) {
      // Add headers
      sheet
          .appendRow(data.first.keys.map((key) => TextCellValue(key)).toList());

      // Add data rows
      for (var row in data) {
        sheet.appendRow(row.values
            .map((value) => TextCellValue(value.toString()))
            .toList());
      }
    }

    final List<int>? fileBytes = excel.encode();
    if (fileBytes != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/OnboardingData_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      _ref
          .read(messengerProvider)
          .showSuccess('Onboarding data Excel file saved to: $path');
      if (kDebugMode) {
        print('Onboarding data Excel file saved to: $path');
      }
    } else {
      _ref
          .read(messengerProvider)
          .showError('Failed to save Onboarding data Excel file.');
    }
  }
}
