import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile/app/router.dart';

void main() {
  test('AppRouter returns MaterialPageRoute for /', () {
    final route = AppRouter.generateRoute(const RouteSettings(name: '/'));
    expect(route, isA<MaterialPageRoute>());
  });
}
