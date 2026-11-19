import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_directory_layout.dart';
import 'package:libretapp/features/directorio/animales/widgets/animal_palette.dart';

/// The same visual hierarchy for livestock and companions in mixed lists.
class AnimalDirectoryHeader extends StatelessWidget {
  const AnimalDirectoryHeader({
    super.key,
    required this.avatar,
    required this.title,
    this.name,
    this.age,
    required this.stage,
    required this.stageColor,
    this.chips,
    this.stageIcon,
    this.titleFontSize,
    this.nameFontSize,
    this.menu,
    this.selected,
  });

  final Widget avatar;
  final String title;
  final String? name;
  final String? age;
  final String stage;
  final Color stageColor;
  final Widget? chips;
  final IconData? stageIcon;
  final double? titleFontSize;
  final double? nameFontSize;
  final Widget? menu;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = AppDirectoryMetrics.of(context);
    final primary = AnimalPalette.cardTextPrimary(context);
    final secondary = AnimalPalette.cardTextSecondary(context);
    final largeText = MediaQuery.textScalerOf(context).scale(12) >= 18;
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontSize: titleFontSize ?? metrics.identityTitleFontSize,
      fontWeight: FontWeight.w800,
      height: 1.05,
      color: primary,
    );
    final nameStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: nameFontSize ?? metrics.identityNameFontSize,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: primary,
    );
    final ageStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: metrics.ageFontSize,
      fontWeight: FontWeight.w600,
      color: secondary,
    );
    final stageLabelStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: math.max(10, metrics.stageFontSize - 2),
      fontWeight: FontWeight.w800,
      color: primary,
    );
    final stageText = stage.toUpperCase();
    return Container(
      width: double.infinity,
      color: AnimalPalette.cardHeader(context),
      padding: EdgeInsets.fromLTRB(
        metrics.headerPaddingH,
        math.max(2, metrics.headerPaddingV - 3),
        6,
        math.max(2, metrics.headerPaddingV - 3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatar,
          SizedBox(width: metrics.headerGap * 0.65),
          Container(
            width: 1.5,
            height: metrics.profileAvatarSize,
            color: AnimalPalette.cardDivider(context),
          ),
          SizedBox(width: metrics.headerGap * 0.65),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stageMaxWidth = math.min(
                  metrics.stagePillMaxWidth,
                  math.max(48.0, constraints.maxWidth - 104),
                );
                final stagePill = Container(
                  constraints: BoxConstraints(maxWidth: stageMaxWidth),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: stageColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (stageIcon != null) ...[
                        Icon(stageIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          stageText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: stageLabelStyle?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
                final actions = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    stagePill,
                    if (selected != null)
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: Icon(
                            selected!
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: selected! ? stageColor : secondary,
                          ),
                        ),
                      )
                    else
                      ?menu,
                  ],
                );
                final actionWidth =
                    math.min(
                      _textWidth(context, stageText, stageLabelStyle) +
                          16 +
                          (stageIcon == null ? 0 : 18),
                      stageMaxWidth,
                    ) +
                    (selected != null
                        ? 40
                        : menu != null
                        ? 32
                        : 0);
                const actionGap = 2.0;
                final titleWidth = math.max(
                  0.0,
                  constraints.maxWidth - actionWidth - actionGap,
                );
                final measuredTitle = _textWidth(context, title, titleStyle);
                final fittedTitleStyle =
                    name != null &&
                        measuredTitle > titleWidth &&
                        titleWidth >= 90
                    ? titleStyle?.copyWith(
                        fontSize:
                            ((titleStyle.fontSize ?? 18) *
                                    titleWidth /
                                    measuredTitle)
                                .clamp(14.0, titleStyle.fontSize ?? 18),
                      )
                    : titleStyle;
                final petAgeFits =
                    age == null ||
                    measuredTitle + _textWidth(context, age!, ageStyle) + 17 <=
                        titleWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: name == null && petAgeFits
                              ? _NameAndAge(
                                  name: title,
                                  age: age,
                                  nameStyle: titleStyle,
                                  ageStyle: ageStyle,
                                  largeText: largeText,
                                )
                              : Text(
                                  title,
                                  style: fittedTitleStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        const SizedBox(width: actionGap),
                        actions,
                      ],
                    ),
                    if (name == null && !petAgeFits)
                      Text(age!, style: ageStyle),
                    if (name != null) ...[
                      _NameAndAge(
                        name: name!,
                        age: age,
                        nameStyle: nameStyle,
                        ageStyle: ageStyle,
                        largeText: largeText,
                      ),
                    ],
                    if (chips != null) ...[
                      SizedBox(
                        height: math.max(0, metrics.headerSectionGap - 1),
                      ),
                      chips!,
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NameAndAge extends StatelessWidget {
  const _NameAndAge({
    required this.name,
    required this.age,
    required this.nameStyle,
    required this.ageStyle,
    required this.largeText,
  });
  final String name;
  final String? age;
  final TextStyle? nameStyle;
  final TextStyle? ageStyle;
  final bool largeText;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // The age is short and stays whole whenever possible; the name yields the
      // leftover space and elides first.
      final nameIntrinsic = _textWidth(context, name, nameStyle);
      final ageMaxWidth = constraints.maxWidth.isFinite
          ? math.max(
              constraints.maxWidth - 17 - math.min(nameIntrinsic, 56),
              0.0,
            )
          : double.infinity;
      final ageNeedsWrap =
          age != null && _textWidth(context, age!, ageStyle) > ageMaxWidth;
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              name,
              style: nameStyle,
              maxLines: largeText ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (age != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 16,
              color: AnimalPalette.cardDivider(context),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ageMaxWidth),
              child: Text(
                age!,
                style: ageStyle,
                maxLines: largeText || ageNeedsWrap ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                softWrap: largeText || ageNeedsWrap,
              ),
            ),
          ],
        ],
      );
    },
  );
}

double _textWidth(BuildContext context, String text, TextStyle? style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  return painter.width;
}
