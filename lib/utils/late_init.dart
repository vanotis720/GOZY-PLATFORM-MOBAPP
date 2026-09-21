import 'package:flutter/foundation.dart';

//https://stackoverflow.com/questions/67197902/how-to-check-late-variable-is-initialized-in-dart
class Late<T> {
  final ValueNotifier<bool> _initialization = ValueNotifier(false);
  late T _val;

  Late([T? value]) {
    if (value != null) {
      val = value;
    }
  }

  bool get isInitialized {
    return _initialization.value;
  }

  T get val => _val;

  set val(T val) => this
    .._initialization.value = true
    .._val = val;
}