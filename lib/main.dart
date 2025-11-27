import 'package:flutter/material.dart';
import 'dart:async';
import 'app.dart';

void main() {
  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Catch async errors
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stackTrace) {
    debugPrint('Async Error: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}
