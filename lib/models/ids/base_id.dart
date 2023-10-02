abstract class GraphQLBaseId<IdType> {
  const GraphQLBaseId(this.value);

  final IdType value;

  String get idType;

  String get idParams => '\$id:$idType!';

  @override
  String toString() => value.toString();
}
