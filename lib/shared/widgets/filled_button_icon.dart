import 'package:flutter/material.dart' hide Title;
import 'package:tesis_app/env/theme/app_theme.dart';
class FilledButtonIcon extends StatelessWidget {
  const FilledButtonIcon({
    super.key,
    required this.icon,
    required this.title,
    this.onPressed,
  });
  final IconData icon;
  final String title;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(AppTheme.primaryLightColor),
        minimumSize: WidgetStateProperty.all<Size>(Size(150, 35)),
      ),
      icon: Icon(icon, color: AppTheme.whiteText),
      label: Text(
        textAlign: TextAlign.center,
        title,
        style: TextStyle(
          color: AppTheme.whiteText,
          fontSize: 15.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
