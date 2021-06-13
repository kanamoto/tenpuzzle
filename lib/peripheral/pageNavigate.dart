import 'package:flutter/material.dart';

class PageNavigate {

  static const Offset LEFT_TO_RIGHT = Offset(-1.0 , 0.0);
  static const Offset RIGHT_TO_LEFT = Offset( 1.0 , 0.0);

  ///
  /// https://flutter.dev/docs/cookbook/animation/page-route-animation
  ///
  static Route createRoute(final Offset begin, final Widget targetPage) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => targetPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}