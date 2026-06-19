import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';
import 'dart:async';
// firebase (previous implementation)
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'firebase_options.dart';
import 'config/supabase_config.dart';
import 'providers/locale_provider.dart';
// firebase (previous implementation)
// import 'services/api/fcm_service.dart';
import 'services/general/messenger.dart';
import 'services/general/settings.dart';
import 'services/translation_service.dart';
import 'utils/router.dart';
import 'utils/theme.dart';

// firebase (previous implementation)
/*
// Define a background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message received: ${message.messageId}');
}
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // firebase (previous implementation)
  /*
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  */

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );

  // firebase (previous implementation)
  /*
  // Initialize background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  */

  // Run app
  runApp(
    const ProviderScope(
      child: NariUdyam(),
    ),
  );
}

class NariUdyam extends ConsumerStatefulWidget {
  const NariUdyam({super.key});

  @override
  ConsumerState<NariUdyam> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<NariUdyam> {
  StreamSubscription? _translationSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initServices();

    // Listen for translation updates and trigger rebuild
    _translationSubscription =
        TranslationService().onTranslationUpdated.listen((_) {
      // Debounce rebuilds to avoid performance issues
      if (_refreshTimer?.isActive ?? false) return;

      _refreshTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            // Trigger rebuild to show new translations
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _translationSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initServices() async {
    await ref.read(settingsProvider).init();
    // firebase (previous implementation)
    // await ref.read(fcmServiceProvider).initialize();
    // Initialize translation service
    await TranslationService().initialize();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final messenger = ref.watch(messengerProvider);
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      key: ValueKey(locale.languageCode), // Force rebuild when locale changes
      debugShowCheckedModeBanner: false,
      title: "Nari Udyam",
      scaffoldMessengerKey: messenger.scaffoldMessengerKey,
      theme: theme,
      routerConfig: router,
      localizationsDelegates: DynamicAppLocalizations.localizationsDelegates,
      supportedLocales: DynamicAppLocalizations.supportedLocales,
      locale: locale,
    );
  }
}
