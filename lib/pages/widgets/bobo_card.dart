import 'package:flutter/material.dart';

import '../../theme/bobo_tokens.dart';

/// White rounded card with the soft Bobobidou shadow. The one container
/// used to group content on the peach background.
class BoboCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  const BoboCard({
    required this.child,
    this.padding = const EdgeInsets.all(BoboSpace.lg),
    this.color = BoboColors.creme,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BoboRadius.lgAll,
        boxShadow: BoboShadows.soft,
      ),
      child: Material(
        color: color,
        borderRadius: BoboRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
