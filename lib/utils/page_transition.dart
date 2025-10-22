import 'package:flutter/material.dart';

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final bool reverse;

  SlidePageRoute({required this.page, this.reverse = false})
      : super(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const beginRight = Offset(1.0, 0.0);
            const beginLeft = Offset(-1.0, 0.0);
            const end = Offset.zero;
            var tween = Tween(
              begin: reverse ? beginLeft : beginRight,
              end: end,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}
