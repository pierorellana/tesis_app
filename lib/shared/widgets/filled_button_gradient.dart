import 'package:flutter/material.dart';
import '../../env/theme/app_theme.dart';

class FilledButtonGradientWidget extends StatefulWidget {
  const FilledButtonGradientWidget({
    super.key,
    this.onPressed,
    this.color,
    required this.text,
    this.width = double.infinity,
    this.height = 40,
    this.borderRadius = 20,
    this.textButtonColor,
    this.disabledColor,
  });

  final void Function()? onPressed;
  final Color? color;
  final String text;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? textButtonColor;
  final Color? disabledColor;

  @override
  State<FilledButtonGradientWidget> createState() =>
      _FilledButtonIconGradientWidgetState();
}

class _FilledButtonIconGradientWidgetState
    extends State<FilledButtonGradientWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDisabled = widget.onPressed == null;

    return Container(
      width: widget.width!,
      height: widget.height!,
      decoration: BoxDecoration(
        gradient: isDisabled 
            ? null 
            : const LinearGradient(
                colors: [AppTheme.darkBlue, AppTheme.deepNavyBlue],
              ),
        color: isDisabled 
            ? (widget.disabledColor ?? Colors.grey.withOpacity(0.5)) 
            : widget.color,
        borderRadius: BorderRadius.circular(widget.borderRadius!),
      ),
      child: FilledButton(
        style: ButtonStyle(
          shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
          minimumSize: WidgetStateProperty.all<Size>(
            Size(widget.width!, widget.height!),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius!),
            ),
          ),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        onPressed: widget.onPressed,
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.textButtonColor ?? AppTheme.white,
            fontWeight: FontWeight.w500,
            fontSize: size.height * 0.020,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}