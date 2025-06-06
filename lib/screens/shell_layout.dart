import 'package:flutter/material.dart';

class OnboardingLayout extends StatelessWidget {
  final Widget child;

  const OnboardingLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Replace with video/whatever
          Container(
            width: double.infinity,
            height: size.height * 0.50,
            color: Colors.black45, // If image, keep it darkened like this
            child: Opacity(
              opacity: 0.3,
              child: Container(
                color: Colors.black, // Replace this part with the image?
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top section with logo and tagline - common for all screens
                SizedBox(
                  height: size.height * 0.4,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nari Udyam',
                          style: TextStyle(
                            fontFamily: 'Rochester',
                            fontSize: 46,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Vyapar chalati, Naari ka saathi',
                          style: TextStyle(
                            fontFamily: 'PatrickHand',
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: child
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
