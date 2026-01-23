import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';

class ValidateFaceWidget extends StatefulWidget {
  const ValidateFaceWidget({super.key});

  @override
  State<ValidateFaceWidget> createState() => _ValidateFaceWidgetState();
}

class _ValidateFaceWidgetState extends State<ValidateFaceWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation(
                      AppTheme.primaryColor.withOpacity(0.75),
                    ),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                  ),
                ),
                const Icon(
                  Icons.shield_outlined,
                  size: 48,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Validando identidad...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: AppTheme.dark,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Espere un momento',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.hinText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
