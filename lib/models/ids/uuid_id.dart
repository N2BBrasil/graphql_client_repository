import 'package:graphql_client_repository/models/models.dart';

class GraphQLUuidId extends GraphQLBaseId<String> {
  GraphQLUuidId(super.graphqlID);

  @override
  String get idType => 'uuid';
}
