// firebase (previous implementation)
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// firebase (previous implementation)
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../models/user.dart';

import '../../components/domain_card.dart';
import '../../l10n/dynamic_localizations.dart';
import '../../models/business_domain.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:nariudyam/providers/schedule_providers.dart';
import '../../services/general/messenger.dart';

class _BusinessDomainInfo {
  final String name;
  final String assetPath;
  _BusinessDomainInfo(this.name, this.assetPath);
}

class BusinessDomainScreen extends ConsumerWidget {
  const BusinessDomainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<_BusinessDomainInfo> domains = [
      _BusinessDomainInfo(context.tr('Beauty Parlor'),
          'assets/icons/onboarding/beauty_parlor.png'),
      _BusinessDomainInfo(
          context.tr('Tailor Shop'), 'assets/icons/onboarding/tailor_shop.png'),
      _BusinessDomainInfo(context.tr('Tiffin Services'),
          'assets/icons/onboarding/tiffin_service.png'),
      _BusinessDomainInfo(context.tr('Grocery Seller'),
          'assets/icons/onboarding/grocery_seller.png'),
      _BusinessDomainInfo(context.tr('Convenience Store'),
          'assets/icons/onboarding/convenience_store.png'),
      _BusinessDomainInfo(context.tr('Other Business'),
          'assets/icons/onboarding/other_business.png'),
    ]; //todo: make other business button functional

    Future<void> selectDomain(String domain) async {
      final user = ref.read(userProvider);
      if (user == null) return;

      try {
        // firebase (previous implementation)
        /*
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'businessDomain': domain});

        // Refresh the user provider to reflect the business domain
        final updatedDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (updatedDoc.exists) {
          final userModel = UserModel.fromFirestore(updatedDoc);
          ref.read(userProvider.notifier).state = userModel;
        }
        */

        await ref.read(authServiceProvider).updateUserProfile({
          'businessDomain': domain,
        });

        // Refresh the user provider to reflect the business domain
        final userModel = await ref.read(authServiceProvider).loadUserModel();
        if (userModel != null) {
          ref.read(userProvider.notifier).state = userModel;
        }

        ref.read(currentDomainProvider.notifier).state =
            BusinessDomainExtension.fromString(domain);

        context.go('/dashboard');
      } catch (e) {
        ref
            .read(messengerProvider)
            .showError(context.tr('Could not save domain. Please try again.'));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            context.tr("Hello!"),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontFamily: 'PatrickHand',
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            context.tr("Select your business domain"),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'PatrickHand',
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: const EdgeInsets.only(bottom: 24),
              children: domains.map((domain) {
                return DomainCard(
                  label: domain.name,
                  iconAssetPath: domain.assetPath,
                  onTap: () => selectDomain(domain.name),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

