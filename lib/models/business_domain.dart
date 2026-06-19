enum BusinessDomain {
  beautyParlor,
  tailorShop,
  tiffinServices,
  grocerySeller,
  convenienceStore,
  other,
}

extension BusinessDomainExtension on BusinessDomain {
  String get stringValue {
    switch (this) {
      case BusinessDomain.beautyParlor:
        return 'Beauty Parlor';
      case BusinessDomain.tailorShop:
        return 'Tailor Shop';
      case BusinessDomain.tiffinServices:
        return 'Tiffin Services';
      case BusinessDomain.grocerySeller:
        return 'Grocery Seller';
      case BusinessDomain.convenienceStore:
        return 'Convenience Store';
      case BusinessDomain.other:
        return 'Other Business';
    }
  }

  static BusinessDomain fromString(String? value) {
    switch (BusinessDomainUtils.normalized(value)) {
      case 'beautyparlor':
      case 'beautyparlour':
      case 'salon':
        return BusinessDomain.beautyParlor;
      case 'tailorshop':
      case 'tailor':
        return BusinessDomain.tailorShop;
      case 'tiffinservices':
      case 'tiffin':
        return BusinessDomain.tiffinServices;
      case 'groceryseller':
      case 'grocery':
        return BusinessDomain.grocerySeller;
      case 'conveniencestore':
      case 'convenience':
        return BusinessDomain.convenienceStore;
      default:
        return BusinessDomain.other;
    }
  }
}

class BusinessDomainUtils {
  const BusinessDomainUtils._();

  static String normalized(String? value) {
    return (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static bool isServiceDomain(String? value) {
    final domain = normalized(value);
    return domain == 'beautyparlor' ||
        domain == 'beautyparlour' ||
        domain == 'salon';
  }
}
