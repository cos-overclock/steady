## 1.1.1

- Rewrite package documentation in English to satisfy pub.dev scoring checks.
- Escape angle brackets in the top-level library dartdoc to remove the analyzer info reported by pub.dev.

## 1.1.0

- Make `Result.expect` rethrow the original exception with its original stack trace.
- Clarify callback exception behavior in `Result.map`, `mapAsync`, `andThen`, `andThenAsync`, `orElse`, `orElseAsync`, `recover`, `recoverAsync`, `mapErr`, and `mapErrAsync`.
- Make `Option.expect` throw `StateError`.
- Update documentation to reflect the new behavior.
- Add tests for exception wrapping and propagation.

## 1.0.1

- Change `fold` to use named parameters.

## 1.0.0

- Initial release.
- Add `Result<T, E>` for explicit success and failure handling.
- Add `Option<T>` for explicit optional values.
- Include sync and async transformation helpers, chaining, recovery, and conversion APIs.
- Build on Freezed for immutable data types and pattern matching support.
