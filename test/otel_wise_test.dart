// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_wise/otel_wise.dart';
import 'package:test/test.dart';

void main() {
  group('otel_wise', () {
    test('suppression toggles in zone', () async {
      expect(wiseInstrumentationSuppressed(), isFalse);
      await runWithoutWiseInstrumentationAsync(() async {
        expect(wiseInstrumentationSuppressed(), isTrue);
      });
      expect(wiseInstrumentationSuppressed(), isFalse);
    });

    test('WiseResult fields default null', () {
      const r = WiseResult();
      expect(r.statusCode, isNull);
    });
  });
}
