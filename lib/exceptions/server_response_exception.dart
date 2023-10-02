import 'package:graphql/client.dart';

class GraphQLServerResponseException implements Exception {
  GraphQLServerResponseException({
    required this.code,
    required this.message,
    required this.originalException,
    this.body,
    this.response,
  });

  final int code;
  final String message;
  final Response? response;
  final dynamic originalException;
  final dynamic body;

  @override
  String toString() => 'GraphQLResponseException: $code, $message';
}
