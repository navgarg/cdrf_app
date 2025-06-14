import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../components/domain_card.dart';
import '../../components/regular_button.dart';
import '../../services/api/auth_service.dart';
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
      _BusinessDomainInfo('Beauty Parlor', 'assets/icons/onboarding/beauty_parlor.png'),
      _BusinessDomainInfo('Tailor Shop', 'assets/icons/onboarding/tailor_shop.png'),
      _BusinessDomainInfo('Tiffin Services', 'assets/icons/onboarding/tiffin_service.png'),
      _BusinessDomainInfo('Grocery Seller', 'assets/icons/onboarding/grocery_seller.png'),
      _BusinessDomainInfo('Convenience Store', 'assets/icons/onboarding/convenience_store.png'),
      _BusinessDomainInfo('Other Business', 'assets/icons/onboarding/other_business.png'),
    ];

    Future<void> selectDomain(String domain) async {
      final user = ref.read(userProvider);
      if (user == null) return;

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'businessDomain': domain});

        context.go('/dashboard');
      } catch (e) {
        ref.read(messengerProvider).showError('Could not save domain. Please try again.');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const Text(
            "Hello!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontFamily: 'PatrickHand',
              fontWeight: FontWeight.w800,

            ),
          ),
          const Text(
            "Select your business domain",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'PatrickHand',
              fontWeight: FontWeight.w300,

            ),
          ),
          const SizedBox(height: 24,),
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