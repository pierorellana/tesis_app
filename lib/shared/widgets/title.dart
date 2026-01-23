import 'package:flutter/material.dart';
import '../../env/theme/app_theme.dart';

class Title extends StatelessWidget {
  const Title({
    super.key,
    this.fontSize = 20,
    this.textAlign,
    required this.title,
    this.fontWeight = FontWeight.w500,
    this.height,
    this.color = AppTheme.whiteText, 
    this.isOverflow = true,
    
  });

  final double? fontSize;
  final TextAlign? textAlign;
  final String title;
  final FontWeight? fontWeight;
  final double? height;
  final Color color;
  final bool? isOverflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      textScaler: MediaQuery.textScalerOf(context).clamp(minScaleFactor: 0.95, maxScaleFactor: 1.137),
      title,
      overflow: isOverflow == true ? TextOverflow.ellipsis : null,
      textAlign: textAlign,
      style: TextStyle(
        color:  (Theme.of(context).brightness == Brightness.dark ? color : AppTheme.dark),
        fontWeight: fontWeight,
        fontSize: fontSize,
        height: height,
      ),
    );
  }
}
