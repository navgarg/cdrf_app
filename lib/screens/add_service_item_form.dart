import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/services/api/services_service.dart';
import 'package:nariudyam/l10n/app_localizations.dart';

class AddServiceItemForm extends ConsumerStatefulWidget {
  const AddServiceItemForm({super.key});

  @override
  ConsumerState<AddServiceItemForm> createState() => _AddServiceItemFormState();
}

class _AddServiceItemFormState extends ConsumerState<AddServiceItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await ref.read(servicesServiceProvider).addServiceItem(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          price: double.tryParse(_priceController.text.trim()) ?? 0.0,
          duration: int.tryParse(_durationController.text.trim()) ?? 0,
        );

    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appLocalizations.newService,
                      style: Theme.of(context).textTheme.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: appLocalizations.serviceName),
                validator: (v) => v == null || v.trim().isEmpty
                    ? appLocalizations.pleaseEnterName
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: appLocalizations.description),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: appLocalizations.price),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? appLocalizations.enterPrice
                    : double.tryParse(v) == null
                        ? appLocalizations.invalidNumber
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration:
                    InputDecoration(labelText: appLocalizations.durationMinutes),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? appLocalizations.enterDuration
                    : int.tryParse(v) == null
                        ? appLocalizations.invalidNumber
                        : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(),
                      )
                    : Text(appLocalizations.saveService),
              )
            ],
          ),
        ),
      ),
    );
  }
}
