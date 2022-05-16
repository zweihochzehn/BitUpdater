import 'dart:convert';

import 'package:flutter/foundation.dart';

T? tryCast<T>(dynamic x, {T? fallback, bool nullable = true}) {
  if (x == null && nullable) {
    return fallback;
  }

  T result;

  if (T == double) {
    if (x is String) {
      result = double.parse(x) as T;
    } else {
      result = (x is num ? x.toDouble() : fallback) as T;
    }
  } else if (T == List && x is String) {
    List output;
    try {
      output = json.decode(x);
      return output as T;
    } catch(err){
      if (kDebugMode) {
        print('The input is not a string representation of a list');
      }
      return fallback;
    }
  } else {
    result = (x is T ? x : fallback)!;
  }

  if (!nullable && result == null) {
    throw FormatException("$x can not be converted to $T");
  } else {
    return result;
  }
}

class Nullable<T> {
  T? _value;

  Nullable(this._value);

  T? get value {
    return _value;
  }
}