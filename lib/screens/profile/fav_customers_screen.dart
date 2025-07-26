import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api/fav_customer_service.dart';

final favouriteCustomerFabPressedProvider = StateProvider<bool>((ref) => false);

class FavouriteCustomersScreen extends ConsumerStatefulWidget {
  const FavouriteCustomersScreen({super.key});

  @override
  ConsumerState<FavouriteCustomersScreen> createState() => _FavouriteCustomersScreenState();
}

class _FavouriteCustomersScreenState extends ConsumerState<FavouriteCustomersScreen> {

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
      barrierDismissible: true,
      barrierLabel: 'Add Favourite Customer',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24, right: 24, top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('New Favourite Customer', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Customer Name'),
                        validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final success = await ref
                                .read(favouriteCustomerServiceProvider)
                                .addFavouriteCustomer(nameController.text);

                            if (success && mounted) {
                              ref.refresh(favouriteCustomersProvider);
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: const Text('Save Customer'),
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
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favCustomersAsync = ref.watch(favouriteCustomersProvider);
    final theme = Theme.of(context);

    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Favourites',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add or remove customers you want to track closely.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
                const Divider(height: 24),
              ],
            ),
          ),

          Expanded(
            child: favCustomersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (customerList) {
                if (customerList.isEmpty) {
                  return const Center(
                    child: Text(
                      'You have no favourite customers yet.\nTap the + button to add one!',
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
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person, color: theme.colorScheme.primary),
                        title: Text(customer.name),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: theme.colorScheme.primary),
                          onPressed: () async {
                            final success = await ref
                                .read(favouriteCustomerServiceProvider)
                                .deleteFavouriteCustomer(customer.id);
                            if (success) {
                              ref.refresh(favouriteCustomersProvider);
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
    );
  }
}