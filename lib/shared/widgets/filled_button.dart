import 'package:flutter/material.dart' hide Title;
import 'package:tesis_app/env/theme/app_theme.dart';

class FilledButtonWidget extends StatelessWidget {
  const FilledButtonWidget({
    super.key,
    this.onPressed,
    this.color,
    required this.text,
    this.width = double.infinity,
    this.height = 40,
    this.borderRadius = 10,
    this.textButtonColor = AppTheme.whiteText,
    this.fontSize = 0.020,
  });

  final void Function()? onPressed;
  final Color? color;
  final String text;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? textButtonColor;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Brightness theme = Theme.of(context).brightness;


    return FilledButton(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all<Size>(Size(width!, height!)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius!)),
        ),
        surfaceTintColor: onPressed != null ? WidgetStatePropertyAll(color ?? AppTheme.primaryColor) : null,
        backgroundColor: onPressed != null ? WidgetStatePropertyAll(color ?? AppTheme.primaryColor) : null,
      ),
      onPressed: onPressed,
      child: Text(
        textAlign: TextAlign.center,
        text,
        style: TextStyle(
          color: theme == Brightness.dark ? textButtonColor : AppTheme.white,
          fontSize: size.height * fontSize!,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
