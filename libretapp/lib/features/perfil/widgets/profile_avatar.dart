/// features \u203a perfil \u203a widgets \u203a profile_avatar \u2014 avatar widget for the user profile.
library;

import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 50, color: Colors.green),
    );
  }
}
