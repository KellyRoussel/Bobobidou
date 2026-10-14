import 'package:flutter/material.dart';

import '../../theme/bobo_tokens.dart';
import 'bobo_logo.dart';

/// Friendly placeholder shown when there is nothing to display yet.
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BoboSpace.xl,
        vertical: BoboSpace.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BoboLogo(size: 88),
          const SizedBox(height: BoboSpace.xl),
          Text(title, style: textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: BoboSpace.sm),
          Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: BoboSpace.xl),
            action!,
          ],
        ],
      ),
    );
  }
}
