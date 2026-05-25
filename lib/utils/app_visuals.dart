import 'package:flutter/material.dart';

class AppVisuals {
  const AppVisuals._();

  static const String appIcon = 'assets/icons/app/storefront_app_icon.png';

  static IconData routeIcon(String? path) {
    final route = path ?? '';
    if (route.startsWith('/inventory')) return Icons.inventory_2_outlined;
    if (route.startsWith('/schedule')) return Icons.event_available_outlined;
    if (route.startsWith('/customer_order')) {
      return Icons.shopping_basket_outlined;
    }
    if (route.startsWith('/profile')) return Icons.person_outline;
    if (route.startsWith('/resource_centre')) return Icons.school_outlined;
    if (route.startsWith('/advanced_analytics')) return Icons.insights_outlined;
    if (route.startsWith('/admin/users')) return Icons.group_outlined;
    if (route.startsWith('/admin/analytics')) return Icons.query_stats_outlined;
    if (route.startsWith('/admin')) return Icons.admin_panel_settings_outlined;
    return Icons.home_outlined;
  }

  static IconData optionIcon(String label) {
    final text = label.toLowerCase();
    if (text.contains('yes') ||
        text.contains('always') ||
        text.contains('regular') ||
        text.contains('accurate')) {
      return Icons.check_circle_outline;
    }
    if (text.contains('no') ||
        text.contains('never') ||
        text.contains('none') ||
        text.contains('rarely')) {
      return Icons.cancel_outlined;
    }
    if (text.contains('sometimes') ||
        text.contains('approx') ||
        text.contains('occasion')) {
      return Icons.help_outline;
    }
    if (text.contains('english')) return Icons.language;
    if (text.contains('hindi') || text.contains('telugu')) {
      return Icons.translate;
    }
    if (text.contains('18') || text.contains('23') || text.contains('30')) {
      return Icons.cake_outlined;
    }
    if (text.contains('61')) return Icons.elderly_outlined;
    if (text.contains('school') ||
        text.contains('primary') ||
        text.contains('secondary') ||
        text.contains('graduate')) {
      return Icons.school_outlined;
    }
    if (text.contains('home')) return Icons.home_work_outlined;
    if (text.contains('rented')) return Icons.storefront_outlined;
    if (text.contains('self')) return Icons.verified_user_outlined;
    if (text.contains('notebook') || text.contains('register')) {
      return Icons.menu_book_outlined;
    }
    if (text.contains('mobile') ||
        text.contains('whatsapp') ||
        text.contains('phone')) {
      return Icons.phone_android_outlined;
    }
    if (text.contains('memory')) return Icons.psychology_outlined;
    if (text.contains('bank') ||
        text.contains('loan') ||
        text.contains('shg')) {
      return Icons.account_balance_outlined;
    }
    return Icons.touch_app_outlined;
  }

  static IconData itemIcon(
    String name, {
    String? displayedName,
    String? unit,
    String? displayedUnit,
    bool isService = false,
  }) {
    final text = _searchText([
      name,
      if (displayedName != null) displayedName,
      if (unit != null) unit,
      if (displayedUnit != null) displayedUnit,
    ]);

    if (isService) {
      if (_containsAny(text, [
        'hair',
        'haircut',
        'cut',
        'salon',
        'trim',
        'styling',
        'straightening',
        'smoothening',
        'blow dry',
      ])) {
        return Icons.content_cut;
      }
      if (_containsAny(text, [
        'makeup',
        'facial',
        'beauty',
        'bridal',
        'clean up',
        'bleach',
        'tan',
        'glow',
      ])) {
        return Icons.face_retouching_natural_outlined;
      }
      if (_containsAny(text, ['nail', 'manicure', 'pedicure', 'polish'])) {
        return Icons.back_hand_outlined;
      }
      if (_containsAny(text, ['massage', 'spa', 'relax', 'therapy'])) {
        return Icons.spa_outlined;
      }
      if (_containsAny(text, [
        'wax',
        'thread',
        'eyebrow',
        'upper lip',
        'threading',
      ])) {
        return Icons.auto_fix_high_outlined;
      }
      return Icons.design_services_outlined;
    }

    if (_containsAny(text, [
      'rice',
      'flour',
      'wheat',
      'grain',
      'cereal',
      'millet',
      'ragi',
      'maida',
      'semolina',
      'poha',
    ])) {
      return Icons.rice_bowl_outlined;
    }
    if (_containsAny(text, [
      'pulse',
      'lentil',
      'bean',
      'peas',
      'chickpea',
      'gram',
      'sprout',
    ])) {
      return Icons.grain_outlined;
    }
    if (_containsAny(text, [
      'milk',
      'curd',
      'paneer',
      'cheese',
      'dairy',
      'butter',
      'yogurt',
    ])) {
      return Icons.local_drink_outlined;
    }
    if (_containsAny(text, ['oil', 'ghee', 'vanaspati'])) {
      return Icons.water_drop_outlined;
    }
    if (_containsAny(text, ['tea', 'coffee', 'drink', 'juice'])) {
      return Icons.coffee_outlined;
    }
    if (_containsAny(text, [
      'sugar',
      'salt',
      'spice',
      'masala',
      'chilli',
      'pepper',
      'turmeric',
      'coriander',
      'cumin',
      'powder',
    ])) {
      return Icons.set_meal_outlined;
    }
    if (_containsAny(text, [
      'soap',
      'shampoo',
      'cream',
      'lotion',
      'wash',
      'conditioner',
      'face wash',
      'detergent',
      'cleaner',
      'powder soap',
    ])) {
      return Icons.soap_outlined;
    }
    if (_containsAny(text, [
      'biscuit',
      'snack',
      'chips',
      'mixture',
      'fry',
      'cracker',
      'cookie',
      'chocolate',
      'sweet',
      'candy',
    ])) {
      return Icons.bakery_dining_outlined;
    }
    if (_containsAny(text, ['bread', 'cake', 'bun', 'puff', 'bakery'])) {
      return Icons.bakery_dining_outlined;
    }
    if (_containsAny(text, ['egg', 'eggs'])) return Icons.egg_outlined;
    if (_containsAny(text, [
      'fruit',
      'apple',
      'banana',
      'mango',
      'orange',
      'grapes',
      'lemon',
      'coconut',
    ])) {
      return Icons.eco_outlined;
    }
    if (_containsAny(text, [
      'vegetable',
      'tomato',
      'onion',
      'potato',
      'carrot',
      'cabbage',
      'greens',
      'leaf',
      'brinjal',
      'chilli',
    ])) {
      return Icons.local_florist_outlined;
    }
    if (_containsAny(text, [
      'cloth',
      'fabric',
      'saree',
      'kurti',
      'dress',
      'shirt',
      'blouse',
      'pant',
      'skirt',
      'uniform',
      'lining',
    ])) {
      return Icons.checkroom_outlined;
    }
    if (_containsAny(text, [
      'thread',
      'needle',
      'button',
      'zip',
      'zipper',
      'lace',
      'elastic',
      'hook',
      'scissor',
      'measuring tape',
    ])) {
      return Icons.handyman_outlined;
    }
    if (_containsAny(text, [
      'tiffin',
      'meal',
      'food',
      'breakfast',
      'lunch',
      'dinner',
      'plate',
      'parcel',
      'curry',
      'biryani',
      'idli',
      'dosa',
      'chapati',
      'roti',
      'snack box',
    ])) {
      return Icons.restaurant_outlined;
    }
    if (_containsAny(text, [
      'water',
      'bottle',
      'soft drink',
      'soda',
      'cool drink',
    ])) {
      return Icons.local_drink_outlined;
    }
    if (_containsAny(text, [
      'medicine',
      'tablet',
      'sanitary',
      'napkin',
      'mask',
      'bandage',
      'health',
    ])) {
      return Icons.medication_outlined;
    }
    if (_containsAny(text, [
      'notebook',
      'book',
      'pen',
      'pencil',
      'eraser',
      'stationery',
      'paper',
      'file',
    ])) {
      return Icons.edit_note_outlined;
    }
    if (_containsAny(text, [
      'battery',
      'charger',
      'bulb',
      'wire',
      'plug',
      'light',
      'electrical',
    ])) {
      return Icons.electrical_services_outlined;
    }
    if (_containsAny(text, [
      'toy',
      'gift',
      'decor',
      'decoration',
      'flower',
      'pooja',
      'festival',
    ])) {
      return Icons.celebration_outlined;
    }
    if (_containsAny(text, ['kg', 'kilogram', 'gram', 'packet', 'pack'])) {
      return Icons.scale_outlined;
    }

    return Icons.inventory_2;
  }

  static bool _containsAny(String text, List<String> needles) {
    return needles.any(text.contains);
  }

  static String _searchText(List<String> values) {
    return values.join(' ').toLowerCase();
  }
}
