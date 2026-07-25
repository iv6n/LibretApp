import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/app/widgets/shell_chrome.dart';
import 'package:libretapp/app/widgets/shell_fab.dart';

void main() {
  testWidgets('shell scopes keep the branch that originated their updates', (
    tester,
  ) async {
    final hostKey = GlobalKey<_RecordingShellHostState>();
    final firstConfig = _fabConfig('first');
    final secondConfig = _fabConfig('second');

    await tester.pumpWidget(
      _testApp(
        key: hostKey,
        activeBranchIndex: 0,
        config: firstConfig,
        chromeVisible: true,
      ),
    );
    await tester.pump();

    hostKey.currentState!.clearEvents();
    await tester.pumpWidget(
      _testApp(
        key: hostKey,
        activeBranchIndex: 1,
        config: secondConfig,
        chromeVisible: false,
      ),
    );
    await tester.pump();

    expect(hostKey.currentState!.fabUpdates, <int>[0]);
    expect(hostKey.currentState!.chromeUpdates, <int>[0]);

    hostKey.currentState!.clearEvents();
    await tester.pumpWidget(
      _testApp(
        key: hostKey,
        activeBranchIndex: 1,
        showScopes: false,
      ),
    );
    await tester.pump();

    expect(hostKey.currentState!.fabRemovals, <int>[0]);
    expect(hostKey.currentState!.chromeRemovals, <int>[0]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending shell callbacks are harmless when the tree deactivates', (
    tester,
  ) async {
    final hostKey = GlobalKey<_RecordingShellHostState>();

    await tester.pumpWidget(
      _testApp(
        key: hostKey,
        activeBranchIndex: 0,
        config: _fabConfig('first'),
        chromeVisible: true,
      ),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

Widget _testApp({
  required GlobalKey<_RecordingShellHostState> key,
  required int activeBranchIndex,
  bool showScopes = true,
  ShellFabConfig? config,
  bool chromeVisible = true,
}) {
  return MaterialApp(
    home: _RecordingShellHost(
      key: key,
      activeBranchIndex: activeBranchIndex,
      showScopes: showScopes,
      config: config,
      chromeVisible: chromeVisible,
    ),
  );
}

ShellFabConfig _fabConfig(String id) {
  return ShellFabConfig(
    id: id,
    label: id,
    icon: Icons.add,
    onPressed: _doNothing,
  );
}

void _doNothing() {}

class _RecordingShellHost extends StatefulWidget {
  const _RecordingShellHost({
    required this.activeBranchIndex,
    required this.showScopes,
    required this.config,
    required this.chromeVisible,
    super.key,
  });

  final int activeBranchIndex;
  final bool showScopes;
  final ShellFabConfig? config;
  final bool chromeVisible;

  @override
  State<_RecordingShellHost> createState() => _RecordingShellHostState();
}

class _RecordingShellHostState extends State<_RecordingShellHost>
    implements
        ShellFabHostState<_RecordingShellHost>,
        ShellChromeHostState<_RecordingShellHost> {
  final fabUpdates = <int>[];
  final fabRemovals = <int>[];
  final chromeUpdates = <int>[];
  final chromeRemovals = <int>[];

  @override
  int get activeBranchIndex => widget.activeBranchIndex;

  void clearEvents() {
    fabUpdates.clear();
    fabRemovals.clear();
    chromeUpdates.clear();
    chromeRemovals.clear();
  }

  @override
  void updateFab(ShellFabConfig? config, {required int branchIndex}) {
    fabUpdates.add(branchIndex);
  }

  @override
  void removeFab(ShellFabConfig? config, {required int branchIndex}) {
    fabRemovals.add(branchIndex);
  }

  @override
  void updateChromeVisibility(bool visible, {required int branchIndex}) {
    chromeUpdates.add(branchIndex);
  }

  @override
  void removeChromeVisibility(bool visible, {required int branchIndex}) {
    chromeRemovals.add(branchIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showScopes) return const SizedBox.shrink();
    return ShellFabConfigScope(
      config: widget.config,
      child: ShellChromeScope(
        visible: widget.chromeVisible,
        child: const SizedBox.shrink(),
      ),
    );
  }
}
