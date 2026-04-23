class ServiceItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int duration; // in minutes

  ServiceItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
  });

  factory ServiceItem.fromMap(Map<String, dynamic> data, String id) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ServiceItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      price: parseDouble(data['price']),
      duration: parseInt(data['duration']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
    };
  }
}
