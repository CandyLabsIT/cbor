/*
 * Package : Cbor
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 12/12/2016
 * Copyright :  S.Hamblett
 */

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

import '../encoder/sink.dart';
import '../utils/info.dart';
import 'value.dart';

/// A CBOR array.
class CborList extends DelegatingList<CborValue>
    with CborValueMixin
    implements CborValue {
  const CborList([List<CborValue> items = const [], this.tags = const []])
      : super(items);

  @override
  final List<int> tags;

  @override
  void encode(EncodeSink sink) {
    if (length < 256) {
      CborEncodeDefiniteLengthList(this).encode(sink);
    } else {
      // Indefinite length
      CborEncodeIndefiniteLengthList(this).encode(sink);
    }
  }
}

/// Use this to force the [CborEncoder] to encode an indefinite length list.
///
/// This is never generated by decoder.
class CborEncodeIndefiniteLengthList implements CborValue {
  CborEncodeIndefiniteLengthList(this.inner);

  final CborList inner;

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    sink.addHeaderInfo(4, Info.indefiniteLength);

    sink.addToCycleCheck(inner);
    for (final x in inner) {
      x.encode(sink);
    }

    sink.removeFromCycleCheck(inner);

    (const Break()).encode(sink);
  }

  @override
  int? get expectedConversion => inner.expectedConversion;

  @override
  List<int> get tags => inner.tags;
}

/// Use this to force the [CborEncoder] to encode an definite length list.
///
/// This is never generated by decoder.
class CborEncodeDefiniteLengthList implements CborValue {
  const CborEncodeDefiniteLengthList(this.inner);

  final CborList inner;

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);

    sink.addHeaderInfo(4, Info.int(inner.length));

    sink.addToCycleCheck(inner);
    for (final x in inner) {
      x.encode(sink);
    }
    sink.removeFromCycleCheck(inner);
  }

  @override
  int? get expectedConversion => inner.expectedConversion;

  @override
  List<int> get tags => inner.tags;
}

/// A CBOR fraction (m * (10 ** e)).
class CborDecimalFraction extends DelegatingList<CborValue>
    with CborValueMixin
    implements CborList {
  CborDecimalFraction(
    this.exponent,
    this.mantissa, [
    this.tags = const [CborTag.decimalFraction],
  ]) : super([exponent, mantissa]);

  final CborInt exponent;

  final CborInt mantissa;

  @override
  final List<int> tags;

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);
    sink.addHeaderInfo(4, Info.int(2));
    exponent.encode(sink);
    mantissa.encode(sink);
  }
}

/// A CBOR fraction (m * (2 ** e)).
class CborBigFloat extends DelegatingList<CborValue>
    with CborValueMixin
    implements CborList {
  CborBigFloat(
    this.exponent,
    this.mantissa, [
    this.tags = const [CborTag.bigFloat],
  ]) : super([exponent, mantissa]);

  final CborInt exponent;

  final CborInt mantissa;

  @override
  final List<int> tags;

  @override
  void encode(EncodeSink sink) {
    sink.addTags(tags);
    sink.addHeaderInfo(4, Info.int(2));
    exponent.encode(sink);
    mantissa.encode(sink);
  }
}
