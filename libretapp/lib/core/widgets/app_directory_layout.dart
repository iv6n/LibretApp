/// Shared layout primitives for the Directory's category lists.
library;

import 'package:flutter/material.dart';

/// Standard horizontal filter strip used by Directory sections.
class AppDirectoryFilterRow extends StatelessWidget {
  const AppDirectoryFilterRow({
    super.key,
    required this.children,
    this.trailing,
    this.compact = false,
  });

  final List<Widget> children;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final rowHeight = ((compact ? 44 : 52) + ((textScale - 1).clamp(0, 3) * 16))
        .toDouble();
    final filters = ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) => children[index],
    );

    return SizedBox(
      height: rowHeight,
      child: trailing == null
          ? filters
          : Row(
              children: [
                Expanded(child: filters),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: trailing,
                ),
              ],
            ),
    );
  }
}

/// Centers an empty-state card in the area left below a section's filters.
class AppDirectoryEmptySlot extends StatelessWidget {
  const AppDirectoryEmptySlot({
    super.key,
    required this.child,
    this.bottomPadding = 0,
  });

  final Widget child;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// Width-derived spacing tokens shared by Directory record cards.
///
/// Typography keeps following the user's [TextScaler] (accessibility); these
/// tokens only size the card chrome (avatar, paddings, gaps) so the same card
/// keeps its proportions from a 360dp phone up to the 720dp column.
@immutable
class AppDirectoryMetrics {
  const AppDirectoryMetrics._(this.progress);

  factory AppDirectoryMetrics.forCardWidth(double cardWidth) =>
      AppDirectoryMetrics._(
        ((cardWidth - minCardWidth) / (maxCardWidth - minCardWidth)).clamp(
          0.0,
          1.0,
        ),
      );

  /// Content width inside an [AppDirectoryCardFrame] on a 360dp phone.
  static const double minCardWidth = 328;

  /// Content width inside an [AppDirectoryCardFrame] at its widest.
  static const double maxCardWidth = 688;

  /// Minimum interactive target; never shrinks with the layout.
  static const double minTapTarget = 48;

  /// 0 at [minCardWidth], 1 at [maxCardWidth].
  final double progress;

  /// Metrics for the card currently being laid out on screen.
  ///
  /// Resolved from the window width instead of a local [LayoutBuilder] so the
  /// same tokens reach the avatar, the header and the footer without the
  /// paddings feeding back into their own calculation.
  static AppDirectoryMetrics of(BuildContext context) =>
      AppDirectoryMetrics.forCardWidth(MediaQuery.sizeOf(context).width - 32);

  double _lerp(double from, double to) => from + (to - from) * progress;

  double get avatarSize => _lerp(56, 68);

  /// Portrait size for the full animal and pet cards.
  double get profileAvatarSize => _lerp(68, 76);
  double get avatarRadius => _lerp(10, 12);
  double get avatarBorderWidth => _lerp(1.5, 1.8);
  double get avatarPadding => _lerp(4, 5);
  double get avatarInnerRadius =>
      avatarRadius - avatarBorderWidth - avatarPadding;
  double get avatarIconSize => _lerp(30, 38);

  /// Identity type and secondary name sizes follow the directory card width.
  double get identityTitleFontSize => _lerp(18, 24);
  double get identityNameFontSize => _lerp(16, 21);
  double get petNameFontSize => _lerp(21, 29);
  double get stageFontSize => _lerp(11, 14);

  /// Gap between the avatar and the identity column.
  double get headerGap => _lerp(10, 12);
  double get headerPaddingH => _lerp(10, 14);
  double get headerPaddingV => _lerp(6, 9);
  double get headerSectionGap => _lerp(2, 4);
  double get actionsGap => _lerp(6, 8);

  /// Tight gap between the primary identity line and the name/age line.
  double get nameGap => _lerp(1, 2);

  /// Left inset that keeps the identity chips aligned with the avatar's text.
  double get chipsIndent => avatarSize + (headerGap * 1.3) + 1.5;

  double get stagePillMaxWidth => _lerp(128, 160);

  /// Companion age line; slightly smaller on phones so a two-word age such as
  /// `5 años 4 meses` never has to elide next to the name.
  double get ageFontSize => _lerp(12, 14);

  double get footerPaddingH => _lerp(12, 16);
  double get footerIconSize => _lerp(22, 26);

  /// Horizontal padding of a footer fact chip. Denser on phones so a card can
  /// keep its facts on a single line.
  double get footerChipPaddingH => _lerp(6, 9);

  // ── Secondary record cards (lotes, cultivos, ubicaciones) ──────────────
  // They share the Directory frame and the animal card's rhythm, but use a
  // compact glyph badge instead of the animal avatar.
  double get cardPaddingH => _lerp(14, 18);
  double get cardPaddingV => _lerp(14, 16);

  /// Diameter of the compact glyph badge.
  double get cardBadgeSize => _lerp(44, 52);
  double get cardBadgeIconSize => _lerp(22, 26);

  /// Gap between the header badge and the identity column.
  double get cardGap => _lerp(12, 14);

  /// Spacing between inline chips on a cards' fact rows.
  double get cardChipGap => _lerp(7, 8);

  /// Leading icon of an inline information row or chip.
  double get cardInlineIconSize => _lerp(17, 19);

  /// `CircleAvatar.radius` that matches [avatarSize]; used by cards that render
  /// their leading glyph without the animal card's frame.
  double get leadingAvatarRadius => avatarSize / 2;

  /// Slightly tighter leading avatar for nested location cards.
  double get compactAvatarRadius => avatarSize * 0.43;
}

/// Consistent width, outer spacing, and shape for Directory record cards.
class AppDirectoryCardFrame extends StatelessWidget {
  const AppDirectoryCardFrame({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.elevation = 1.2,
    this.margin = const EdgeInsets.only(bottom: 14),
    this.frameOnly = false,
  });

  static const double maxWidth = 720;
  static const double cornerRadius = 20;

  final Widget child;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final bool frameOnly;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            margin.resolve(Directionality.of(context)).bottom,
          ),
          child: frameOnly
              ? child
              : Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  color: color,
                  elevation: elevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cornerRadius),
                    side: BorderSide(
                      color:
                          borderColor ??
                          Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: .4),
                      width: borderWidth,
                    ),
                  ),
                  child: child,
                ),
        ),
      ),
    );
  }
}
