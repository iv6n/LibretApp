import 'package:flutter/material.dart';
import 'package:libretapp/theme/app_theme.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    required this.controller,
    required this.onChanged,
    this.focusNode,
    this.hintText = 'Buscar',
    this.label,
    this.onClear,
    this.onFilterTap,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final String hintText;
  final String? label;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final bool autofocus;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showClear = widget.controller.text.isNotEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              widget.label!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
              ),
            ),
          ),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onFilterTap != null)
                  IconButton(
                    tooltip: 'Filtrar',
                    icon: const Icon(Icons.tune),
                    onPressed: widget.onFilterTap,
                  ),
                if (showClear)
                  IconButton(
                    tooltip: 'Limpiar',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                      widget.onClear?.call();
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
