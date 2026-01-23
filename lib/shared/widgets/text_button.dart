import 'package:flutter/material.dart';
import '../../env/theme/app_theme.dart';

class TextButtonWidget extends StatelessWidget {
  final String nameButton;
  final void Function()? onPressed;
  final double? fontSize;
  final Color? textButtonColor;

  const TextButtonWidget(
      {super.key,
      required this.nameButton,
      this.onPressed,
      this.fontSize = 15,
      this.textButtonColor = AppTheme.darkBlue});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(overlayColor: Colors.black12),
      onPressed: onPressed,
      child: Text(nameButton,
          style: TextStyle(color: textButtonColor, fontSize: fontSize, fontWeight: FontWeight.bold)),
    );
  }
}
