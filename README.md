<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# GraphQL Client Repository

A Flutter package that provides a wrapper for GraphQL client to be used in repositories. This package simplifies the integration of GraphQL in your Flutter applications by providing a clean and maintainable way to handle GraphQL operations.

## Features

- 🚀 Easy integration with GraphQL APIs
- 📦 Repository pattern implementation
- 🔄 Type-safe GraphQL operations
- 🛠️ Built on top of the official `graphql` package
- 📝 Clean and maintainable code structure

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  graphql_client_repository: ^1.0.0
```

## Usage

Here's a simple example of how to use this package:

```dart
import 'package:graphql_client_repository/graphql_client_repository.dart';

// Create your repository
class UserRepository extends GraphQLRepository {
  Future<User> getUser(String id) async {
    final result = await query(
      document: gql('''
        query GetUser(\$id: ID!) {
          user(id: \$id) {
            id
            name
            email
          }
        }
      '''),
      variables: {'id': id},
    );

    return User.fromJson(result.data!['user']);
  }
}
```

## Additional information

This package is built on top of the official `graphql` package and follows the repository pattern to provide a clean and maintainable way to handle GraphQL operations in your Flutter applications.

### Contributing

Feel free to contribute to this project by:

1. Forking the repository
2. Creating a new branch
3. Making your changes
4. Submitting a pull request

### Issues and Feedback

Please file issues and feature requests on the [GitHub repository](https://github.com/yourusername/graphql_client_repository).

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
