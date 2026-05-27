/// features \u203a inicio \u203a view \u203a inicio_page \u2014 root page for the home dashboard.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:libretapp/features/inicio/view/inicio_view.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return const Scaffold(extendBodyBehindAppBar: true, body: InicioView());
  }
}
