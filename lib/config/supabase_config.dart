class SupabaseConfig {
  static const String supabaseUrl = 'https://sulqucjnwgwhgwynvqhv.supabase.co';

  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1bHF1Y2pud2d3aGd3eW52cWh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE5MjIxNzUsImV4cCI6MjA4NzQ5ODE3NX0.WEeshcfrD5Lh5-q4-V3UXuENW_zsaZFZ8ByZ37fTAYk';

  // Optional: Custom schema name (default is 'public')
  static const String schema = 'public';

  // Storage bucket names
  static const String resourcesBucket = 'resources';
  static const String profileImagesBucket = 'profile-images';
}
