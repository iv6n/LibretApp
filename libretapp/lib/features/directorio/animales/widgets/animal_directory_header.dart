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
    required this.chips,
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
  final Widget chips;
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
      height: 1.1,
      color: primary,
    );
    final nameStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: nameFontSize ?? metrics.identityNameFontSize,
      fontWeight: FontWeight.w700,
      height: 1.15,
      color: primary,
    );
    final ageStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: metrics.ageFontSize,
      fontWeight: FontWeight.w600,
      color: secondary,
    );
    final stageLabelStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: metrics.stageFontSize,
      fontWeight: FontWeight.w800,
      color: primary,
    );
    final stageText = stage.toUpperCase();
    final stagePillWidth = math.min(
      _textWidth(context, stageText, stageLabelStyle) +
          24 +
          (stageIcon == null ? 0 : 22),
      metrics.stagePillMaxWidth,
    );
    final actionsWidth =
        stagePillWidth +
        (selected != null || menu != null
            ? metrics.actionsGap + AppDirectoryMetrics.minTapTarget
            : 0);
    final stagePill = Container(
      constraints: BoxConstraints(maxWidth: metrics.stagePillMaxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: stageColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stageIcon != null) ...[
            Icon(stageIcon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
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
            width: AppDirectoryMetrics.minTapTarget,
            height: AppDirectoryMetrics.minTapTarget,
            child: Center(
              child: Icon(
                selected! ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected! ? stageColor : secondary,
              ),
            ),
          )
        else
          ?menu,
      ],
    );
    return Container(
      width: double.infinity,
      color: AnimalPalette.cardHeader(context),
      padding: EdgeInsets.symmetric(
        horizontal: metrics.headerPaddingH,
        vertical: metrics.headerPaddingV,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The actions only share the primary line when that line still has
          // room for a usable title afterwards; otherwise they drop below.
          final ageWidth = age == null
              ? 0.0
              : _textWidth(context, age!, ageStyle) + 17;
          final titleBudget = math.min(
            _textWidth(context, title, titleStyle),
            115.0,
          );
          final identityWidth =
              constraints.maxWidth -
              metrics.profileAvatarSize -
              (metrics.headerGap * 1.3) -
              1.5;
          final stacked =
              largeText ||
              identityWidth < actionsWidth + titleBudget + metrics.actionsGap;
          final ageBelowForPet =
              name == null &&
              age != null &&
              !stacked &&
              identityWidth - actionsWidth - metrics.actionsGap <
                  _textWidth(context, title, titleStyle) + ageWidth;
          final Widget identity = name == null && !ageBelowForPet
              ? _NameAndAge(
                  name: title,
                  age: age,
                  nameStyle: titleStyle,
                  ageStyle: ageStyle,
                  largeText: largeText,
                )
              : Text(
                  title,
                  style: titleStyle,
                  maxLines: largeText ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                );
          final Widget? nameLine = name != null
              ? _NameAndAge(
                  name: name!,
                  age: age,
                  nameStyle: nameStyle,
                  ageStyle: ageStyle,
                  largeText: largeText,
                )
              : ageBelowForPet
              ? Text(age!, style: ageStyle)
              : null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The stage pill and the menu share the first identity
                        // line so they stay level with the primary text instead
                        // of floating against the middle of the whole block.
                        Row(
                          children: [
                            Expanded(child: identity),
                            if (!stacked) ...[
                              SizedBox(width: metrics.actionsGap),
                              actions,
                            ],
                          ],
                        ),
                        if (nameLine != null) ...[
                          SizedBox(height: metrics.nameGap),
                          nameLine,
                        ],
                        if (stacked)
                          Align(
                            alignment: Alignment.centerRight,
                            child: actions,
                          ),
                        SizedBox(height: metrics.headerSectionGap),
                        chips,
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
