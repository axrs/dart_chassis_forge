import 'package:process_run/shell.dart' as pr;

typedef MapComputer<K, V> = V? Function(K key);

extension ChassisMap<K, V> on Map<K, V?> {
  /// Gets the value of the [key] from the map
  ///
  /// `since 0.0.1`
  V? get(K key) {
    return this[key];
  }

  /// Puts the [value] into the map for the given [key]
  ///
  /// `since 0.0.1`
  void put(K key, V? value) {
    this[key] = value;
  }

  /// Computes the value for the given [key] if the map does not already contain it
  ///
  /// `since 0.0.1`
  V? computeIfAbsent(K key, MapComputer<K, V?> compute) {
    if (containsKey(key)) {
      return get(key);
    } else {
      var value = compute(key);
      if (value != null) {
        put(key, value);
      }
      return value;
    }
  }

  /// Computes the value for the given [key] if the map value is currently null
  ///
  /// `since 0.0.1`
  V? computeIfNull(K key, MapComputer<K, V?> compute) {
    var value = get(key);
    if (value != null) {
      return value;
    } else {
      return computeIfAbsent(key, compute);
    }
  }
}

dynamic tryTrimRight(dynamic v) {
  return v is String ? v.trimRight() : v;
}

String buildCmdWithArgs(String cmd, List<String>? args) {
  // ignore: omit_local_variable_types
  var buffer = StringBuffer(cmd);
  if (args != null && args.isNotEmpty) {
    buffer.write(' ${pr.shellArguments(args)}');
  }
  return buffer.toString();
}
