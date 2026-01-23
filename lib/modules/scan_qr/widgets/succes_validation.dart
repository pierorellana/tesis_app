import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/providers/functional_provider.dart';
import 'package:tesis_app/shared/widgets/status_icon_animated.dart';

class SuccessValidation extends StatefulWidget {
  const SuccessValidation({super.key});

  @override
  State<SuccessValidation> createState() => _SuccessValidationState();
}

class _SuccessValidationState extends State<SuccessValidation> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.read<FunctionalProvider>().setEntryMethodItem(
        EntryMethodItem.none,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.white, AppTheme.greyBlocked],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const StatusIconAnimated(
                  color: Color(0xFF14A44D),
                  icon: Icons.check_rounded,
                  size: 140,
                  iconSize: 52,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Acceso autorizado',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.dark,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Redirigiendo al inicio...',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.hinText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
