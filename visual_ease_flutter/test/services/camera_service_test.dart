import 'package:flutter_test/flutter_test.dart';
import 'package:visual_ease_flutter/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CameraServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
