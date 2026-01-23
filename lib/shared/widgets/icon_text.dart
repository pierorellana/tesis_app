import 'package:flutter/material.dart' hide Title;
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/widgets/title.dart';

class IconText extends StatelessWidget {
  const IconText({super.key, required this.icon, required this.text, this.flex, this.isToUpperCase = true});
  final IconData icon;
  final String text;
  final int? flex;
  final bool isToUpperCase;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.mutedColor),
        Expanded(
          flex: flex ?? 1,
          child: Title(title: isToUpperCase ? text.toUpperCase() : text , fontSize: 14)),
      ],
    );
  }
}
