import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/app_directory_filter_chip.dart';
import 'package:libretapp/core/widgets/app_directory_layout.dart';

void main() {
  testWidgets('filter row is compact and keeps a 48 dp chip touch target', (
    tester,
  ) async {
    var selected = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppDirectoryFilterRow(
            children: [
              AppDirectoryFilterChip(
                label: 'Todos',
                count: 0,
                selected: true,
                onTap: () => selected = true,
              ),
              AppDirectoryFilterChip(
                label: 'Activos',
                selected: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppDirectoryFilterRow)).height, 52);
    expect(
      tester.getSize(find.byType(AppDirectoryFilterChip).first).height,
      greaterThanOrEqualTo(48),
    );

    await tester.tap(find.text('Todos'));
    expect(selected, isTrue);
  });

  testWidgets('filter row grows when text is enlarged', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: AppDirectoryFilterRow(
            children: [
              AppDirectoryFilterChip(
                label: 'Mascota',
                selected: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(AppDirectoryFilterRow)).height,
      greaterThan(52),
    );
    expect(
      tester.getSize(find.byType(AppDirectoryFilterChip)).height,
      greaterThanOrEqualTo(48),
    );
  });

  testWidgets('card frame centers cards and applies the shared shape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppDirectoryCardFrame(child: SizedBox(height: 80)),
        ),
      ),
    );

    final card = tester.widget<Card>(find.byType(Card));
    final shape = card.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(20));
    expect(card.margin, EdgeInsets.zero);
    expect(tester.getSize(find.byType(Card)).width, lessThanOrEqualTo(688));
    expect(tester.getTopLeft(find.byType(Card)).dx, greaterThanOrEqualTo(156));
  });

  testWidgets('empty slot centers content and reserves bottom clearance', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: AppDirectoryEmptySlot(
              bottomPadding: 20,
              child: SizedBox(height: 100),
            ),
          ),
        ),
      ),
    );

    final top = tester.getTopLeft(find.byType(SizedBox).last).dy;
    expect(top, closeTo(146, 2));
  });

  group('AppDirectoryMetrics', () {
    test('scales every card token from the phone to the widest column', () {
      final phone = AppDirectoryMetrics.forCardWidth(
        AppDirectoryMetrics.minCardWidth,
      );
      final wide = AppDirectoryMetrics.forCardWidth(
        AppDirectoryMetrics.maxCardWidth,
      );

      expect(phone.progress, 0);
      expect(wide.progress, 1);
      expect(phone.avatarSize, 56);
      expect(wide.avatarSize, 68);
      expect(phone.cardPaddingH, 14);
      expect(wide.cardPaddingH, 18);
      expect(wide.cardPaddingV, greaterThan(phone.cardPaddingV));
      expect(wide.cardBadgeSize, greaterThan(phone.cardBadgeSize));
      expect(wide.cardGap, greaterThan(phone.cardGap));
      expect(wide.cardChipGap, greaterThan(phone.cardChipGap));
      expect(wide.cardInlineIconSize, greaterThan(phone.cardInlineIconSize));
      expect(phone.leadingAvatarRadius, 28);
      expect(wide.leadingAvatarRadius, 34);
      expect(wide.compactAvatarRadius, lessThan(wide.leadingAvatarRadius));
    });

    test('clamps the progress outside the supported widths', () {
      expect(AppDirectoryMetrics.forCardWidth(240).progress, 0);
      expect(AppDirectoryMetrics.forCardWidth(1200).progress, 1);
    });

    test('chipsIndent keeps secondary content aligned with the avatar', () {
      final metrics = AppDirectoryMetrics.forCardWidth(520);
      expect(metrics.chipsIndent, metrics.avatarSize + metrics.headerGap);
    });
  });
}
