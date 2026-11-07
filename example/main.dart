// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_wise/otel_wise.dart';

/// Traces Wise calls with OpenTelemetry.
///
/// `otel_wise` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Wise call in
/// [tracedWise]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'wise-example');

  // Traces a Wise call.
  final wiseId = await tracedWise<String>(
    operation: 'create',
    invoke: () async {
      // Make the Wise call here, then report what it returned.
      const id = 'wise_8f3a2c';
      return const WiseCallResult(
          value: id,
          result: WiseResult(
              profileId: 'profile_8f3a2c',
              quoteId: 'quote_8f3a2c',
              transferId: 'transfer_8f3a2c',
              recipientId: 'recipient_8f3a2c',
              sourceCurrency: 'usd',
              targetCurrency: 'usd',
              sourceAmount: 0.5,
              targetAmount: 0.5,
              rate: 0.5,
              status: 'succeeded',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedWise create returned $wiseId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutWiseInstrumentationAsync.
  await runWithoutWiseInstrumentationAsync(
    () => tracedWise<String>(
      operation: 'create',
      invoke: () async {
        const id = 'wise_8f3a2c';
        return const WiseCallResult(
            value: id,
            result: WiseResult(
                profileId: 'profile_8f3a2c',
                quoteId: 'quote_8f3a2c',
                transferId: 'transfer_8f3a2c',
                recipientId: 'recipient_8f3a2c',
                sourceCurrency: 'usd',
                targetCurrency: 'usd',
                sourceAmount: 0.5,
                targetAmount: 0.5,
                rate: 0.5,
                status: 'succeeded',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
