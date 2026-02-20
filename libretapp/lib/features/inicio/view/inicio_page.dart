import 'package:flutter/material.dart';
import 'package:libretapp/features/inicio/view/inicio_view.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio'), elevation: 0),
      body: const InicioView(),
    );
  }
}
