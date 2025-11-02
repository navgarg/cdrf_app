import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';

import '../general/messenger.dart';

final onboardingExcelServiceProvider =
    Provider((ref) => OnboardingExcelService(ref));

class OnboardingExcelService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OnboardingExcelService(this._ref);

  Future<void> exportOnboardingDataToExcel() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
          await _firestore.collection('users').get();
      final List<UserModel> users = usersSnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Onboarding Data'];

      final List<String> allKeys =
          users.isNotEmpty ? users.first.toMap().keys.toList() : [];

      final List<CellValue> headers =
          allKeys.map((key) => TextCellValue(key)).toList();
      sheetObject.appendRow(headers);

      for (var user in users) {
        sheetObject.appendRow([
          ...allKeys.map((key) {
            final value = user.toMap()[key];
            if (value is Timestamp) {
              return TextCellValue(
                  value.toDate().toIso8601String().split('T').first);
            } else if (value != null) {
              return TextCellValue(value.toString());
            } else {
              return TextCellValue('N/A');
            }
          }),
        ]);
      }

      final directory = await path_provider.getApplicationDocumentsDirectory();
      final path = '${directory.path}/Onboarding_Data.xlsx';
      final fileBytes = excel.save();

      if (fileBytes != null) {
        File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        _ref
            .read(messengerProvider)
            .showSuccess('Onboarding data Excel file saved to: $path');
        print('Onboarding data Excel file saved to: $path');
      } else {
        _ref
            .read(messengerProvider)
            .showError('Failed to save Onboarding data Excel file.');
      }
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Error exporting onboarding data: $e');
    }
  }
}
