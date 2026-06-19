// Central export file for all app providers.
// Import this file to get access to all providers in the app.

// Shared providers (used by both Firebase and Supabase)
export 'shared_providers.dart';

// Backend selection
export '../config/backend_config.dart';

// Switch providers (automatically use Firebase or Supabase based on config)
export 'auth_providers.dart';
export 'resource_providers.dart';

// Domain providers
export 'transaction_providers.dart';
export 'inventory_providers.dart';
export 'services_providers.dart';
export 'schedule_providers.dart';
export 'fav_customer_providers.dart';
export 'admin_providers.dart';
