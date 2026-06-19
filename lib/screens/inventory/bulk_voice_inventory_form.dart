import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:nariudyam/components/success_bottom_sheet.dart';
import 'package:nariudyam/components/voice_text_form_field.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';
import 'package:nariudyam/models/product_item.dart';
import 'package:nariudyam/providers/inventory_providers.dart';
import 'package:nariudyam/providers/locale_provider.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:nariudyam/services/voice/voice_input_service.dart';
import 'package:nariudyam/services/voice/voice_output_service.dart';

class BulkVoiceInventoryForm extends ConsumerStatefulWidget {
  final List<ProductItem> currentItems;

  const BulkVoiceInventoryForm({
    super.key,
    required this.currentItems,
  });

  @override
  ConsumerState<BulkVoiceInventoryForm> createState() =>
      _BulkVoiceInventoryFormState();
}

class _BulkVoiceInventoryFormState
    extends ConsumerState<BulkVoiceInventoryForm> {
  final _transcriptController = TextEditingController();
  final List<_InventoryEntry> _entries = [];
  bool _isListening = false;
  bool _isSaving = false;

  @override
  void dispose() {
    VoiceInputService.instance.stopListening();
    _transcriptController.dispose();
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _listen() async {
    final languageCode = ref.read(localeProvider).languageCode;
    final microphoneError = context.tr('Microphone permission is required.');
    if (_isListening && VoiceInputService.instance.isListening) {
      await VoiceInputService.instance.stopListening();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final started = await VoiceInputService.instance.startListening(
      languageCode: languageCode,
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() {
          _transcriptController.text = text.trim();
          _transcriptController.selection = TextSelection.fromPosition(
            TextPosition(offset: _transcriptController.text.length),
          );
          _replaceEntries(_parseTranscript(text));
          if (isFinal) _isListening = false;
        });
      },
    );

    if (!started) {
      ref.read(messengerProvider).showError(microphoneError);
      return;
    }
    if (mounted) setState(() => _isListening = true);
  }

  void _replaceEntries(List<_InventoryEntry> entries) {
    for (final entry in _entries) {
      entry.dispose();
    }
    _entries
      ..clear()
      ..addAll(entries);
  }

  List<_InventoryEntry> _parseTranscript(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return const [];
    final segments = text
        .split(RegExp(r'(?:,|\n|;|\band\b)+', caseSensitive: false))
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty);

    return segments.map(_parseSegment).whereType<_InventoryEntry>().toList();
  }

  _InventoryEntry? _parseSegment(String segment) {
    final compact = segment.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) return null;

    final firstPattern = RegExp(r'^(\d+|[a-z]+)\s+(.+)$', caseSensitive: false)
        .firstMatch(compact);
    if (firstPattern != null) {
      final quantity = _parseNumberToken(firstPattern.group(1)!);
      final name = firstPattern.group(2)!.trim();
      if (quantity != null && name.isNotEmpty) {
        return _createEntry(name, quantity);
      }
    }

    final lastPattern = RegExp(r'^(.+?)\s+(\d+|[a-z]+)$', caseSensitive: false)
        .firstMatch(compact);
    if (lastPattern != null) {
      final name = lastPattern.group(1)!.trim();
      final quantity = _parseNumberToken(lastPattern.group(2)!);
      if (quantity != null && name.isNotEmpty) {
        return _createEntry(name, quantity);
      }
    }

    return null;
  }

  _InventoryEntry _createEntry(String spokenName, int quantity) {
    final matchedItem = _findBestItemMatch(spokenName);
    return _InventoryEntry(
      spokenName: spokenName,
      quantity: quantity,
      selectedItemId: matchedItem?.id,
      unit: matchedItem?.unit ?? 'pcs',
    );
  }

  ProductItem? _findBestItemMatch(String spokenName) {
    final normalizedSpoken = _normalize(spokenName);
    if (normalizedSpoken.isEmpty) return null;
    ProductItem? bestItem;
    var bestScore = 0;

    for (final item in widget.currentItems) {
      final normalizedItem = _normalize(item.name);
      if (normalizedItem.isEmpty) continue;
      var score = 0;
      if (normalizedItem == normalizedSpoken) {
        score = 100;
      } else if (normalizedItem.contains(normalizedSpoken) ||
          normalizedSpoken.contains(normalizedItem)) {
        score = 70;
      } else {
        final overlap = normalizedSpoken
            .split(' ')
            .toSet()
            .intersection(normalizedItem.split(' ').toSet())
            .length;
        score = overlap * 20;
      }
      if (score > bestScore) {
        bestScore = score;
        bestItem = item;
      }
    }
    return bestScore >= 40 ? bestItem : null;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int? _parseNumberToken(String token) {
    final direct = int.tryParse(token.trim());
    if (direct != null) return direct;
    const smallNumbers = {
      'one': 1,
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
      'six': 6,
      'seven': 7,
      'eight': 8,
      'nine': 9,
      'ten': 10,
      'eleven': 11,
      'twelve': 12,
      'thirteen': 13,
      'fourteen': 14,
      'fifteen': 15,
      'sixteen': 16,
      'seventeen': 17,
      'eighteen': 18,
      'nineteen': 19,
      'twenty': 20,
      'thirty': 30,
      'forty': 40,
      'fifty': 50,
      'sixty': 60,
      'seventy': 70,
      'eighty': 80,
      'ninety': 90,
    };
    return smallNumbers[token.trim().toLowerCase()];
  }

  Future<void> _save() async {
    if (_entries.isEmpty) {
      ref.read(messengerProvider).showError(
            context.tr('Speak or type at least one inventory item.'),
          );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final inventoryService = ref.read(inventoryServiceProvider);
      for (final entry in _entries) {
        if (entry.quantity <= 0) continue;
        final selectedItem = widget.currentItems
            .where((item) => item.id == entry.selectedItemId)
            .firstOrNull;
        if (selectedItem != null) {
          await inventoryService.updateProductItem(
            selectedItem.id,
            stockQuantity: selectedItem.stockQuantity + entry.quantity,
          );
        } else {
          await inventoryService.addProductItem(
            name: entry.spokenName,
            description: '',
            price: double.tryParse(entry.priceController.text.trim()) ?? 0,
            cost: 0,
            stockQuantity: entry.quantity,
            reorderThreshold:
                int.tryParse(entry.reorderController.text.trim()) ?? 0,
            unit: entry.unitController.text.trim().isEmpty
                ? 'pcs'
                : entry.unitController.text.trim(),
          );
        }
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      await VoiceOutputService.instance.speak(
        text: 'Inventory updated successfully',
        languageCode: ref.read(localeProvider).languageCode,
      );
      if (!mounted) return;
      await showSuccessBottomSheet(
        context: context,
        title: context.tr('Inventory saved'),
        message: context.tr('Your stock changes have been recorded.'),
        actionLabel: context.tr('Done'),
        onDone: () => Navigator.of(context).pop(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ref.read(messengerProvider).showError(
            '${context.tr('Failed to update inventory')}: $e',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr('Add Stock by Voice'),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'Speak stock in one go, for example: clips 20, soap 5, rice 10.',
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            VoiceTextFormField(
              controller: _transcriptController,
              decoration: InputDecoration(
                labelText: context.tr('Inventory transcript'),
                hintText: context.tr('Example: clips 20, soap 5'),
              ),
              maxLines: 4,
              onMicTap: _listen,
              isListening: _isListening,
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () {
                setState(() => _replaceEntries(
                      _parseTranscript(_transcriptController.text),
                    ));
              },
              icon: const Icon(Icons.auto_fix_high),
              label: Text(context.tr('Review Stock')),
            ),
            const SizedBox(height: 18),
            if (_entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  context.tr(
                    'Your reviewed inventory items will appear here before saving.',
                  ),
                ),
              )
            else
              ..._entries.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _InventoryReviewCard(
                  entry: item,
                  currentItems: widget.currentItems,
                  onRemove: () {
                    setState(() {
                      _entries.removeAt(index).dispose();
                    });
                  },
                  onChanged: () => setState(() {}),
                );
              }),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt),
              label: Text(context.tr('Save Inventory')),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryReviewCard extends StatelessWidget {
  final _InventoryEntry entry;
  final List<ProductItem> currentItems;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _InventoryReviewCard({
    required this.entry,
    required this.currentItems,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchedItem = currentItems
        .where((item) => item.id == entry.selectedItemId)
        .firstOrNull;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                matchedItem == null
                    ? Icons.add_box_outlined
                    : Icons.inventory_2_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.spokenName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.tr('Remove'),
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: entry.selectedItemId,
            decoration: InputDecoration(labelText: context.tr('Match item')),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.tr('Create new item')),
              ),
              ...currentItems.map(
                (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text(context.tr(item.name)),
                ),
              ),
            ],
            onChanged: (value) {
              entry.selectedItemId = value;
              onChanged();
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: entry.quantity.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: context.tr('Quantity')),
            onChanged: (value) {
              entry.quantity = int.tryParse(value) ?? 0;
            },
          ),
          if (matchedItem == null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: entry.priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: context.tr('Price')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: entry.unitController,
              decoration: InputDecoration(labelText: context.tr('Unit')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: entry.reorderController,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(labelText: context.tr('Reorder Threshold')),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              '${context.tr('Current stock')}: ${matchedItem.stockQuantity} ${context.tr(matchedItem.unit)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _InventoryEntry {
  final String spokenName;
  int quantity;
  String? selectedItemId;
  final TextEditingController priceController;
  final TextEditingController unitController;
  final TextEditingController reorderController;

  _InventoryEntry({
    required this.spokenName,
    required this.quantity,
    required this.selectedItemId,
    required String unit,
  })  : priceController = TextEditingController(text: '0'),
        unitController = TextEditingController(text: unit),
        reorderController = TextEditingController(text: '0');

  void dispose() {
    priceController.dispose();
    unitController.dispose();
    reorderController.dispose();
  }
}
