import 'package:flutter/material.dart';

double textContrast(Color foreground, Color background) {
  final fg = Color.alphaBlend(foreground, background).computeLuminance();
  final bg = background.computeLuminance();
  return (fg > bg ? fg + .05 : bg + .05) / (fg > bg ? bg + .05 : fg + .05);
}

Color readableTextColor(Color desired, Color background) {
  final base = Color.alphaBlend(desired, background);
  if (textContrast(base, background) >= 4.5) return base;
  final target = textContrast(Colors.white, background) > textContrast(Colors.black, background)
      ? Colors.white : Colors.black;
  for (var step = 1; step <= 20; step++) {
    final candidate = Color.lerp(base, target, step / 20)!;
    if (textContrast(candidate, background) >= 4.5) return candidate;
  }
  return target;
}
