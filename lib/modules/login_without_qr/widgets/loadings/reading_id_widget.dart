import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';

class ReadingIdInfoWidget extends StatelessWidget {
  const ReadingIdInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
                Icons.description_outlined,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Leyendo información...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w900,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Esto puede tardar unos segundos',
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
