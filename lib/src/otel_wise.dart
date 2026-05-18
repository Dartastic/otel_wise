// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_wise_suppression.dart';

class WiseResult {
  const WiseResult({
    this.profileId,
    this.quoteId,
    this.transferId,
    this.recipientId,
    this.sourceCurrency,
    this.targetCurrency,
    this.sourceAmount,
    this.targetAmount,
    this.rate,
    this.status,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? profileId;
  final String? quoteId;
  final String? transferId;
  final String? recipientId;
  final String? sourceCurrency;
  final String? targetCurrency;
  final double? sourceAmount;
  final double? targetAmount;
  final double? rate;
  final String? status;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class WiseCallResult<T> {
  const WiseCallResult({required this.value, this.result});
  final T value;
  final WiseResult? result;
}

Future<T> tracedWise<T>({
  required String operation,
  required Future<WiseCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (wiseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_wise');
  final span = t.startSpan('wise $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'wise');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.profileId != null) {
        span.setStringAttribute('wise.profile.id', res.profileId!);
      }
      if (res.quoteId != null) {
        span.setStringAttribute('wise.quote.id', res.quoteId!);
      }
      if (res.transferId != null) {
        span.setStringAttribute('wise.transfer.id', res.transferId!);
      }
      if (res.recipientId != null) {
        span.setStringAttribute('wise.recipient.id', res.recipientId!);
      }
      if (res.sourceCurrency != null) {
        span.setStringAttribute('wise.source.currency', res.sourceCurrency!);
      }
      if (res.targetCurrency != null) {
        span.setStringAttribute('wise.target.currency', res.targetCurrency!);
      }
      if (res.sourceAmount != null) {
        span.setDoubleAttribute('wise.source.amount', res.sourceAmount!);
      }
      if (res.targetAmount != null) {
        span.setDoubleAttribute('wise.target.amount', res.targetAmount!);
      }
      if (res.rate != null) {
        span.setDoubleAttribute('wise.rate', res.rate!);
      }
      if (res.status != null) {
        span.setStringAttribute('wise.status', res.status!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('wise.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'wise.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
