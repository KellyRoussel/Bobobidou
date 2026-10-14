import 'package:flutter/material.dart';

import '../../theme/bobo_tokens.dart';

enum EntryKind { meal, pain }

/// Round icon that tells a meal from a pain episode: coral fork for meals,
/// plum bolt for pain. Used in the journal, the sheets and the analysis.
class EntryIcon extends StatelessWidget {
  final EntryKind kind;
  final double size;
  final bool filled;

  const EntryIcon(this.kind, {this.size = 40, this.filled = false, super.key});

  static IconData iconOf(EntryKind kind) =>
      kind == EntryKind.meal ? Icons.restaurant_rounded : Icons.bolt_rounded;

  static Color colorOf(EntryKind kind) =>
      kind == EntryKind.meal ? BoboColors.repas : BoboColors.douleur;

  static Color tintOf(EntryKind kind) =>
      kind == EntryKind.meal ? BoboColors.repasTendre : BoboColors.douleurTendre;

  @override
  Widget build(BuildContext context) {
    final color = colorOf(kind);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : tintOf(kind),
      ),
      child: Icon(
        iconOf(kind),
        size: size * 0.5,
        color: filled
            ? Colors.white
            : (kind == EntryKind.meal ? BoboColors.corailProfond : color),
      ),
    );
  }
}
