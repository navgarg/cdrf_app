import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../components/generic_list_tile.dart';
import '../../components/regular_button.dart';
import '../../services/api/auth_service.dart';
import '../../services/general/messenger.dart';
import '../../services/general/excel_service.dart';
import '../../services/general/onboarding_excel_service.dart';
import '../../l10n/dynamic_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../services/translation_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  StreamSubscription? _translationSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // Listen for translation updates and trigger rebuild
    _translationSubscription =
        TranslationService().onTranslationUpdated.listen((_) {
      if (_refreshTimer?.isActive ?? false) return;

      _refreshTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {});
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

  void _showLanguagesDialog(BuildContext context) {
    const Map<String, String> languagesMap = {
      'English': 'en',
      'हिन्दी': 'hi',
      'తెలుగు': 'te',
      'മലയാളം': 'ml',
      'ಕನ್ನಡ': 'kn',
      'தமிழ்': 'ta',
    };
    final List<String> languages = languagesMap.keys.toList();

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
      barrierDismissible: true,
      barrierLabel: context.tr('Select Language'),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr('Select Language'),
                      style: const TextStyle(
                        fontSize: 36,
                        fontFamily: 'PatrickHand',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...languages.map(
                      (lang) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: RegularButton(
                            text: lang,
                            onPressed: () async {
                              final langCode = languagesMap[lang];
                              if (langCode != null) {
                                // Close dialog first
                                Navigator.of(context).pop();

                                // Update locale - this triggers app-wide translation
                                await ref
                                    .read(localeProvider.notifier)
                                    .setLocale(Locale(langCode));

                                // Update User Profile in Firebase in background (don't await to prevent redirect)
                                ref
                                    .read(authServiceProvider)
                                    .updateUserProfile({'language': langCode});

                                // Show success message - stay on profile page
                                if (context.mounted) {
                                  ref.read(messengerProvider).showSuccess(
                                      context.tr('Language Updated to $lang'));
                                }
                              }
                            },
                          )),
                    ),
                  ],
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
    final theme = Theme.of(context);
    final user = ref.watch(userProvider);

    // Show a loading indicator if user data isn't available yet
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Use a SingleChildScrollView to prevent overflow
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black12,
              child: Icon(Icons.person, size: 60, color: Colors.black45),
            ),
            const SizedBox(height: 12),
            Text(
              user.name ?? context.tr('User'),
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user.phoneNumber,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 9),
            _buildInfoSection(context, context.tr('Business Information')),
            _buildInfoRow(context.tr('Business Name'),
                user.name ?? context.tr('Not Available')),
            _buildInfoRow(context.tr('Business Domain'),
                user.businessDomain ?? context.tr('Not Available')),
            const SizedBox(height: 16),
            _buildInfoSection(context, context.tr('Settings')),
            GenericListTile(
              leading: Icon(Icons.translate,
                  color: theme.colorScheme.primary, size: 28),
              titleWidget: Text(
                context.tr('Languages'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade600),
              onTap: () {
                _showLanguagesDialog(context);
              },
            ),
            GenericListTile(
              leading: Icon(Icons.notifications_none_outlined,
                  color: theme.colorScheme.primary, size: 28),
              titleWidget: Text(
                context.tr('Notifications'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade600),
              onTap: () {},
            ),
            GenericListTile(
              leading: Icon(Icons.favorite_border_rounded,
                  color: theme.colorScheme.primary, size: 28),
              titleWidget: Text(
                context.tr('Favourite Customers'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade600),
              onTap: () => context.push('/profile/favourite_customers'),
            ),
            GenericListTile(
              leading: Icon(Icons.request_quote_outlined,
                  color: theme.colorScheme.primary, size: 28),
              titleWidget: Text(
                context.tr('Financial Transactions'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Switch(
                value: user.financialTransactionsEnabled,
                onChanged: (value) {
                  // ref.read(authServiceProvider).updateUserProfile({
                  //   'financialTransactionsEnabled': value,
                  // });
                },
              ),
              onTap: () {},
            ),
            GenericListTile(
              leading: Icon(Icons.download,
                  color: theme.colorScheme.primary, size: 28),
              titleWidget: Text(
                context.tr('Export Transactions to Excel'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade600),
              onTap: () async {
                await ref
                    .read(excelServiceProvider)
                    .exportAllAnalyticsToExcel();
                ref
                    .read(messengerProvider)
                    .showSuccess(context.tr('Transactions Exported'));
              },
            ),
            GenericListTile(
              leading: Icon(Icons.upload_file,
                  color: theme.colorScheme.primary, size: 28),
              titleWidget: Text(
                context.tr('Export Onboarding Data to Excel'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade600),
              onTap: () async {
                await ref
                    .read(onboardingExcelServiceProvider)
                    .exportOnboardingDataToExcel(
                        []); // todo: pass actual list here
                ref
                    .read(messengerProvider)
                    .showSuccess(context.tr('Onboarding Data Exported'));
              },
            ),

            // Resource Centre tile - placed at end of page as requested
            GenericListTile(
              leading: Icon(Icons.folder,
                  color: theme.colorScheme.primary, size: 28),
              titleWidget: Text(
                context.tr('Resource Centre'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey.shade600),
              onTap: () => context.push('/resource_centre'),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  ref.read(authServiceProvider).signOut();
                },
                icon: const Icon(Icons.logout),
                label: Text(context.tr('Sign Out')),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: Colors.white,
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
