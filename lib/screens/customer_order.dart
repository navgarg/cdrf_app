import 'package:flutter/material.dart';

class CustomerOrderScreen extends StatelessWidget {
  const CustomerOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'icon': Icons.circle, // Placeholder for Oranges
        'name': 'Oranges',
        'price': '₹ 70/kg',
      },
      {
        'icon': Icons.apple,
        'name': 'Apples',
        'price': '₹ 90/kg',
      },
      {
        'icon': Icons.spa,
        'name': 'Potatoes',
        'price': '₹ 40/kg',
      },
      {
        'icon': Icons.emoji_food_beverage,
        'name': 'Onions',
        'price': '₹ 45/kg',
      },
      {
        'icon': Icons.local_pizza,
        'name': 'Tomatoes',
        'price': '₹ 55/kg',
      },
      {
        'icon': Icons.grain,
        'name': 'Grapes',
        'price': '₹ 65/kg',
      },
    ];

    const searchBarColor = Color(0xFFFFE3C1);
    const itemBlockColor = Color(0xFFFFC897); // #ffc897
    const addButtonColor = Color(0xFFF77D3F); // #f77d3f

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search for an item...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.mic),
              filled: true,
              fillColor: searchBarColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
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
              return Container(
                decoration: BoxDecoration(
                  color: itemBlockColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(item['icon'] as IconData, size: 32),
                  title: Text(item['name'] as String),
                  subtitle: Text(item['price'] as String),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: addButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Add'),
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
