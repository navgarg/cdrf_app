import 'package:flutter/material.dart';
import '../utils/app_visuals.dart';
// TODO: Add import for your localization solution, e.g.:
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// or your custom i18n package

class OnboardingLayout extends StatelessWidget {
  final Widget child;

  const OnboardingLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: size.height * 0.50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 42,
                  child: Opacity(
                    opacity: 0.18,
                    child: Image.asset(
                      AppVisuals.appIcon,
                      width: size.width * 0.75,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
                Container(color: Colors.black.withAlpha(35)),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top section with logo and tagline - common for all screens
                SizedBox(
                  height: size.height * 0.35,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nari Udyam', // TODO: Replace with AppLocalizations.of(context)!.appName
                          style: TextStyle(
                            fontFamily: 'Rochester',
                            fontSize: 50,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Vyapar chalati, Naari ka saathi', // TODO: Replace with AppLocalizations.of(context)!.appTagline
                          style: TextStyle(
                            fontFamily: 'PatrickHand',
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
