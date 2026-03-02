import 'package:flutter/material.dart';

/// Wraps [child] in a minimal MaterialApp+Scaffold so widget tests have a
/// valid BuildContext with a real theme and MediaQuery.
Widget wrapWidget(Widget child, {Size surfaceSize = const Size(390, 844)}) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    ),
    home: MediaQuery(
      data: MediaQueryData(size: surfaceSize),
      child: Scaffold(body: child),
    ),
  );
}
