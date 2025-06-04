import 'package:nariudyam/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/api/fcm_service.dart';
import 'services/general/messenger.dart';
import 'services/general/settings.dart';
import 'utils/router.dart';
import 'utils/theme.dart';

// Define a background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message received: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await ref.read(settingsProvider).init();
    await ref.read(fcmServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final messenger = ref.watch(messengerProvider);
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppInfo.name,
      scaffoldMessengerKey: messenger.scaffoldMessengerKey,
      theme: theme,
      routerConfig: router,
    );
  }
}
