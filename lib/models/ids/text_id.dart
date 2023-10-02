import 'package:graphql_client_repository/models/models.dart';

class GraphQLTextId extends GraphQLBaseId<String> {
  GraphQLTextId(super.value);

  @override
  String get idType => 'String';
}
