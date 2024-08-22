import 'package:graphql_client_repository/helpers/helpers.dart';

class GraphQLQueryFilter {
  GraphQLQueryFilter(this.filter, {this.customType});

  final Map<String, dynamic> filter;
  final String? customType;

  factory GraphQLQueryFilter.eq(String field, dynamic value, {String? customType}) {
    return GraphQLQueryFilter(
      {
        field: {'_eq': value}
      },
      customType: customType,
    );
  }

  Map<String, dynamic> get _flattened => _flatten(filter);

  String get name => _flattened.keys.first.split('.').first;

  dynamic get value => _flattened.values.first;

  String get paramType {
    final filterMap = _flattened.map((key, value) =>
        MapEntry(key.toVariable(true), customType ?? GraphQLQueryConverter.typeOf(value)));
    return filterMap.toString().substring(1, filterMap.toString().length - 1);
  }

  Map<String, dynamic> get variables {
    return _flattened.map((key, value) => MapEntry(key.toVariable(), value));
  }

  String get operation {
    final filterMap = _flattened.map((key, value) => MapEntry(key, '\$$key'));
    Map<String, dynamic> defflated = filterMap.entries
        .map((entry) => _deflattenAndSet(entry.key.getPathsByDelimiter('.'), entry.value))
        .toList()
        .reduce(_mergeMaps);
    defflated = _parseMapValuesToVariable(defflated);
    return defflated.toString().substring(1, defflated.toString().length - 1);
  }

  Map<String, dynamic> _parseMapValuesToVariable(Map<String, dynamic> map) {
    return map.map((key, value) => MapEntry(
        key,
        value is Map<String, dynamic>
            ? _parseMapValuesToVariable(value)
            : (value is String ? value.toVariable() : value)));
  }

  Map<String, dynamic> _mergeMaps(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    return {
      ...map1,
      ...map2.map(
        (key, value) => MapEntry(
          key,
          map1.containsKey(key) && map1[key] is Map && value is Map
              ? _mergeMaps(map1[key], Map<String, dynamic>.from(value))
              : value,
        ),
      )
    };
  }

  Map<String, dynamic> _flatten(Map<String, dynamic> target, {String delimiter = "."}) {
    final result = <String, dynamic>{};
    void step(Map<String, dynamic> obj, [String? previousKey]) {
      obj.forEach((key, value) {
        final newKey = previousKey != null ? "$previousKey$delimiter$key" : key;
        if (value is Map<String, dynamic>) {
          step(value, newKey);
        } else {
          result[newKey] = value;
        }
      });
    }

    step(target);
    return result;
  }

  Map<String, dynamic> _deflattenAndSet(List<String> path, dynamic value) {
    final target = <String, dynamic>{};
    var current = target;
    for (var i = 0; i < path.length; i++) {
      final prop = path[i];
      if (i == path.length - 1) {
        current[prop] = value;
      } else {
        current[prop] ??= <String, dynamic>{};
        current = current[prop] as Map<String, dynamic>;
      }
    }
    return target;
  }
}

extension _StringExt on String {
  String toVariable([bool addDollar = false]) => '${addDollar ? '\$' : ''}${replaceAll('.', '_')}';

  List<String> getPathsByDelimiter(String delimiter) {
    final keys = split(delimiter);
    final res = <String>[];
    for (var i = 0; i < keys.length; i++) {
      var prop = keys[i];
      while (prop.endsWith('\\')) {
        prop = prop.substring(0, prop.length - 1) + delimiter + keys[++i];
      }
      res.add(prop);
    }

    return res;
  }
}
