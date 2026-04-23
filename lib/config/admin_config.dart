class AdminConfig {
  static const List<String> adminPhoneNumbers = [
    '+911234567890',
  ];

  static bool isAdmin(String phoneNumber) {
    return adminPhoneNumbers.contains(phoneNumber);
  }
}
