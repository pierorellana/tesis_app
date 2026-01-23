import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightGrey = Color(0xffe3e3e3);
  static const Color darkBlue = Color(0xff084d87);
  static const Color darkGrey = Color(0XFF4A4A4A);
  static const Color deepNavyBlue = Color(0xff042744);
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteText = Color(0xFFDDDDDD);
  static const Color black = Color(0xFF000000);
  static const Color hinText = Color(0xff5B5B5B);
  static const Color actionError = Color(0xffCC0000);
  static const Color errorNotification = Color(0xffdc3545);
  static const Color dark = Color(0xff363636);
  static const Color actionSuccessLight = Color(0XFFBEFFBE);
  static const Color actionSuccess = Color(0XFF00B300);
  static const Color actionWarning = Color(0XFFFF5500);
  static const Color greenText = Color(0xFF0B9145);
  static const Color darkPrimaryColor = Color(0xFF17223b);
  // static const Color primaryColor = Color(0xFF04345C);
  static const Color primaryColor = Color(0xFF108A50);
  static const Color primaryLightColor = Color(0xFF256192);
  static const Color secondary2Color = Color(0xFFDADCE2);
  static const Color secondaryColor = Color(0xFFf8f4f4);
  static const Color mutedColor = Color(0xFF9E9E9E);
  static const Color mediumDarkGray = Color(0xff545454);
  static const Color transparent = Colors.transparent;
  static const Color black12 = Colors.black12;
  static const Color greyBlocked = Color(0xFFDCDBE5);

  // * ASSETS
  static const String logoApp = 'assets/logo_app.png';
  static const String icon404Path = "assets/404.svg";
  static const String iconErrorPath = "assets/error.svg";
  static const String iconCheckPath = "assets/check.svg";
  static const String iconCautionPath = "assets/caution.svg";
  static const String logoAppCargandoWhite = 'assets/logo_cargando_white.png';
  static const String loadingPath = 'assets/loading.gif';
  static const String loadingRemoveBgPath = 'assets/loading-removebg.gif';
  static const String notFoundImagePath = 'assets/not_found_image.jpg';
  static const String notFountImageUserPath = 'assets/image_user_not_found.png';

  static Widget logoAppImage({required EdgeInsetsGeometry padding}) {
    return Padding(
      padding: padding,
      child: Opacity(
        opacity: 0.85,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset(logoAppCargandoWhite, fit: BoxFit.cover),
        ),
      ),
    );
  }

  ThemeData theme() {
    return ThemeData(
      textSelectionTheme: const TextSelectionThemeData(
        selectionHandleColor: primaryColor,
        cursorColor: primaryColor,
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
    );
  }

  static ThemeData themeDialog() {
    return ThemeData(
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      timePickerTheme: TimePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      primaryColor: AppTheme.primaryColor,
      hoverColor: AppTheme.primaryColor,
      highlightColor: AppTheme.primaryColor,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppTheme.primaryColor,
        onPrimary: AppTheme.white,
        secondary: AppTheme.primaryColor,
        onSecondary: AppTheme.white,
        error: AppTheme.actionError,
        onError: AppTheme.actionError,
        surface: AppTheme.white,
        onSurface: AppTheme.dark,
      ),
    );
  }
}
