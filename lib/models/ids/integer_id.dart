import 'package:graphql_client_repository/models/models.dart';

class GraphQLIntegerId extends GraphQLBaseId<int> {
  GraphQLIntegerId(super.graphqlID);

  @override
  String get idType => 'Int';
}
