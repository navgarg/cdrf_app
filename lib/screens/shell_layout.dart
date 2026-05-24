import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
// TODO: Add import for your localization solution, e.g.:
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// or your custom i18n package

class OnboardingLayout extends StatefulWidget {
  final Widget child;

  const OnboardingLayout({
    super.key,
    required this.child,
  });

  @override
  State<OnboardingLayout> createState() => _OnboardingLayoutState();
}

class _OnboardingLayoutState extends State<OnboardingLayout> {
  late final VideoPlayerController _videoController;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/videos/onboarding_background.mp4',
    )
      ..setLooping(true)
      ..setVolume(0);

    _videoController.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isVideoReady = true);
      _videoController.play();
    }).catchError((Object error) {
      debugPrint('Onboarding video could not be initialized: $error');
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

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
                if (_isVideoReady)
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  ),
                Container(color: Colors.black.withAlpha(70)),
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
                      child: widget.child,
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
