import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/components/voice_text_form_field.dart';
import 'package:nariudyam/services/api/services_service.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';
import 'package:nariudyam/providers/locale_provider.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:nariudyam/services/voice/voice_input_service.dart';

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
  TextEditingController? _activeListeningController;
  bool _isLoading = false;

  @override
  void dispose() {
    VoiceInputService.instance.stopListening();
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

  String _normalizedVoiceText(String text, {bool numeric = false}) {
    final trimmed = text.trim();
    if (!numeric) return trimmed;

    final match = RegExp(r'-?\d+(?:[.,]\d+)?').firstMatch(trimmed);
    if (match == null) return trimmed;
    return match.group(0)!.replaceAll(',', '.');
  }

  Future<void> _listenIntoField(
    TextEditingController controller, {
    bool numeric = false,
  }) async {
    final languageCode = ref.read(localeProvider).languageCode;
    final messenger = ref.read(messengerProvider);

    if (_activeListeningController == controller &&
        VoiceInputService.instance.isListening) {
      await VoiceInputService.instance.stopListening();
      if (mounted) {
        setState(() => _activeListeningController = null);
      }
      return;
    }

    final started = await VoiceInputService.instance.startListening(
      languageCode: languageCode,
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() {
          controller.text = _normalizedVoiceText(text, numeric: numeric);
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
          if (isFinal) {
            _activeListeningController = null;
          }
        });
      },
    );

    if (!started) {
      messenger.showError(context.tr('Microphone permission is required.'));
      return;
    }

    if (mounted) {
      setState(() => _activeListeningController = controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.loc;
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
                  Text(appLocalizations.tr('Add a New Service'),
                      style: Theme.of(context).textTheme.headlineSmall),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              VoiceTextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: appLocalizations.tr('Enter Service Name')),
                onMicTap: () => _listenIntoField(_nameController),
                isListening: _activeListeningController == _nameController,
                validator: (v) => v == null || v.trim().isEmpty
                    ? appLocalizations.tr('Please Enter Valid Service Name')
                    : null,
              ),
              const SizedBox(height: 16),
              VoiceTextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText:
                        appLocalizations.tr('Enter Service Description')),
                maxLines: 2,
                onMicTap: () => _listenIntoField(_descriptionController),
                isListening:
                    _activeListeningController == _descriptionController,
              ),
              const SizedBox(height: 16),
              VoiceTextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                    labelText: appLocalizations.tr('Enter Price')),
                keyboardType: TextInputType.number,
                onMicTap: () =>
                    _listenIntoField(_priceController, numeric: true),
                isListening: _activeListeningController == _priceController,
                validator: (v) => v == null || v.isEmpty
                    ? appLocalizations.tr('Please Enter Price')
                    : double.tryParse(v) == null
                        ? appLocalizations.tr('Invalid Price, Please Try Again')
                        : null,
              ),
              const SizedBox(height: 16),
              VoiceTextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                    labelText:
                        appLocalizations.tr('Enter Duration in Minutes')),
                keyboardType: TextInputType.number,
                onMicTap: () =>
                    _listenIntoField(_durationController, numeric: true),
                isListening: _activeListeningController == _durationController,
                validator: (v) => v == null || v.isEmpty
                    ? appLocalizations.tr('Please Enter Duration in Minutes')
                    : int.tryParse(v) == null
                        ? appLocalizations
                            .tr('Invalid Duration, Please Try Again')
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
                    : Text(appLocalizations.tr('Save Service')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
