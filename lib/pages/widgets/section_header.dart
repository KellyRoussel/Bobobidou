import 'package:flutter/material.dart';

import '../../theme/bobo_tokens.dart';

/// Title above a group of content, with an optional action on the right.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader(this.title, {this.trailing, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: BoboSpace.xs, bottom: BoboSpace.md),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Large title at the top of a tab, with an optional subtitle and action.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  const PageHeader({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BoboSpace.page,
        BoboSpace.lg,
        BoboSpace.page,
        BoboSpace.xl,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: BoboSpace.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.headlineMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: BoboSpace.xs),
                  Text(subtitle!, style: textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
