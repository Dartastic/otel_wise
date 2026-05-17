# otel_wise

Dartastic OpenTelemetry bridge for Wise (international transfers + multi-currency).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_wise/otel_wise.dart';

await tracedWise<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return WiseCallResult(value: r, result: WiseResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutWiseInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
