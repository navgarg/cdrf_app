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
    switch (value) {
      case 'Beauty Parlor':
        return BusinessDomain.beautyParlor;
      case 'Tailor Shop':
        return BusinessDomain.tailorShop;
      case 'Tiffin Services':
        return BusinessDomain.tiffinServices;
      case 'Grocery Seller':
        return BusinessDomain.grocerySeller;
      case 'Convenience Store':
        return BusinessDomain.convenienceStore;
      default:
        return BusinessDomain.other;
    }
  }
}