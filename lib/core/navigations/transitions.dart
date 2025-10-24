import 'package:flutter/material.dart';

Route slideFadeRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 280),
    reverseTransitionDuration: Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnim = Tween<Offset>(
        begin: Offset(0.1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.ease)).animate(animation);

      final fadeAnim = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      return FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(position: offsetAnim, child: child),
      );
    },
  );
}

Route enterExitRoute(Widget exitPage, Widget enterPage) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 280),
    reverseTransitionDuration: Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) => enterPage,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return Stack(
        children: <Widget>[
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.0),
              end: const Offset(-1.0, 0.0),
            ).animate(animation),
            child: exitPage,
          ),
          SlideTransition(
            position: new Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: enterPage,
          ),
        ],
      );
    },
  );
}
