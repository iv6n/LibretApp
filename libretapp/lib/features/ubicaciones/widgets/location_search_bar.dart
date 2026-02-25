import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_search_bar.dart';

class LocationSearchBar extends StatelessWidget {
  const LocationSearchBar({
    required this.controller,
    required this.onChanged,
    this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      hintText: 'Buscar por nombre',
    );
  }
}
