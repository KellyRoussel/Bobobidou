import 'package:flutter/material.dart';

import '../../theme/bobo_tokens.dart';

/// The Bobobidou logo, cropped in a circle on its peach background.
class BoboLogo extends StatelessWidget {
  final double size;

  const BoboLogo({this.size = 48, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: BoboColors.pecheSplash,
        boxShadow: BoboShadows.soft,
      ),
      clipBehavior: Clip.antiAlias,
      // The mark sits in the middle of the square picture: zoom on it.
      child: Transform.scale(
        scale: 1.35,
        child: Image.asset('assets/icon/logo.jpg', fit: BoxFit.cover),
      ),
    );
  }
}
