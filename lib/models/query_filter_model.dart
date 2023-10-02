import 'dart:convert';

import 'package:graphql_client_repository/helpers/helpers.dart';

class GraphQLQueryFilter {
  GraphQLQueryFilter(this.filter, {this.customType});

  final Map<String, dynamic> filter;
  final String? customType;

  factory GraphQLQueryFilter.eq(
    String field,
    dynamic value, {
    String? customType,
  }) {
    return GraphQLQueryFilter(
      <String, dynamic>{
        field: <String, dynamic>{'_eq': value},
      },
      customType: customType,
    );
  }

  Map<String, dynamic> get _flattened => _flatten(filter);

  String get name => _flattened.keys.first.split('.').first;

  dynamic get value => _flattened.values.first;

  String get paramType =>
      '\$$name: ${customType ?? GraphQLQueryConverter.typeOf(value)}';

  String get operation {
    final filterMap = Map<String, dynamic>.from(_flattened);
    filterMap.update(_flattened.keys.first, (dynamic _) => '\$$name');
    final mapAsString = jsonEncode(
      _deflattenAndSet(
        _split(filterMap.keys.first, '.'),
        filterMap.values.first,
      ),
    ).replaceAll('"', '');

    return mapAsString.substring(1, mapAsString.length - 1);
  }

  Map<String, dynamic> _flatten(
    Map<String, dynamic> target, {
    String delimiter = ".",
  }) {
    final result = <String, dynamic>{};

    void step(
      Map<String, dynamic> obj, [
      String? previousKey,
      int currentDepth = 1,
    ]) {
      obj.forEach((key, dynamic value) {
        final newKey = previousKey != null ? "$previousKey$delimiter$key" : key;

        if (value is Map<String, dynamic>) {
          return step(value, newKey, currentDepth + 1);
        }

        result[newKey] = value;
      });
    }

    step(target);

    return result;
  }

  Map<String, dynamic> _deflattenAndSet(
    List<String> path,
    dynamic value,
  ) {
    Map<String, dynamic> target = <String, dynamic>{};

    if (path.length == 1) {
      target[path.first] = value;

      return target;
    }

    final orig = target;
    final len = path.length;

    for (var i = 0; i < len; i++) {
      final prop = path[i];

      if (target[prop] is! Map<String, dynamic>) {
        target[prop] = <String, dynamic>{};
      }

      if (i == len - 1) {
        target[prop] = value;
        break;
      }

      target = target[prop] as Map<String, dynamic>;
    }

    return orig;
  }

  List<String> _split(String path, String splitAt) {
    final keys = path.split(splitAt);
    final res = <String>[];
    String prop;

    for (var i = 0; i < keys.length; i++) {
      prop = keys[i];
      var lastChar = prop.length - 1;
      while (prop.substring(lastChar) == '\\') {
        prop = prop.substring(0, lastChar) + splitAt + keys[++i];
        lastChar = prop.length - 1;
      }
      res.add(prop);
    }

    return res;
  }
}
