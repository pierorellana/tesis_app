import 'dart:math' as math;
import 'package:flutter/material.dart';

class Responsive {
  double _width = 0, _height = 0, _diagonal = 0;
  bool _isTablet = false;

  double get width => _width;
  double get height => _height;
  double get diagonal => _diagonal;

  bool get isTablet => _isTablet;

  static Responsive of(BuildContext context) => Responsive(context);

  Responsive(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _width = size.width;
    _height = size.height;
    _diagonal = math.sqrt(math.pow(_width, 2) + math.pow(_height, 2));
    _isTablet = size.shortestSide >= 600;
  }

  double wp(double percent) => _width * percent / 100;
  double hp(double percent) => _height * percent / 100;
  double dp(double percent) => _diagonal * percent / 100;
}

extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive.of(this);
}
