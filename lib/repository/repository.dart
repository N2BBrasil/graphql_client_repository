import 'package:graphql_client_repository/client.config.dart';

export 'resolvers/resolvers.dart';

abstract class GraphQLRepository {
  GraphQLRepository(this.client);

  final GraphQLRepositoryClient client;
}
