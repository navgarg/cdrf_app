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
}
