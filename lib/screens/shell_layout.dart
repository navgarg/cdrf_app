import 'package:flutter/material.dart';

class ShellLayout extends StatelessWidget {
  final Widget child;

  const ShellLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Replace with video/whatever
          Container(
            width: double.infinity,
            height: size.height * 0.45,
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

                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
