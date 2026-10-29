import 'package:flutter/material.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';

class WorkspaceDemoFrame extends StatefulWidget {
  const WorkspaceDemoFrame({
    super.key,
    required this.manager,
    required this.child,
  });
  final WorkspaceManager manager;
  final Widget child;
  @override
  State<WorkspaceDemoFrame> createState() => _WorkspaceDemoFrameState();
}

class _WorkspaceDemoFrameState extends State<WorkspaceDemoFrame> {
  bool _busy = false;
  String? _error;
  Future<void> _exit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.manager.exitDemo();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo salir. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Material(
        key: const ValueKey('workspace_demo_banner'),
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 40,
              key: const ValueKey('workspace_demo_banner_row'),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _error ?? 'Modo demo · Datos ficticios',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _exit,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Salir de la demo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: widget.child,
        ),
      ),
    ],
  );
}
