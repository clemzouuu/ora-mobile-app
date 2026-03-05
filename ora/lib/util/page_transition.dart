import 'package:flutter/material.dart';

class FadeSlideRoute extends PageRouteBuilder {
  final Widget page;

  FadeSlideRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(0.0, 0.15);
            const end = Offset.zero;
            const curve = Curves.ease;

            var slideAnimation = Tween(
              begin: begin,
              end: end,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            ));

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 700),
        );
}