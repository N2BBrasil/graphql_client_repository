class GraphQLPaginatedList<T> {
  final int count;
  final List<T> list;

  const GraphQLPaginatedList({
    required this.count,
    required this.list,
  });

  factory GraphQLPaginatedList.empty() =>
      const GraphQLPaginatedList(list: [], count: 0);
}
