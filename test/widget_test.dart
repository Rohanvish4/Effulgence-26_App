// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:effulgence26_mobile_app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('App smoke test - MyApp class exists', () {
    // Verify that the MyApp class can be instantiated
    const app = MyApp();
    expect(app, isNotNull);
    expect(app, isA<MyApp>());
  });
}
