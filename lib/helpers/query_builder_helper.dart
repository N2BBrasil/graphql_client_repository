import 'package:graphql_client_repository/enums/enums.dart';
import 'package:graphql_client_repository/models/models.dart';

class GraphQLQueryBuilder {
  static String list({
    required GraphQLOperation operation,
    required String tableName,
    required Iterable<String> attributes,
    GraphQLSearchOptions? searchOptions,
    String? aggregate,
  }) {
    return '''
        ${[
      operation.name,
      'list_$tableName',
      if (searchOptions != null && searchOptions.hasFilters) '(${searchOptions.paramTypes})',
    ].join(' ')} {
      ${aggregate ?? ''}
      ${[
      tableName,
      if (searchOptions != null) ...[
        '(',
        [
          if (searchOptions.hasFilters) 'where: { ${searchOptions.operations} }',
          if (searchOptions.orderBy != null)
            'order_by: { ${searchOptions.orderBy?.field}: ${searchOptions.orderBy?.value} }',
          if (searchOptions.limit != null) 'limit: ${searchOptions.limit}',
          if (searchOptions.offset != null) ' offset: ${searchOptions.offset}',
        ].join(','),
        ')',
      ],
    ].join(' ')}  {
      ${attributes.join(' ')}
      }
    }
    ''';
  }

  static String count({
    required String tableName,
    GraphQLSearchOptions? searchOptions,
  }) {
    return '''
      ${[
      '${tableName}_aggregate',
      if (searchOptions != null) ...[
        '(',
        [
          if (searchOptions.hasFilters) 'where: { ${searchOptions.operations} }',
          if (searchOptions.orderBy != null)
            'order_by: { ${searchOptions.orderBy?.field}: ${searchOptions.orderBy?.value} }',
        ].join(','),
        ')',
      ],
    ].join()} { 
      aggregate {
        count
      }
    }
    ''';
  }

  static String findByPk({
    required String tableName,
    required GraphQLBaseId id,
    required Iterable<String> attributes,
  }) {
    return '''
        ${[
      'query',
      'query_${tableName}_by_pk(${id.idParams})',
    ].join(' ')} {
          ${tableName}_by_pk(id: \$id) {
            ${attributes.join(' ')}
          }
        } 
    ''';
  }
}
