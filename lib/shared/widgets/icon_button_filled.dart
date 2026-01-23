import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';

class IconButtonFilledWidget extends StatelessWidget {
  const IconButtonFilledWidget({super.key, required this.icon, this.onPressed});
  final IconData icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll( 
          Colors.grey[300]
        ),
        minimumSize: WidgetStatePropertyAll(Size(35, 35)),
        maximumSize: WidgetStatePropertyAll(Size(40, 40)),
        padding: WidgetStatePropertyAll(EdgeInsets.zero)
      ),
      icon: Icon(icon, color: AppTheme.dark),
      onPressed: onPressed,
    );
  }
}
