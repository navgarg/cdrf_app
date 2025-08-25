import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, int>>(
    (ref) => CartNotifier());

class CartNotifier extends StateNotifier<Map<String, int>> {
  CartNotifier() : super({});

  void addToCart(String itemName) {
    state = {
      ...state,
      itemName: (state[itemName] ?? 0) + 1,
    };
  }

  void removeFromCart(String itemName) {
    if (state[itemName] != null && state[itemName]! > 1) {
      state = {
        ...state,
        itemName: state[itemName]! - 1,
      };
    } else {
      final newState = {...state};
      newState.remove(itemName);
      state = newState;
    }
  }

  void clearCart() {
    state = {};
  }
}

class CustomerOrderScreen extends ConsumerWidget {
  const CustomerOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ItemData.items;

    const searchBarColor = Color(0xFFFFE3C1);
    const itemBlockColor = Color(0xFFFFC897); // #ffc897
    const addButtonColor = Color(0xFFF77D3F); // #f77d3f

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: searchBarColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for an item...',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                prefixIcon:
                    Icon(Icons.search, color: Colors.black.withOpacity(0.6)),
                suffixIcon:
                    Icon(Icons.mic, color: Colors.black.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final cart = ref.watch(cartProvider);
              final qty = cart[item.name] ?? 0;

              return Container(
                decoration: BoxDecoration(
                  color: itemBlockColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      // Emoji icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            item.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name and price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.price,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add button or quantity controls
                      if (qty == 0)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: addButtonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            elevation: 0,
                          ),
                          onPressed: () {
                            ref
                                .read(cartProvider.notifier)
                                .addToCart(item.name);
                          },
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: addButtonColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .removeFromCart(item.name);
                                },
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '$qty kg',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .addToCart(item.name);
                                },
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
