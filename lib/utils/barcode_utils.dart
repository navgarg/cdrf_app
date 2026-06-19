import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BarcodeUtils {
  /// Shows a barcode scanner and returns the scanned result
  static Future<String?> scanBarcode(BuildContext context) async {
    try {
      final res = await SimpleBarcodeScanner.scanBarcode(context);
      if (res == '-1') return null; // User cancelled scan
      return res;
    } catch (e) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning barcode: $e')),
      );
      return null;
    }
  }

  /// Fetches product details from a barcode using UPC Item DB
  static Future<Map<String, dynamic>?> fetchProductDetails(
    String barcode,
    BuildContext context,
  ) async {
    final url =
        Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode');

    try {
      final response = await http.get(url);
      if (!context.mounted) return null;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];
          return {
            'name': item['title'] ?? '',
            'description': item['description'] ?? '',
            'price': (item['lowest_recorded_price'] ?? 0.0).toString(),
          };
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product details not found.')),
          );
          return null;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load product details: ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching product details: $e')),
      );
      return null;
    }
  }

  /// Find an item in a list by barcode
  // static InventoryItem? findItemByBarcode(
  //   String barcode,
  //   List<InventoryItem> items,
  //   BuildContext context,
  // ) {
  //   // In a real app, you would search for the item by barcode in your inventory
  //   // For now, we'll try to match the barcode with the item name as a simple demonstration
  //   try {
  //     return items.firstWhere((item) => item.name.contains(barcode));
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text('Item with barcode $barcode not found in inventory')),
  //     );
  //     return null;
  //   }
  // }
}
