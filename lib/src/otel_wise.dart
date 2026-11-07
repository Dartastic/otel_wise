// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_wise_suppression.dart';

class WiseResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class WiseCallResult<T> {
  /// Creates a call result.
  const WiseCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final WiseResult? result;
}

Future<T> tracedWise<T>({
  required String operation,
  required Future<WiseCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (wiseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_wise');
  final span = t.startSpan('wise $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'wise')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.profileId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('wise.profile.id', res.profileId!)]));
      }
      if (res.quoteId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('wise.quote.id', res.quoteId!)]));
      }
      if (res.transferId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('wise.transfer.id', res.transferId!)]));
      }
      if (res.recipientId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('wise.recipient.id', res.recipientId!)]));
      }
      if (res.sourceCurrency != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('wise.source.currency', res.sourceCurrency!)
        ]));
      }
      if (res.targetCurrency != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('wise.target.currency', res.targetCurrency!)
        ]));
      }
      if (res.sourceAmount != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeDouble('wise.source.amount', res.sourceAmount!)
        ]));
      }
      if (res.targetAmount != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeDouble('wise.target.amount', res.targetAmount!)
        ]));
      }
      if (res.rate != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('wise.rate', res.rate!)]));
      }
      if (res.status != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('wise.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('wise.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'wise.error',
          )
        ]));
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
