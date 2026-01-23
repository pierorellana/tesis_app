import 'package:flutter/material.dart';
import '../../env/theme/app_theme.dart';
import '../helpers/responsive.dart';

class FilledButtonWidget extends StatefulWidget {
  const FilledButtonWidget({
    super.key,
    this.onPressed,
    this.color,
    required this.text,
    this.width = double.infinity,
    this.height,
    this.borderRadius = 20,
    this.textButtonColor,
    required this.icon,
    this.borderSide,
    this.iconColor,
    this.fontWeight = FontWeight.w500,
    this.iconOnLeft = false,
  });

  final void Function()? onPressed;
  final Color? color;
  final String text;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? textButtonColor;
  final Widget icon;
  final BorderSide? borderSide;
  final Color? iconColor;
  final FontWeight? fontWeight;
  final bool iconOnLeft;

  @override
  State<FilledButtonWidget> createState() => _FilledButtonWidgetState();
}

class _FilledButtonWidgetState extends State<FilledButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final responsive = Responsive(context);

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: SizedBox(
        width: widget.width,
        height: widget.height ?? responsive.hp(3.8),
        child: FilledButton(
          style: ButtonStyle(
            elevation: WidgetStateProperty.all<double>(
              widget.onPressed != null ? 2 : 0,
            ),
            iconColor: WidgetStatePropertyAll(
              widget.iconColor ?? AppTheme.white,
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius!),
              ),
            ),
            side: WidgetStateProperty.all<BorderSide>(
              widget.borderSide ?? BorderSide.none,
            ),
            backgroundColor: WidgetStatePropertyAll(widget.color),
          ),
          onPressed: widget.onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.iconOnLeft
                ? [
                    widget.icon,
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.textButtonColor ?? AppTheme.black,
                        fontWeight: widget.fontWeight,
                        fontSize: size.height * 0.015,
                      ),
                    ),
                  ]
                : [
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.textButtonColor ?? AppTheme.black,
                        fontWeight: widget.fontWeight,
                        fontSize: size.height * 0.015,
                      ),
                    ),
                    widget.icon,
                  ],
          ),
        ),
      ),
    );
  }
}
