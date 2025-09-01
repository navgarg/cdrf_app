class Item {
  final String icon;
  final String name;
  final String price;
  final double priceValue;

  const Item({
    required this.icon,
    required this.name,
    required this.price,
    required this.priceValue,
  });
}

class ItemData {
  static const List<Item> items = [
    Item(
      icon: '🍊',
      name: 'Oranges',
      price: '₹ 70/kg',
      priceValue: 70.0,
    ),
    Item(
      icon: '🍎',
      name: 'Apples',
      price: '₹ 90/kg',
      priceValue: 90.0,
    ),
    Item(
      icon: '🥔',
      name: 'Potatoes',
      price: '₹ 40/kg',
      priceValue: 40.0,
    ),
    Item(
      icon: '🧅',
      name: 'Onions',
      price: '₹ 45/kg',
      priceValue: 45.0,
    ),
    Item(
      icon: '🍅',
      name: 'Tomatoes',
      price: '₹ 55/kg',
      priceValue: 55.0,
    ),
    Item(
      icon: '🍇',
      name: 'Grapes',
      price: '₹ 65/kg',
      priceValue: 65.0,
    ),
  ];

  static Item? getItemByName(String name) {
    try {
      return items.firstWhere((item) => item.name == name);
    } catch (e) {
      return null;
    }
  }

  static double getItemPrice(String name) {
    final item = getItemByName(name);
    return item?.priceValue ?? 0.0;
  }
}
