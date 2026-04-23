import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/generic_list_tile.dart';
import '../../l10n/dynamic_localizations.dart';

class FaqsScreen extends ConsumerStatefulWidget {
  const FaqsScreen({super.key});

  @override
  ConsumerState<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends ConsumerState<FaqsScreen> {
  // Tracking expanded FAQ tile
  final Set<int> _expandedFaqs = <int>{};

  // FAQ data with questions and answers - computed in build to access context
  List<Map<String, String>> _getFaqs(BuildContext context) => [
        {
          'question': context.tr('How do I add items to my inventory?'),
          'answer': context.tr(
              'To add items to your inventory, go to the Inventory tab and tap the "+" button. Fill in the item details including name, price, cost, quantity, and reorder threshold. This helps you track your stock levels effectively.')
        },
        {
          'question': context
              .tr('What is the difference between Products and Services?'),
          'answer': context.tr(
              'Products are physical items you sell that have inventory quantities (like cosmetics, accessories). Services are non-physical offerings (like haircuts, facials) that don\'t require stock management. The app automatically determines this based on your business domain.')
        },
        {
          'question': context.tr('How do I process customer orders?'),
          'answer': context.tr(
              'Use the Customer Order tab to add items to the cart. You can adjust quantities, view the total, and process payment. The app supports various payment methods including cash, card, and QR code payments.')
        },
        {
          'question': context.tr('How can I track my business performance?'),
          'answer': context.tr(
              'The Dashboard provides comprehensive insights including daily, weekly, and monthly sales data. You can view charts showing your revenue trends, track your best-performing periods, and monitor business growth over time.')
        },
        {
          'question': context.tr('What happens when inventory runs low?'),
          'answer': context.tr(
              'When items reach their reorder threshold, you\'ll be notified to restock. You can set custom reorder thresholds for each item. The app helps you maintain optimal stock levels to avoid running out of popular items.')
        },
        {
          'question': context.tr('Can I export my business data?'),
          'answer': context.tr(
              'Yes! From your Profile, you can export transaction data and onboarding information to Excel files. This is useful for accounting, tax purposes, or sharing data with your accountant.')
        },
        {
          'question': context.tr('How do I manage my favorite customers?'),
          'answer': context.tr(
              'In the Profile section, you can access "Favourite Customers" to add and manage your VIP clients. Favorite customers will be highlighted in your schedule with a star icon for easy recognition.')
        },
        {
          'question': context.tr('What payment methods are supported?'),
          'answer': context.tr(
              'The app supports multiple payment methods including cash, card payments, and QR code-based digital payments. You can select the payment method during checkout to track different payment types.')
        },
        {
          'question': context.tr('How do I update my business profile?'),
          'answer': context.tr(
              'Go to the Profile tab to update your business information, change language preferences, manage notification settings, and configure other app preferences to suit your business needs.')
        },
      ];

  void _toggleExpansion(int index) {
    setState(() {
      if (_expandedFaqs.contains(index)) {
        _expandedFaqs.remove(index);
      } else {
        _expandedFaqs.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('Frequently Asked Questions'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                    'Find answers to common questions about using Nari Udyam'),
                style: TextStyle(
                  fontSize: 16,
                  color:
                      theme.colorScheme.onSurface.withAlpha(179), // 0.7 opacity
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _getFaqs(context).length,
                  itemBuilder: (context, index) {
                    final faq = _getFaqs(context)[index];
                    final isExpanded = _expandedFaqs.contains(index);

                    return Column(
                      children: [
                        GenericListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withAlpha(51), // 0.2 opacity
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.help_outline,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          titleWidget: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                faq['question']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 12),
                                Text(
                                  faq['answer']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface
                                        .withAlpha(204), // 0.8 opacity
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 24,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          onTap: () => _toggleExpansion(index),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
