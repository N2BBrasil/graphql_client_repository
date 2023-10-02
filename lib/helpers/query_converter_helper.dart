import 'package:gql/ast.dart' as ast;
import 'package:gql/language.dart' as lang;

class GraphQLQueryConverter {
  static ast.DocumentNode toDocumentNode(String query) =>
      lang.parseString(query);

  static Map<String, dynamic> prepareNestedProperties(
    Map<String, dynamic> json,
  ) {
    convertListStringToString(json);
    for (final element in json.keys) {
      if (json[element] is List<Map>) {
        json[element] = <String, dynamic>{
          'data': json[element]
              .map(
                (Map<String, dynamic> nested) =>
                    prepareNestedProperties(nested),
              )
              .toList(),
        };
      }
    }

    return json;
  }

  static void convertListStringToString(Map<String, dynamic> json) {
    json.forEach(
      (String key, dynamic value) {
        if (value is List<String>) {
          json[key] = value.isNotEmpty ? '{${value.join(',')}}' : null;
        }
      },
    );
  }

  static String paramsTypesOf(
    Map<String, dynamic> params, {
    Map<String, String>? customTypeOf,
  }) {
    return params.keys
        .map<String>(
          (key) {
            return '\$$key: ${customTypeOf != null && customTypeOf.containsKey(key) ? customTypeOf[key] : typeOf(params[key])}';
          },
        )
        .toList()
        .join(', ');
  }

  static String paramsOf(Map<String, dynamic> parameters) =>
      parameters.keys.map((e) => '$e:\$$e').join(', ');

  static String typeOf(dynamic value) {
    if (value is String) return 'String!';
    if (value is bool) return 'Boolean!';
    if (value is DateTime) return 'date!';
    if (value is int) return 'Int!';
    if (value is List<int>) return '[Int!]';
    if (value is List<String>) return '[String!]';
    if (value is num) return 'numeric!';

    throw UnimplementedError('Type not implemented yet');
  }
}
