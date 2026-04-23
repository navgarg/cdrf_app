class ResourceEntry {
  final String id;
  final String name;
  final String url;
  final String uploadedBy;
  final DateTime timestamp;
  final int size;

  const ResourceEntry({
    required this.id,
    required this.name,
    required this.url,
    required this.uploadedBy,
    required this.timestamp,
    required this.size,
  });

  factory ResourceEntry.fromMap(Map<String, dynamic> data) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now().toUtc();
      if (value is DateTime) return value.toUtc();
      if (value is String) return DateTime.parse(value).toUtc();
      return DateTime.now().toUtc();
    }

    return ResourceEntry(
      id: (data['id'] ?? '').toString(),
      name: (data['name'] ?? 'file').toString(),
      url: (data['url'] ?? '').toString(),
      uploadedBy: (data['uploaded_by'] ?? data['uploadedBy'] ?? '').toString(),
      timestamp: parseDateTime(data['timestamp']),
      size: (data['size'] ?? 0) is int
          ? (data['size'] as int)
          : int.tryParse((data['size'] ?? 0).toString()) ?? 0,
    );
  }
}
