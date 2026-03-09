# steady

[![pub package](https://img.shields.io/pub/v/steady.svg)](https://pub.dev/packages/steady)

`steady` provides `Result<T, E>` and `Option<T>` for explicit, type-safe control flow in Dart.
It is inspired by Rust and is intended for codebases that prefer modeling success, failure,
and optional values without relying on unchecked exceptions or nullable values.

## Features

- Explicit success and failure handling with `Result<T, E extends Exception>`
- Explicit optional values with `Option<T>`
- Sync and async transformation helpers
- Chaining and fallback APIs for readable workflows
- Immutable sealed data types with pattern matching support

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  steady: ^1.1.1
```

Then install dependencies:

```bash
dart pub get
```

## Quick Start

Import the package:

```dart
import 'package:steady/steady.dart';
```

### Result

Create success and failure values:

```dart
final ok = Result<int, Exception>.ok(42);
final err = Result<int, Exception>.error(Exception('failed'));
```

Read values safely:

```dart
final value = ok.unwrap(); // 42
final fallback = err.unwrapOr(0); // 0

final computed = err.unwrapOrElse((error) {
  print('error: $error');
  return 0;
});
```

Transform and chain:

```dart
final result = Result<int, Exception>.ok(21)
    .map((value) => value * 2)
    .andThen((value) => Result.ok(value + 1));

print(result.unwrap()); // 43
```

Recover from errors:

```dart
final recovered = Result<int, Exception>.error(Exception('network'))
    .recover((error) => Result.ok(0));

print(recovered.unwrap()); // 0
```

Work with async callbacks:

```dart
final asyncResult = await Result<String, Exception>.ok('steady')
    .mapAsync((value) async => value.toUpperCase());

print(asyncResult.unwrap()); // STEADY
```

### Option

Create present and absent values:

```dart
final some = Option.some(42);
final none = Option<int>.none();
```

Read values safely:

```dart
final value = some.unwrap(); // 42
final fallback = none.unwrapOr(0); // 0
```

Transform and chain:

```dart
final option = Option.some(21)
    .map((value) => value * 2)
    .andThen((value) => Option.some(value + 1));

print(option.unwrap()); // 43
```

Convert an `Option` to a `Result`:

```dart
final userId = Option<String>.none();

final result = userId.toResult(() => StateError('missing user id'));
print(result.isErr); // true
```

## Core APIs

`Result<T, E>`:

- `unwrap`, `unwrapOr`, `unwrapOrElse`, `expect`
- `map`, `mapAsync`, `mapErr`, `mapErrAsync`
- `andThen`, `andThenAsync`
- `orElse`, `orElseAsync`, `recover`, `recoverAsync`
- `fold`

`Option<T>`:

- `fromNullable`
- `unwrap`, `unwrapOr`, `unwrapOrElse`, `expect`
- `map`, `mapAsync`
- `andThen`, `andThenAsync`
- `orElse`, `orElseAsync`
- `filter`, `fold`, `toResult`

## Example

```dart
Future<Result<User, Exception>> fetchUser(ApiClient client, int id) async {
  try {
    final response = await client.getUser(id);
    return Result.ok(response);
  } on Exception catch (error) {
    return Result.error(error);
  }
}

Future<String> loadUserName(ApiClient client, int id) async {
  final result = await fetchUser(client, id);
  return result.map((user) => user.name).unwrapOr('Unknown');
}
```

## Additional Resources

- API reference: https://pub.dev/documentation/steady/latest/
- Example app: [example/example.dart](example/example.dart)
- Issue tracker: https://github.com/cos-overclock/steady/issues

## Release Automation

This repository includes a GitHub Actions workflow at `.github/workflows/release_publish.yml`.
When you push a tag like `v1.1.1`, GitHub Actions will:

- verify that the tag matches the `version` in `pubspec.yaml`
- create a GitHub Release using the matching section from `CHANGELOG.md`
- publish the package to `pub.dev`

The workflow runs on tag pushes regardless of which branch the tag was created from.

Before using it, configure automated publishing on `pub.dev`:

1. Open `https://pub.dev/packages/steady/admin`.
2. Enable publishing from GitHub Actions for `cos-overclock/steady`.
3. Set the tag pattern to `v{{version}}`.

This workflow uses GitHub OIDC via the official `dart-lang/setup-dart` reusable workflow,
so no `pub.dev` API token needs to be stored as a GitHub secret.

If you enable a required GitHub Actions environment on `pub.dev`, add the same environment
name to the `publish` job in `.github/workflows/release_publish.yml`.

## License

This package is available under the MIT License. See [LICENSE](LICENSE).
