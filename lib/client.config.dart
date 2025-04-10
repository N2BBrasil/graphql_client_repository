import 'dart:async';

import 'package:graphql/client.dart';
//ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

typedef TokenHandler = FutureOr<String?> Function();
typedef GraphQLQueryOptions<TParsed extends Object?> = QueryOptions<TParsed>;
typedef GraphQLMutationOptions<TParsed extends Object?> = MutationOptions<TParsed>;
typedef GraphQLSubscriptionOptions<TParsed extends Object?> = SubscriptionOptions<TParsed>;
typedef GraphQLFetchPolicy = FetchPolicy;
typedef GraphQLCacheRereadPolicy = CacheRereadPolicy;
typedef GraphQLQueryResult<T> = QueryResult<T>;

class GraphQLRepositoryClient extends GraphQLClient {
  GraphQLRepositoryClient({
    required String url,
    required String version,
    required TokenHandler getToken,
    dynamic initSocketPayload,
    Map<String, String> defaultHttpHeaders = const {},
    http.Client? client,
    Duration? queryRequestTimeout,
    DefaultPolicies? defaultPolicies,
  })  : assert(
          !url.contains('https://') || !url.contains('wss://'),
          'url should not contain https:// or wss://',
        ),
        super(
          link: Link.split(
            (request) => request.isSubscription,
            WebSocketLink(
              [
                'wss://',
                url,
                version,
              ].join(),
              config: SocketClientConfig(initialPayload: initSocketPayload),
            ),
            AuthLink(
              getToken: getToken,
            ).concat(
              HttpLink(
                [
                  'https://',
                  url,
                  version,
                ].join(),
                defaultHeaders: defaultHttpHeaders,
                httpClient: client,
              ),
            ),
          ),
          defaultPolicies: defaultPolicies ??
              DefaultPolicies(
                query: Policies(fetch: FetchPolicy.noCache),
                mutate: Policies(fetch: FetchPolicy.noCache),
              ),
          cache: GraphQLCache(partialDataPolicy: PartialDataCachePolicy.accept),
          queryRequestTimeout: queryRequestTimeout,
        );
}
