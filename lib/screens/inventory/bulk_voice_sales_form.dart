import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';
import 'package:nariudyam/components/voice_text_form_field.dart';
import 'package:nariudyam/models/product_item.dart';
import 'package:nariudyam/providers/locale_provider.dart';
import 'package:nariudyam/services/api/inventory_service.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:nariudyam/services/voice/voice_input_service.dart';

import '../../l10n/dynamic_localizations.dart';

class BulkVoiceSalesForm extends ConsumerStatefulWidget {
  final List<ProductItem> items;

  const BulkVoiceSalesForm({
    super.key,
    required this.items,
  });

  @override
  ConsumerState<BulkVoiceSalesForm> createState() => _BulkVoiceSalesFormState();
}

class _BulkVoiceSalesFormState extends ConsumerState<BulkVoiceSalesForm> {
  final _transcriptController = TextEditingController();
  final List<_ParsedSaleEntry> _entries = [];
  bool _isListening = false;
  bool _isSaving = false;

  @override
  void dispose() {
    VoiceInputService.instance.stopListening();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _listenForBulkSales() async {
    final messenger = ref.read(messengerProvider);
    final languageCode = ref.read(localeProvider).languageCode;
    final microphoneError = context.tr('Microphone permission is required.');

    if (_isListening && VoiceInputService.instance.isListening) {
      await VoiceInputService.instance.stopListening();
      if (mounted) {
        setState(() => _isListening = false);
      }
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
          _entries
            ..clear()
            ..addAll(_parseTranscript(text));
          if (isFinal) {
            _isListening = false;
          }
        });
      },
    );

    if (!started) {
      messenger.showError(microphoneError);
      return;
    }

    if (mounted) {
      setState(() => _isListening = true);
    }
  }

  List<_ParsedSaleEntry> _parseTranscript(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return const [];

    final segments = text
        .split(RegExp(r'(?:,|\n|;|\band\b)+', caseSensitive: false))
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty);

    return segments
        .map(_parseSegment)
        .whereType<_ParsedSaleEntry>()
        .toList(growable: false);
  }

  _ParsedSaleEntry? _parseSegment(String segment) {
    final compact = segment.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) return null;

    final firstPattern = RegExp(r'^(\d+|[a-z]+)\s+(.+)$', caseSensitive: false)
        .firstMatch(compact);
    if (firstPattern != null) {
      final quantity = _parseNumberToken(firstPattern.group(1)!);
      final spokenName = firstPattern.group(2)!.trim();
      if (quantity != null && spokenName.isNotEmpty) {
        return _createEntry(spokenName, quantity);
      }
    }

    final lastPattern = RegExp(r'^(.+?)\s+(\d+|[a-z]+)$', caseSensitive: false)
        .firstMatch(compact);
    if (lastPattern != null) {
      final spokenName = lastPattern.group(1)!.trim();
      final quantity = _parseNumberToken(lastPattern.group(2)!);
      if (quantity != null && spokenName.isNotEmpty) {
        return _createEntry(spokenName, quantity);
      }
    }

    final quantityMatch = RegExp(r'(\d+)').firstMatch(compact);
    if (quantityMatch != null) {
      final quantity = int.tryParse(quantityMatch.group(1)!);
      final spokenName = compact
          .replaceFirst(quantityMatch.group(0)!, '')
          .replaceAll(
              RegExp(r'\b(quantity|qty|pieces|piece|units|unit)\b',
                  caseSensitive: false),
              '')
          .trim();
      if (quantity != null && spokenName.isNotEmpty) {
        return _createEntry(spokenName, quantity);
      }
    }

    return null;
  }

  _ParsedSaleEntry _createEntry(String spokenName, int quantity) {
    final matchedItem = _findBestItemMatch(spokenName);
    return _ParsedSaleEntry(
      spokenName: spokenName,
      quantity: quantity,
      selectedItemId: matchedItem?.id,
    );
  }

  ProductItem? _findBestItemMatch(String spokenName) {
    final normalizedSpoken = _normalizeItemName(spokenName);
    if (normalizedSpoken.isEmpty) return null;

    ProductItem? bestItem;
    var bestScore = 0;

    for (final item in widget.items) {
      final normalizedItem = _normalizeItemName(item.name);
      if (normalizedItem.isEmpty) continue;

      var score = 0;
      if (normalizedItem == normalizedSpoken) {
        score = 100;
      } else if (normalizedItem.startsWith(normalizedSpoken) ||
          normalizedSpoken.startsWith(normalizedItem)) {
        score = 80;
      } else if (normalizedItem.contains(normalizedSpoken) ||
          normalizedSpoken.contains(normalizedItem)) {
        score = 65;
      } else {
        final spokenTokens = normalizedSpoken.split(' ').toSet();
        final itemTokens = normalizedItem.split(' ').toSet();
        final overlap = spokenTokens.intersection(itemTokens).length;
        if (overlap > 0) {
          score = overlap * 20;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestItem = item;
      }
    }

    return bestScore >= 40 ? bestItem : null;
  }

  String _normalizeItemName(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int? _parseNumberToken(String token) {
    final normalized = token.trim().toLowerCase();
    final direct = int.tryParse(normalized);
    if (direct != null) return direct;

    final cleaned = normalized
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\band\b'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return null;

    const smallNumbers = {
      'zero': 0,
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
    };
    const tensNumbers = {
      'twenty': 20,
      'thirty': 30,
      'forty': 40,
      'fifty': 50,
      'sixty': 60,
      'seventy': 70,
      'eighty': 80,
      'ninety': 90,
    };
    const scaleNumbers = {
      'hundred': 100,
      'thousand': 1000,
      'lakh': 100000,
      'lac': 100000,
      'million': 1000000,
      'crore': 10000000,
    };

    var total = 0;
    var current = 0;

    for (final part in cleaned.split(' ')) {
      if (smallNumbers.containsKey(part)) {
        current += smallNumbers[part]!;
        continue;
      }
      if (tensNumbers.containsKey(part)) {
        current += tensNumbers[part]!;
        continue;
      }
      if (part == 'hundred') {
        current = (current == 0 ? 1 : current) * 100;
        continue;
      }
      final scale = scaleNumbers[part];
      if (scale != null) {
        final base = current == 0 ? 1 : current;
        total += base * scale;
        current = 0;
        continue;
      }
      return null;
    }

    final result = total + current;
    return result > 0 ? result : null;
  }

  Future<void> _saveSales() async {
    if (_entries.isEmpty) {
      ref.read(messengerProvider).showError(
            context.tr('Add or speak at least one sale entry.'),
          );
      return;
    }

    for (final entry in _entries) {
      if (entry.selectedItemId == null) {
        ref.read(messengerProvider).showError(
              context
                  .tr('Please match every spoken item to an inventory item.'),
            );
        return;
      }
      if (entry.quantity <= 0) {
        ref.read(messengerProvider).showError(
              context.tr('Each sale quantity must be greater than zero.'),
            );
        return;
      }
    }

    final paymentMethod = await showModalBottomSheet<PaymentMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => PaymentSelectionBottomSheet(
        onSelected: (method) => Navigator.of(sheetContext).pop(method),
      ),
    );

    if (paymentMethod == null) return;

    final totalsByItem = <String, int>{};
    for (final entry in _entries) {
      final itemId = entry.selectedItemId!;
      totalsByItem[itemId] = (totalsByItem[itemId] ?? 0) + entry.quantity;
    }

    final requests = <InventorySaleRequest>[];
    for (final item in widget.items) {
      final totalQuantity = totalsByItem[item.id];
      if (totalQuantity == null) continue;
      requests.add(
        InventorySaleRequest(item: item, quantity: totalQuantity),
      );
    }

    setState(() => _isSaving = true);
    final success = await ref.read(inventoryServiceProvider).recordBulkSales(
          sales: requests,
          paymentMethod: paymentMethod,
        );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr('Log Today\'s Sales'),
                    style: Theme.of(context).textTheme.headlineSmall,
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
                'Speak multiple sales in one go, for example: Rice 2, Oil 1, Soap 3. Price is picked from inventory automatically.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            VoiceTextFormField(
              controller: _transcriptController,
              decoration: InputDecoration(
                labelText: context.tr('Daily sales transcript'),
                hintText: context.tr('Example: Milk 2, Bread 1, Shampoo 3'),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              onMicTap: _listenForBulkSales,
              isListening: _isListening,
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () {
                setState(() {
                  _entries
                    ..clear()
                    ..addAll(_parseTranscript(_transcriptController.text));
                });
              },
              icon: const Icon(Icons.auto_fix_high),
              label: Text(context.tr('Parse Sales')),
            ),
            const SizedBox(height: 20),
            if (_entries.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  context.tr(
                    'Parsed sales will appear here. You can review and adjust before saving.',
                  ),
                ),
              )
            else
              ..._entries.asMap().entries.map((entry) {
                final index = entry.key;
                final sale = entry.value;
                final matchedItem = widget.items
                    .where((item) => item.id == sale.selectedItemId)
                    .firstOrNull;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: matchedItem == null
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${context.tr('Spoken')}: ${sale.spokenName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: sale.selectedItemId,
                        decoration: InputDecoration(
                          labelText: context.tr('Inventory Item'),
                        ),
                        items: widget.items
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            sale.selectedItemId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: sale.quantity.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: context.tr('Quantity'),
                        ),
                        onChanged: (value) {
                          sale.quantity = int.tryParse(value) ?? 0;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              matchedItem == null
                                  ? context.tr('No matching item found yet')
                                  : '${context.tr('Stock available')}: ${matchedItem.stockQuantity}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          IconButton(
                            tooltip: context.tr('Remove'),
                            onPressed: () {
                              setState(() {
                                _entries.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSales,
              icon: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt),
              label: Text(context.tr('Save Today\'s Sales')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParsedSaleEntry {
  final String spokenName;
  int quantity;
  String? selectedItemId;

  _ParsedSaleEntry({
    required this.spokenName,
    required this.quantity,
    required this.selectedItemId,
  });
}
