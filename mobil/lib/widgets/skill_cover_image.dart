import 'package:flutter/material.dart';

import '../api/skills_api.dart';

/// Önce `GET /api/skills/{id}/cover` proxy; hata olursa API’deki [fallbackUrl].
class SkillCoverImage extends StatelessWidget {
  const SkillCoverImage({
    super.key,
    required this.skillId,
    this.fallbackUrl,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  final String skillId;
  final String? fallbackUrl;
  final BoxFit fit;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = skillCoverProxyUrl(skillId);
    final fb = fallbackUrl?.trim();
    final placeholder = errorWidget ??
        ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
        );
    return Image.network(
      primary,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (fb != null && fb.isNotEmpty && fb != primary) {
          return Image.network(
            fb,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => placeholder,
          );
        }
        return placeholder;
      },
    );
  }
}
