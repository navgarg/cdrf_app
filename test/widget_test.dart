// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nariudyam/config/supabase_config.dart';
import 'package:nariudyam/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    // Widget tests don't run `main()`, so we must initialize Supabase here.
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        // Avoid deep-link/plugin requirements during widget tests.
        detectSessionInUri: false,
      ),
    );
  });

  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NariUdyam(),
      ),
    );

    // Don't use pumpAndSettle(): the app may keep timers/streams alive.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Basic sanity check: the app renders a MaterialApp shell.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
