import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/router/app_route_path.dart';

/// Animated splash: faded logo → vivid logo → brand mark + version.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

enum _SplashPhase { start, middle, done }

class _SplashPageState extends State<SplashPage> {
  _SplashPhase _phase = _SplashPhase.start;

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _phase = _SplashPhase.middle);

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _phase = _SplashPhase.done);

    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    context.go(AppRoutePath.bootContinuePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: switch (_phase) {
                  _SplashPhase.start => SvgPicture.asset(
                      'assets/logo/loading-start.svg',
                      key: const ValueKey('start'),
                      width: 190,
                      height: 173,
                    ),
                  _SplashPhase.middle => SvgPicture.asset(
                      'assets/logo/loading-middle2.svg',
                      key: const ValueKey('middle'),
                      width: 190,
                      height: 173,
                    ),
                  _SplashPhase.done => const _SplashBrand(
                      key: ValueKey('done'),
                    ),
                },
              ),
            ),
            if (_phase == _SplashPhase.done)
              const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 36),
                  child: Text(
                    'Version ${AppInfo.version}',
                    style: TextStyle(
                      color: Color(0xFF0F4888),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SplashBrand extends StatelessWidget {
  const _SplashBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/logo/Chat Round.svg',
            width: 220,
            height: 220,
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Group 8',
                style: TextStyle(
                  color: Color(0xFF0F4888),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Stay Chatting',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
