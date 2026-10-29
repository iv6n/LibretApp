import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/shell_chrome.dart';

/// Opens a modal panel over the shell navigation dock.
///
/// The sheet's surface reaches the bottom edge, while its contents stay above
/// the system navigation area. A panel opened from a shell branch is promoted
/// to the root navigator so the dock cannot paint over it.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  bool isScrollControlled = false,
  bool useSafeArea = true,
  Color? backgroundColor,
  Color? barrierColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  RouteSettings? routeSettings,
}) {
  final navigationEnabled =
      ShellChromeVisibility.of(context)?.navigationEnabled ?? false;

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator || navigationEnabled,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    routeSettings: routeSettings,
    builder: (sheetContext) =>
        SafeArea(top: false, child: builder(sheetContext)),
  );
}
