import 'package:flutter/material.dart';

class AnimalCard extends StatelessWidget {
  const AnimalCard({super.key, this.animal, this.location, this.onTap});
  final dynamic animal;
  final dynamic location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(animal?.toString() ?? 'Animal'),
        subtitle: Text(location?.toString() ?? 'Location'),
        onTap: onTap,
      ),
    );
  }
}
