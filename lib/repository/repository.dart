import 'package:graphql/client.dart';

export 'resolvers/resolvers.dart';

abstract class GraphQLRepository {
  GraphQLRepository(this.client);

  final GraphQLClient client;
}
