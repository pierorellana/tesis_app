import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../env/theme/app_theme.dart';

class DropDownButtonWidget<T> extends StatefulWidget {
  const DropDownButtonWidget({
    super.key,
    this.items,
    this.onChanged,
    this.value,
    this.hint,
    this.validator,
    this.onSaved,
    this.hasError = false,
  });

  final List<DropdownMenuItem<T>>? items;
  final void Function(T?)? onChanged;
  final T? value;
  final String? hint;
  final String? Function(T?)? validator;
  final void Function(T?)? onSaved;
  final bool hasError;

  @override
  State<DropDownButtonWidget<T>> createState() =>
      _DropDownButtonWidgetState<T>();
}

class _DropDownButtonWidgetState<T> extends State<DropDownButtonWidget<T>> {
  List<double> customHeights = [40.0, 50.0, 30.0];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 45,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        DropdownButtonFormField2<T>(
          onSaved: widget.onSaved,
          isExpanded: true,
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintStyle: TextStyle(
              color: AppTheme.white,
              fontSize: 30,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: AppTheme.greyBlocked,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0.7,
                color: widget.hasError
                    ? AppTheme.actionError
                    : AppTheme.lightGrey,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0.7,
                color: widget.hasError
                    ? AppTheme.actionError
                    : AppTheme.transparent,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 0.7,
                color: widget.hasError
                    ? AppTheme.actionError
                    : AppTheme.lightGrey,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppTheme.actionError,
                width: 0.7,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: AppTheme.actionError,
                width: 0.7,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          hint: Text(
            widget.hint!,
            style: TextStyle(
              color: AppTheme.dark,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          items: widget.items?.map((item) {
            final child = item.child;
            return DropdownMenuItem<T>(
              value: item.value,
              child: IconTheme.merge(
                data: IconThemeData(color: AppTheme.white),
                child: (child is Text)
                    ? Text(
                        child.data ?? '',
                        style: (child.style ?? const TextStyle()).copyWith(
                          color: AppTheme.dark,
                        ),
                        maxLines: child.maxLines,
                        overflow: child.overflow,
                        textAlign: child.textAlign,
                      )
                    : DefaultTextStyle.merge(
                        style: TextStyle(color: AppTheme.white),
                        child: child,
                      ),
              ),
            );
          }).toList(),
          onChanged: widget.onChanged,
          value: widget.value,
          validator: widget.validator,
          buttonStyleData: ButtonStyleData(
            height: 18,
            overlayColor: MaterialStatePropertyAll(AppTheme.white),
            elevation: 0,
            padding: EdgeInsets.only(right: 8),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_outlined,
              color: AppTheme.dark,
            ),
            openMenuIcon: Icon(
              Icons.keyboard_arrow_up_outlined,
              color: AppTheme.dark,
            ),
            iconSize: 24,
          ),
          dropdownStyleData: DropdownStyleData(
            isOverButton: true,
            elevation: 3,
            maxHeight: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.greyBlocked,
            ),
            offset: const Offset(0, -48),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(10),
              thickness: MaterialStateProperty.all<double>(6),
              thumbVisibility: MaterialStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: 40,
            selectedMenuItemBuilder: (context, child) {
              return Container(
                height: 40,
                decoration: const BoxDecoration(color: AppTheme.black12),
                child: child,
              );
            },
            padding: const EdgeInsets.only(left: 14, right: 14),
          ),
        ),
      ],
    );
  }
}
