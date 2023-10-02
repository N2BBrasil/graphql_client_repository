import 'package:graphql/client.dart';
import 'package:graphql_client_repository/exceptions/exceptions.dart';

extension ResultInterceptor<T> on QueryResult<T> {
  T? parse() {
    if (hasException) {
      final currentException = exception!.linkException;

      if (currentException is HttpLinkServerException) {
        throw GraphQLServerResponseException(
          code: currentException.response.statusCode,
          message: currentException.parsedResponse?.errors?.first.message ??
              currentException.response.reasonPhrase ??
              'internal error',
          originalException: currentException.originalException,
        );
      }

      throw GraphQLServerResponseException(
        code: currentException.hashCode,
        message: currentException.toString(),
        originalException: currentException?.originalException,
      );
    }

    return parsedData;
  }
}
