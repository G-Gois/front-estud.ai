import 'package:flutter/material.dart';

class HomeRegisterCardAnimationWidget extends StatelessWidget {
  const HomeRegisterCardAnimationWidget({super.key, required this.child, required this.shouldHide});

  final Widget child;
  final bool shouldHide;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
        );
        return SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      child: !shouldHide ? child : const SizedBox.shrink(),
    );
  }
}
