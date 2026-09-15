import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/router/app_route_path.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class _OnboardingStep {
  const _OnboardingStep({
    required this.asset,
    required this.title,
    required this.subtitle,
  });

  final String asset;
  final String title;
  final String subtitle;
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  var _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingCompletedProvider.notifier).complete();
    if (!mounted) return;
    context.go(AppRoutePath.loginPath);
  }

  void _next(int stepCount) {
    if (_index >= stepCount - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  List<_OnboardingStep> _stepsFor(AppStrings s) => [
        _OnboardingStep(
          asset: 'assets/images/step1.png',
          title: s.onboardingStep1Title,
          subtitle: s.onboardingStep1Subtitle,
        ),
        _OnboardingStep(
          asset: 'assets/images/step2.png',
          title: s.onboardingStep2Title,
          subtitle: s.onboardingStep2Subtitle,
        ),
        _OnboardingStep(
          asset: 'assets/images/step3.png',
          title: s.onboardingStep3Title,
          subtitle: s.onboardingStep3Subtitle,
        ),
        _OnboardingStep(
          asset: 'assets/images/step4.png',
          title: s.onboardingStep4Title,
          subtitle: s.onboardingStep4Subtitle,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final s = ref.watch(appStringsProvider);
    final steps = _stepsFor(s);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * 0.42,
            child: CustomPaint(
              painter: _WavePainter(color: AppColors.brandSurfaceAlt),
              child: const SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: steps.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: Image.asset(
                                  step.asset,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              step.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF0F4888),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              step.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.brandLight,
                                fontSize: 15,
                                height: 1.35,
                              ),
                            ),
                            const Spacer(flex: 2),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [AppColors.brandLight, AppColors.brand],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: _finish,
                          child: Center(
                            child: Text(
                              s.getStarted,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          s.skip,
                          style: const TextStyle(
                            color: Color(0xFF64B5F6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(steps.length, (i) {
                            final active = i == _index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: active ? 10 : 7,
                              height: active ? 10 : 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: active
                                    ? AppColors.headerBlue
                                    : const Color(0xFFBBDEFB),
                              ),
                            );
                          }),
                        ),
                      ),
                      Material(
                        color: const Color(0xFFBBDEFB).withValues(alpha: 0.55),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _next(steps.length),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: Center(
                              child: Text(
                                s.next,
                                style: const TextStyle(
                                  color: Color(0xFF0F4888),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _WavePainter extends CustomPainter {
  _WavePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.5,
        0,
        size.width,
        size.height * 0.18,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
