import 'package:flutter/widgets.dart';

extension ResponsiveExtension on BuildContext {
  Size get size => MediaQuery.sizeOf(this);

  double get width => size.width;

  double get height => size.height;

  double wp(double percent) => width * percent / 100;

  double hp(double percent) => height * percent / 100;

  double sp(double size) {
    final scale = width / 390;
    return size * scale.clamp(0.85, 1.25);
  }
}
