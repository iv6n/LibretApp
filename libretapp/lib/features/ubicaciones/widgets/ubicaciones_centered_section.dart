/// features › ubicaciones › widgets › ubicaciones_centered_section — max-width wrapper for list items.
library;

import 'package:flutter/material.dart';

class UbicacionesCenteredSection extends StatelessWidget {
  const UbicacionesCenteredSection({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SizedBox(
          width: double.infinity,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
