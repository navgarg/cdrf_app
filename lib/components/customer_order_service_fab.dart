import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/business_domain.dart';
import 'package:nariudyam/models/business_domain.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import '../screens/add_service_item_form.dart';

class CustomerOrderServiceFab extends ConsumerWidget {
  const CustomerOrderServiceFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isService = BusinessDomainUtils.isServiceDomain(user?.businessDomain);
    if (!isService) return const SizedBox.shrink();
    return FloatingActionButton(
      onPressed: () {
        showGeneralDialog(
          context: context,
          barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
          barrierDismissible: true,
          barrierLabel: 'Add Service Item',
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
                child: const Material(
                  color: Colors.transparent,
                  child: AddServiceItemForm(),
                ),
              ),
            );
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                      .animate(animation),
              child: child,
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
