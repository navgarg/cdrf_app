import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/backend_config.dart';
import '../services/adapters/firebase_transaction_service_adapter.dart';
import '../services/api/transaction_service_supabase.dart';
import '../services/interfaces/i_transaction_service.dart';
import 'shared_providers.dart';
import '../models/transaction.dart';

final transactionServiceSwitchProvider = Provider<ITransactionService>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == BackendType.firebase) {
    return FirebaseTransactionServiceAdapter(ref);
  }
  return TransactionServiceSupabase(ref);
});

/// Compatibility provider name used widely in the app.
final transactionServiceProvider = Provider<ITransactionService>((ref) {
  return ref.watch(transactionServiceSwitchProvider);
});

/// Compatibility provider name used by dashboard_service.
final allTransactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) {
    return Stream.value(<Transaction>[]);
  }
  return ref.watch(transactionServiceProvider).streamTransactions();
});
