import 'dart:async';

import 'package:graphql_client_repository/graphql_client_repository.dart';

mixin GraphQLTableDataResolver<IdType extends GraphQLBaseId, Model>
    on GraphQLRepository {
  String get table;

  Iterable<String> get attributes;

  Model encode(Map<String, dynamic> json);

  Map<String, dynamic> decode(Model model);

  IdType mapId(dynamic value);

  void beforeCreate(Map<String, dynamic> json) {}

  List<T> parseList<T>(dynamic data) {
    return data
        .map<T>((dynamic model) => encode(model as Map<String, dynamic>))
        .toList() as List<T>;
  }

  Future<bool> delete(
    IdType id, {
    GraphQLFetchPolicy? fetchPolicy,
    GraphQLCacheRereadPolicy? cacheRereadPolicy,
  }) async {
    final mutation = '''
      mutation delete$table(${id.idParams}) {
        delete_$table(where: {id: {_eq: \$id}}) {
          affected_rows
        }
      }
    ''';

    final result = await client.mutate<bool>(
      GraphQLMutationOptions(
        document: GraphQLQueryConverter.toDocumentNode(mutation),
        variables: {'id': id.value},
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        parserFn: (_) => true,
      ),
    );

    return result.parse()!;
  }

  Future<IdType> create(
    Model model, {
    GraphQLFetchPolicy? fetchPolicy,
    GraphQLCacheRereadPolicy? cacheRereadPolicy,
  }) async {
    final json = decode(model);
    beforeCreate(json);

    final mutation = '''
      mutation insert_$table(\$object: ${table}_insert_input! ) {
        insert_${table}_one(object: \$object) {
          id
        }
      }
    ''';

    final result = await client.mutate<IdType>(
      GraphQLMutationOptions(
        document: GraphQLQueryConverter.toDocumentNode(mutation),
        variables: <String, dynamic>{
          'object': GraphQLQueryConverter.prepareNestedProperties(json),
        },
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        parserFn: (Map<String, dynamic>? data) {
          return mapId(data?['insert_${table}_one']['id']);
        },
      ),
    );

    return result.parse()!;
  }

  Future<bool> update({
    required Model model,
    String? id,
    List<String>? updateAttributes,
    GraphQLFetchPolicy? fetchPolicy,
    GraphQLCacheRereadPolicy? cacheRereadPolicy,
  }) async {
    final json = decode(model);

    assert(
      json['id'] != null || id != null,
      'Model $model does not have a valid id',
    );

    final graphqlId = mapId(json['id'] ?? id);

    final mutation = '''
      mutation update_$table(${graphqlId.idParams}, \$changes: ${table}_set_input) {
        update_$table(
          where: {id: {_eq: \$id}},
          _set: \$changes
        ) {
          affected_rows
          returning {
            id
          }
        }
      }
    ''';

    json.removeWhere(
      (String key, dynamic value) => [
        'id',
        'created_at',
        'updated_at',
      ].contains(key),
    );

    if (updateAttributes != null) {
      json.removeWhere(
        (String key, dynamic value) => !updateAttributes.contains(key),
      );
    }

    GraphQLQueryConverter.convertListStringToString(json);

    final result = await client.mutate<bool>(
      GraphQLMutationOptions(
        document: GraphQLQueryConverter.toDocumentNode(mutation),
        variables: <String, dynamic>{
          'id': graphqlId.value,
          'changes': json,
        },
        fetchPolicy: fetchPolicy,
        cacheRereadPolicy: cacheRereadPolicy,
        parserFn: (_) => true,
      ),
    );

    return result.parse()!;
  }

  Future<int> count({
    GraphQLSearchOptions? searchOptions,
    GraphQLFetchPolicy? fetchPolicy,
  }) async {
    final query = '''
      ${[
      'query',
      'aggregate',
      if (searchOptions != null && searchOptions.filters != null)
        '(${searchOptions.paramTypes})',
    ].join(' ')} {
      ${GraphQLQueryBuilder.count(
      tableName: table,
      searchOptions: searchOptions,
    )}
    }
    ''';

    final result = await client.query<int>(
      GraphQLQueryOptions(
        document: GraphQLQueryConverter.toDocumentNode(query),
        fetchPolicy: fetchPolicy,
        variables: (searchOptions?.filters != null)
            ? searchOptions!.filtersOf
            : const <String, dynamic>{},
        parserFn: (Map<String, dynamic>? data) {
          return data!['${table}_aggregate']['aggregate']['count'] as int;
        },
      ),
    );

    return result.parse()!;
  }

  Future<Model?> findByPk({
    required IdType id,
    Iterable<String>? attributes,
    GraphQLFetchPolicy? fetchPolicy,
  }) async {
    final query = GraphQLQueryBuilder.findByPk(
      id: id,
      tableName: table,
      attributes: attributes ?? this.attributes,
    );

    final result = await client.query<Model?>(
      GraphQLQueryOptions(
        document: GraphQLQueryConverter.toDocumentNode(query),
        variables: {'id': id.value},
        fetchPolicy: fetchPolicy,
        parserFn: (Map<String, dynamic>? data) {
          final json = data?['${table}_by_pk'];

          if (json == null) return null;

          return encode(json as Map<String, dynamic>);
        },
      ),
    );

    return result.parse();
  }

  Future<Model?> get({
    Iterable<String>? attributes,
    List<GraphQLQueryFilter>? filters,
    GraphQLOrderBy? orderBy,
  }) async {
    final result = await list(
      attributes: attributes,
      searchOptions: GraphQLSearchOptions(
        orderBy: orderBy,
        filters: filters,
        limit: 1,
      ),
    );

    try {
      return result.single;
    } catch (_) {
      return null;
    }
  }

  Future<List<Model>> list({
    Iterable<String>? attributes,
    GraphQLSearchOptions? searchOptions,
    GraphQLFetchPolicy? fetchPolicy,
  }) async {
    final result = await client.query<List<Model>>(
      GraphQLQueryOptions(
        document: GraphQLQueryConverter.toDocumentNode(
          GraphQLQueryBuilder.list(
            tableName: table,
            searchOptions: searchOptions,
            attributes: attributes ?? this.attributes,
            operation: GraphQLOperation.query,
          ),
        ),
        fetchPolicy: fetchPolicy,
        variables: (searchOptions?.filters != null)
            ? searchOptions!.filtersOf
            : const <String, dynamic>{},
        parserFn: (Map<String, dynamic>? data) {
          if (data?[table] == null) return [];

          return parseList<Model>(data![table]);
        },
      ),
    );

    return result.parse() ?? [];
  }

  Future<GraphQLPaginatedList<Model>> paginatedList({
    Iterable<String>? attributes,
    GraphQLSearchOptions? searchOptions,
    GraphQLFetchPolicy? fetchPolicy,
  }) async {
    final result = await client.query<GraphQLPaginatedList<Model>>(
      GraphQLQueryOptions(
        document: GraphQLQueryConverter.toDocumentNode(
          GraphQLQueryBuilder.list(
            tableName: table,
            operation: GraphQLOperation.query,
            searchOptions: searchOptions,
            attributes: attributes ?? this.attributes,
            aggregate: GraphQLQueryBuilder.count(
              tableName: table,
              searchOptions: searchOptions,
            ),
          ),
        ),
        fetchPolicy: fetchPolicy,
        variables: (searchOptions?.filters != null)
            ? searchOptions!.filtersOf
            : const <String, dynamic>{},
        parserFn: (Map<String, dynamic>? data) {
          if (data?[table] == null) return GraphQLPaginatedList.empty();

          return GraphQLPaginatedList(
            list: parseList<Model>(data![table]),
            count: data['${table}_aggregate']['aggregate']['count'] as int,
          );
        },
      ),
    );

    return result.parse()!;
  }

  Stream<Model?> subscribe({
    required IdType id,
    Iterable<String>? attributes,
    GraphQLFetchPolicy? fetchPolicy,
  }) {
    final subscription = '''
      ${[
      'subscription',
      'subscription_${table}_by_pk(${id.idParams})',
    ].join(' ')} {
        ${table}_by_pk(id: \$id) {
          ${(attributes ?? this.attributes).join(' ')}
        }
      }
    ''';

    final options = GraphQLSubscriptionOptions(
      document: GraphQLQueryConverter.toDocumentNode(subscription),
      variables: {'id': id.value},
      fetchPolicy: fetchPolicy,
      parserFn: (Map<String, dynamic>? data) {
        final json = data?['${table}_by_pk'];

        if (json == null) return null;

        return encode(json as Map<String, dynamic>);
      },
    );

    return client.subscribe<Model?>(options).map((result) {
      return result.parsedData;
    });
  }

  Stream<List<Model>> subscribeList({
    Iterable<String>? attributes,
    GraphQLSearchOptions? searchOptions,
    GraphQLFetchPolicy? fetchPolicy,
  }) {
    final options = GraphQLSubscriptionOptions<List<Model>>(
      document: GraphQLQueryConverter.toDocumentNode(
        GraphQLQueryBuilder.list(
          attributes: attributes ?? this.attributes,
          searchOptions: searchOptions,
          operation: GraphQLOperation.subscription,
          tableName: table,
        ),
      ),
      fetchPolicy: fetchPolicy,
      variables: (searchOptions?.filters != null)
          ? searchOptions!.filtersOf
          : const <String, dynamic>{},
      parserFn: (Map<String, dynamic>? data) {
        if (data?[table] == null) return [];

        return parseList<Model>(data![table]);
      },
    );

    return client.subscribe(options).map((result) => result.parsedData ?? []);
  }
}
