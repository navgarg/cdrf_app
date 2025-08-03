import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/services/api/inventory_service.dart';

class AddInventoryItemForm extends ConsumerStatefulWidget {
  const AddInventoryItemForm({super.key});

  @override
  ConsumerState<AddInventoryItemForm> createState() => _AddInventoryItemFormState();
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await ref.read(inventoryServiceProvider).addInventoryItem(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        cost: double.tryParse(_costController.text) ?? 0.0,
        stockQuantity: int.tryParse(_stockQuantityController.text) ?? 0,
        reorderThreshold: int.tryParse(_reorderThresholdController.text) ?? 0,
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
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Inventory Item', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter stock quantity' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reorderThresholdController,
                decoration: const InputDecoration(labelText: 'Reorder Threshold'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unit (e.g., pcs, kg)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Save Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}