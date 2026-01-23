import 'package:flutter/material.dart' hide Title;
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/widgets/title.dart';


class FilterWidget extends StatelessWidget {
  final IconData iconData;
  final int count;
  final String label;
  final Color color;
  final void Function() onTap;

  const FilterWidget({
    super.key,
    required this.iconData,
    required this.count,
    required this.label,
    this.color = AppTheme.greenText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    
    return RawChip(
      backgroundColor: AppTheme.greyBlocked,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      side: BorderSide.none,
      avatar: Container(
        margin: const EdgeInsets.only(left: 0),
        decoration: const BoxDecoration(
          color: Color(0XFF0a9146),
          shape: BoxShape.circle,
        ),
        width: 35,
        height: 35,
        child: Center(child: Icon(Icons.tune, color: AppTheme.whiteText, size: 20)),
      ),
      label: Title(title: '${count >= 1000 ? '999+': count} $label', fontSize: 16, fontWeight: FontWeight.bold),
      onPressed: onTap,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      padding: const EdgeInsets.only(right: 6),
    );
  }
}
