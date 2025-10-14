/// Admin configuration
/// Add admin phone numbers here (with country code)
class AdminConfig {
  // List of admin phone numbers
  static const List<String> adminPhoneNumbers = [
    '+911234567890', // Admin portal access
    // Add more admin numbers as needed
  ];

  /// Check if a phone number is an admin
  static bool isAdmin(String phoneNumber) {
    return adminPhoneNumbers.contains(phoneNumber);
  }
}
