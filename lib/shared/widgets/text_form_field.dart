import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../env/theme/app_theme.dart';
import '../helpers/global_helper.dart';

class TextFormFieldWidget extends StatelessWidget {
  const TextFormFieldWidget({
    super.key,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.hintText,
    this.maxHeigth = double.infinity,
    this.maxWidth = double.infinity,
    this.controller,
    this.validator,
    this.inputFormatters,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.fillColor = AppTheme.white,
    this.fontWeightHintText = FontWeight.w400,
    this.maxLines = 1,
    this.showShading = true,
    this.borderWith = 1.2,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.enabled,
    this.initialValue,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onSaved,
    this.borderRadius = 10,
    this.enabledBorder = true,
    this.style = const TextStyle(color: AppTheme.hinText, fontWeight: FontWeight.w400), this.fontSizeHintStyle,
  });

  final double maxHeigth;
  final double maxWidth;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final Color? fillColor;
  final FontWeight? fontWeightHintText;
  final int? maxLines;
  final bool? showShading;
  final double? borderWith;
  final FocusNode? focusNode;
  final bool? enabled;
  final bool? readOnly;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final String? initialValue;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final void Function(String?)? onSaved;
  final double borderRadius;
  final bool enabledBorder;
  final TextStyle? style;
  final double? fontSizeHintStyle;

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context).brightness;

    return TextFormField(
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      onTap: onTap,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      initialValue: initialValue,
      readOnly: readOnly!,
      enabled: enabled,
      focusNode: focusNode,
      maxLines: maxLines,
      obscuringCharacter: '*',
      obscureText: obscureText,
      style: style,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator,
      controller: controller,
      onTapOutside: (pointerDownEvent) {
        // GlobalHelper.dismissKeyboard(context);
      },
      textAlign: textAlign,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          errorMaxLines: 15,
          errorStyle: const TextStyle(color: AppTheme.actionError),
          filled: true,
          fillColor: (enabled != false ? (AppTheme.lightGrey) : AppTheme.secondary2Color),
          prefixIconColor: theme == Brightness.dark ? AppTheme.whiteText.withOpacity(0.7) : AppTheme.darkGrey,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          alignLabelWithHint: true,
          isCollapsed: false,
          isDense: true,
          hintStyle: TextStyle(
              fontSize: fontSizeHintStyle,
              fontWeight: fontWeightHintText,
              color: theme == Brightness.dark ? AppTheme.whiteText.withOpacity(0.7) : AppTheme.darkGrey.withOpacity(0.7)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeigth),
          border: OutlineInputBorder(
              borderSide: enabledBorder ? BorderSide(width: borderWith!, color: AppTheme.lightGrey) : BorderSide.none,
              borderRadius: BorderRadius.circular(borderRadius)),
          enabledBorder: OutlineInputBorder(
              borderSide: enabledBorder ? BorderSide(width: borderWith!, color: AppTheme.transparent) : BorderSide.none,
              borderRadius: BorderRadius.circular(borderRadius)),
          focusedBorder: OutlineInputBorder(
              borderSide: enabledBorder ? BorderSide(width: borderWith!, color: AppTheme.darkBlue) : BorderSide.none,
              borderRadius: BorderRadius.circular(borderRadius)),
          errorBorder: OutlineInputBorder(
              borderSide: enabledBorder ? BorderSide(width: borderWith!, color: AppTheme.actionError) : BorderSide.none,
              borderRadius: BorderRadius.circular(borderRadius)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: enabledBorder ? BorderSide(width: borderWith!, color: AppTheme.actionError) : BorderSide.none,
              borderRadius: BorderRadius.circular(borderRadius)),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(borderRadius))),
    );
  }
}
