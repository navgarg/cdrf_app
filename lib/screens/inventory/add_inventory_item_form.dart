import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/providers/inventory_providers.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../l10n/dynamic_localizations.dart';

// firebase (previous implementation)
// import 'package:nariudyam/services/api/inventory_service.dart';

class AddInventoryItemForm extends ConsumerStatefulWidget {
  const AddInventoryItemForm({super.key});

  @override
  ConsumerState<AddInventoryItemForm> createState() =>
      _AddInventoryItemFormState();
}

class _AddInventoryItemFormState extends ConsumerState<AddInventoryItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _reorderThresholdController = TextEditingController();
  final _unitController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockQuantityController.dispose();
    _reorderThresholdController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetails(String barcode) async {
    final url =
        Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];
          setState(() {
            _nameController.text = item['title'] ?? '';
            _descriptionController.text = item['description'] ?? '';
            _priceController.text =
                (item['lowest_recorded_price'] ?? 0.0).toString();
          });
        } else {
          _showSnackBar(context.tr('Product details not found.'));
        }
      } else {
        _showSnackBar(context
            .tr('Failed to load product details: ${response.statusCode}'));
      }
    } catch (e) {
      _showSnackBar(context.tr('Error fetching product details: $e'));
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await ref.read(inventoryServiceProvider).addProductItem(
            name: _nameController.text,
            description: _descriptionController.text,
            price: double.tryParse(_priceController.text) ?? 0.0,
            cost: double.tryParse(_costController.text) ?? 0.0,
            stockQuantity: int.tryParse(_stockQuantityController.text) ?? 0,
            reorderThreshold:
                int.tryParse(_reorderThresholdController.text) ?? 0,
            unit: _unitController.text,
          );

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.tr('New Inventory Item'),
                      style: Theme.of(context).textTheme.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      var res = await SimpleBarcodeScanner.scanBarcode(context);
                      if (res is String) {
                        _nameController.text = res;
                        _fetchProductDetails(res);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.tr('Item Name'),
                ),
                validator: (value) =>
                    value!.isEmpty ? context.tr('Please enter a name') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    InputDecoration(labelText: context.tr('Description')),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: context.tr('Price')),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('Please enter a price');
                  }
                  if (double.tryParse(value) == null) {
                    return context.tr('Please enter a valid number');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: InputDecoration(labelText: context.tr('Cost')),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.tr('Please enter a cost');
                  }
                  if (double.tryParse(value) == null) {
                    return context.tr('Please enter a valid number');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockQuantityController,
                decoration:
                    InputDecoration(labelText: context.tr('Stock Quantity')),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty
                    ? context.tr('Please enter stock quantity')
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reorderThresholdController,
                decoration:
                    InputDecoration(labelText: context.tr('Reorder Threshold')),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(
                    labelText: context.tr('Unit (e.g., pcs, kg)')),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white))
                    : Text(context.tr('Save Item')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
