import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';

class ReadingPlateWidget extends StatelessWidget {
  const ReadingPlateWidget({super.key});

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
                Icons.directions_car_filled_outlined,
                size: 42,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Leyendo placa...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w900,
            color: AppTheme.dark,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Espere un momento',
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
