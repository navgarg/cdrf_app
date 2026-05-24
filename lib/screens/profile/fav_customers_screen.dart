import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/providers/fav_customer_providers.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import '../../l10n/dynamic_localizations.dart';

// firebase (previous implementation)
// import '../../services/api/fav_customer_service.dart';
// import '../../services/api/auth_service.dart';

final favouriteCustomerFabPressedProvider = StateProvider<bool>((ref) => false);

class FavouriteCustomersScreen extends ConsumerStatefulWidget {
  const FavouriteCustomersScreen({super.key});

  @override
  ConsumerState<FavouriteCustomersScreen> createState() =>
      _FavouriteCustomersScreenState();
}

class _FavouriteCustomersScreenState
    extends ConsumerState<FavouriteCustomersScreen> {
  void _showAddCustomerDialog(String? userId) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
      barrierDismissible: true,
      barrierLabel: context.tr('Add Favourite Customer'),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(dialogContext).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(dialogContext).viewInsets.bottom + 24,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(context.tr('New Favourite Customer'),
                          style:
                              Theme.of(dialogContext).textTheme.headlineSmall),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                            labelText: context.tr('Customer Name')),
                        validator: (value) => value!.isEmpty
                            ? context.tr('Please enter a name')
                            : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final success = await ref
                                .read(favouriteCustomerServiceProvider(userId))
                                .addFavouriteCustomer(nameController.text);

                            if (success) {
                              if (!dialogContext.mounted) return;
                              final _ = ref
                                  .refresh(favouriteCustomersProvider(userId));
                              Navigator.of(dialogContext).pop();
                            }
                          }
                        },
                        child: Text(context.tr('Save Customer')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userProvider)?.uid;
    ref.listen(favouriteCustomerFabPressedProvider, (_, isPressed) {
      if (isPressed) {
        _showAddCustomerDialog(userId);
        ref.read(favouriteCustomerFabPressedProvider.notifier).state = false;
      }
    });
    final favCustomersAsync = ref.watch(favouriteCustomersProvider(userId));
    final theme = Theme.of(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(context.tr('Favourite Customers')),
      // ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Manage Favourites'),
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  context
                      .tr('Add or remove customers you want to track closely.'),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const Divider(height: 24),
              ],
            ),
          ),
          Expanded(
            child: favCustomersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text(context.tr('Error: $err'))),
              data: (customerList) {
                if (customerList.isEmpty) {
                  return Center(
                    child: Text(
                      context.tr(
                          'You have no favourite customers yet.\nTap the + button to add one!'),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: customerList.length,
                  itemBuilder: (context, index) {
                    final customer = customerList[index];
                    return Card(
                      color: theme.cardColor,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person,
                            color: theme.colorScheme.primary),
                        title: Text(customer.name),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: theme.colorScheme.primary),
                          onPressed: () async {
                            final success = await ref
                                .read(favouriteCustomerServiceProvider(userId))
                                .deleteFavouriteCustomer(customer.id);
                            if (success) {
                              final _ = ref
                                  .refresh(favouriteCustomersProvider(userId));
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCustomerDialog(userId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
