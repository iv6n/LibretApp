import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/app_search_bar.dart';

class LocationSearchBar extends StatelessWidget {
  const LocationSearchBar({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      controller: controller,
      onChanged: onChanged,
      hintText: 'Buscar por nombre',
    );
  }
}
