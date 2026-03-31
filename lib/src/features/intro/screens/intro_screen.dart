import 'package:easy_localization/easy_localization.dart';
import 'package:evim_furniture/src/core/constants/app_texts.dart';
import 'package:evim_furniture/src/core/router/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const List<_IntroPage> _pages = <_IntroPage>[
    _IntroPage(
      svgAsset: 'assets/images/introOne.svg',
      titleKey: AppTexts.intro1Title,
      subtitleKey: AppTexts.intro1Subtitle,
    ),
    _IntroPage(
      svgAsset: 'assets/images/introTwo.svg',
      titleKey: AppTexts.intro2Title,
      subtitleKey: AppTexts.intro2Subtitle,
    ),
    _IntroPage(
      svgAsset: 'assets/images/introThree.svg',
      titleKey: AppTexts.intro3Title,
      subtitleKey: AppTexts.intro3Subtitle,
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      Navigator.of(context).pushNamedAndRemoveUntil(Pages.home, (_) => false);
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    if (_index == 0) {
      Navigator.pop(context);
      return;
    }
    _controller.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _back,
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (_, int i) {
                  final _IntroPage p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(p.svgAsset, height: 260, fit: BoxFit.contain),
                        const SizedBox(height: 24),
                        Text(
                          p.titleKey.tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: cs.secondary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          p.subtitleKey.tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: cs.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 90),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 52),
                  Expanded(
                    child: Center(
                      child: _DotsIndicator(length: _pages.length, index: _index),
                    ),
                  ),
                  TextButton(
                    onPressed: _next,
                    style: TextButton.styleFrom(
                      foregroundColor: cs.secondary,
                      textStyle: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      _isLast ? AppTexts.btnGetStarted.tr() : AppTexts.btnNext.tr(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.length, required this.index});

  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(length, (int i) {
        final bool active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? cs.secondary : Colors.transparent,
            border: Border.all(color: cs.secondary, width: 1.6),
          ),
        );
      }),
    );
  }
}

class _IntroPage {
  const _IntroPage({
    required this.svgAsset,
    required this.titleKey,
    required this.subtitleKey,
  });

  final String svgAsset;
  final String titleKey;
  final String subtitleKey;
}