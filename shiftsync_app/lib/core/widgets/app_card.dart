import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// AppCard — Base floating card container inspired by our minimalist clean design.
/// Supports directional [accentColor] that renders on the right in RTL (Arabic) or left in LTR.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? accentColor;
  final double? accentWidth;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.accentColor,
    this.accentWidth = 4.5,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: child,
    );

    // Adapt accent bar direction based on RTL vs LTR
    if (accentColor != null) {
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      content = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isRtl) _buildAccentBar(isRtl: false),
            if (isRtl) _buildAccentBar(isRtl: true),
            Expanded(child: content),
            if (!isRtl) const SizedBox.shrink(),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: context.isDarkMode
            ? Border.all(color: const Color(0xFF334155), width: 1)
            : null,
        boxShadow: context.isDarkMode ? [] : AppShadows.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                child: content,
              )
            : content,
      ),
    );
  }

  Widget _buildAccentBar({required bool isRtl}) {
    return Container(
      width: accentWidth,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: isRtl
            ? const BorderRadius.only(
                topRight: Radius.circular(AppRadius.lg),
                bottomRight: Radius.circular(AppRadius.lg),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(AppRadius.lg),
              ),
      ),
    );
  }
}
