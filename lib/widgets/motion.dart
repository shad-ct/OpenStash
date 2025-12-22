import 'package:flutter/material.dart';

sealed class Motion {
  static Widget fadeSlide({required Widget child, required Animation<double> animation}) {
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final slide = Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }

  static Route<T> pageRoute<T>(WidgetBuilder builder) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Motion.fadeSlide(child: child, animation: animation);
      },
    );
  }
}
