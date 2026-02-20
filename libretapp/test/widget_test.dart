// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:libretapp/main.dart';
import 'package:libretapp/app/app_bloc.dart';

void main() {
  testWidgets('LibretApp opens successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      BlocProvider(
        create: (context) => AppBloc()..add(const AppStarted()),
        child: const LibretApp(),
      ),
    );

    // Verify that app renders without error
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
