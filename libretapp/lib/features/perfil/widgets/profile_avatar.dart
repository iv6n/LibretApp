/// features \u203a perfil \u203a widgets \u203a profile_avatar \u2014 avatar widget for the user profile.
library;

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({this.initials, super.key});

  final String? initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasInitials = initials != null && initials!.isNotEmpty;
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: hasInitials
          ? Text(
              initials!,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            )
          : Icon(
              Icons.person,
              size: 50,
              color: theme.colorScheme.onPrimaryContainer,
            ),
    );
  }
}
