import 'package:graphql_client_repository/models/models.dart';

class GraphQLSearchOptions {
  GraphQLSearchOptions({
    this.filters,
    this.orderBy,
    this.limit,
    this.offset,
  });

  final List<GraphQLQueryFilter>? filters;
  final GraphQLOrderBy? orderBy;
  final int? limit;
  final int? offset;

  bool get hasFilters => filters != null && filters!.isNotEmpty;

  String get paramTypes => filters!.map((e) => e.paramType).join(',');

  Map<String, dynamic> get filtersOf {
    return filters?.map((e) => e.variables).reduce((value, element) => value..addAll(element)) ??
        {};
  }

  Map<String, dynamic> get filtersOf2 {
    return {
      for (final filter in filters!) filter.name: filter.value,
    };
  }

  String get operations => filters!.map((e) => e.operation).join(',');

  @override
  String toString() {
    return 'SearchQueryOptions('
        'filters: $filters, '
        'orderBy: $orderBy, '
        'limit: $limit, '
        'offset: $offset'
        ')';
  }
}

class GraphQLOrderBy {
  GraphQLOrderBy({
    required this.field,
    this.value = 'asc',
  });

  final String field;
  final String value;
}
