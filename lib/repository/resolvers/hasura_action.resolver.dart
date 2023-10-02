import 'package:graphql_client_repository/graphql_client_repository.dart';

typedef ActionDecoder<T> = T Function(dynamic);

mixin GraphQLHasuraActionResolver on GraphQLRepository {
  Future<T> callAction<T>(
    String name, {
    required List<String> fields,
    required GraphQLOperation operation,
    required ActionDecoder<T> decoder,
    Map<String, dynamic>? parameters,
    Map<String, String>? customParamTypes,
  }) async {
    final query = buildQuery(
      operation,
      name,
      parameters,
      customParamTypes,
      fields,
    );

    late GraphQLQueryResult<T?> result;

    switch (operation) {
      case GraphQLOperation.query:
        result = await client.query(
          GraphQLQueryOptions(
            document: GraphQLQueryConverter.toDocumentNode(query),
            variables: <String, dynamic>{
              if (parameters != null) ...parameters,
            },
            parserFn: (dynamic data) {
              final json = data?[name];

              if (json == null) return null;

              return decoder(json);
            },
          ),
        );
      case GraphQLOperation.mutation:
        result = await client.mutate(
          GraphQLMutationOptions(
            document: GraphQLQueryConverter.toDocumentNode(query),
            variables: <String, dynamic>{
              if (parameters != null) ...parameters,
            },
            parserFn: (dynamic data) {
              final json = data?[name];

              if (json == null) return null;

              return decoder(json);
            },
          ),
        );
      case GraphQLOperation.subscription:
        throw Exception('Subscription is not supported for actions');
    }

    return result.parse()!;
  }
}

extension QueryBuilderExt on GraphQLHasuraActionResolver {
  String buildQuery(
    GraphQLOperation operation,
    String name,
    Map<String, dynamic>? parameters,
    Map<String, String>? customParamTypes,
    List<String> fields,
  ) {
    return '''
    ${[
      operation.name,
      name,
      if (parameters != null)
        '(${GraphQLQueryConverter.paramsTypesOf(
          parameters,
          customTypeOf: customParamTypes,
        )})',
    ].join(' ')} {
      ${[
      name,
      if (parameters != null) '(${GraphQLQueryConverter.paramsOf(parameters)})',
    ].join(' ')} {
          ${fields.join('\n')}
      }
    }
  ''';
  }
}
