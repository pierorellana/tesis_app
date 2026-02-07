import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';

class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.width,
    this.height,
    this.iconSize,
    this.titleSize,
    this.subtitleSize,
    this.padding,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final double? iconSize;
  final double? titleSize;
  final double? subtitleSize;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 310,
      height: height ?? 250,
      child: Material(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightGrey),
            ),
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize ?? 60,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize ?? 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.dark,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: subtitleSize ?? 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.hinText,
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
