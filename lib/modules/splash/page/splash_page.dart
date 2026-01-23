import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/modules/home/pages/home_page.dart';
import '../../../env/theme/app_theme.dart';
import '../../../shared/helpers/global_helper.dart';
import '../../../shared/providers/functional_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late FunctionalProvider fp;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fp = Provider.of<FunctionalProvider>(context, listen: false);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 125), () {
          if (mounted) _controller.reverse();
        });
      }

      if (status == AnimationStatus.dismissed) {
        if (mounted) {
          _routePage(page: const HomePage());
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _routePage({required Widget page}) {
    GlobalHelper.routeRemoveSlideTransition(context: context, page: page);
    // Future.delayed(
    //   const Duration(seconds: 2),
    //   () =>
    //       GlobalHelper.routeRemoveSlideTransition(context: context, page: page),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Align(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Hero(
                  tag: 'logo',
                  child: Image.asset(AppTheme.logoApp, width: 325),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
