import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// Result型は、成功または失敗を表す汎用的な型です。
///
/// Rustの`Result<T, E>`型にインスパイアされた実装で、
/// 例外処理を明示的に扱うことができます。
///
/// [T] 成功時の値の型
/// [E] 失敗時の例外の型（[Exception]のサブタイプである必要があります）
///
/// 使用例:
/// ```dart
/// // 成功の場合
/// final result = Result.ok(42);
/// final value = result.unwrap(); // 42
///
/// // 失敗の場合
/// final result = Result.error(Exception('エラーが発生しました'));
/// if (result.isErr()) {
///   print(result.err); // Exception: エラーが発生しました
/// }
///
/// // チェーン処理
/// final result = Result.ok(21)
///   .map((x) => x * 2)
///   .andThen((x) => Result.ok(x + 1))
///   .unwrap(); // 43
/// ```
@freezed
sealed class Result<T, E extends Exception> with _$Result<T, E> {
  const Result._();

  /// 成功を表すResultを作成します。
  ///
  /// [data] 成功時の値
  const factory Result.ok(T data) = Ok<T, E>;

  /// 失敗を表すResultを作成します。
  ///
  /// [error] 失敗時の例外
  const factory Result.error(E error) = Err<T, E>;

  /// 成功値を取得します。失敗の場合は例外を投げます。
  ///
  /// 成功時は値を返し、失敗時は[E]型の例外を投げます。
  /// 失敗の可能性がある場合は[unwrapOr]や[unwrapOrElse]の使用を検討してください。
  ///
  /// 例:
  /// ```dart
  /// final result = Result.ok(42);
  /// final value = result.unwrap(); // 42
  ///
  /// final error = Result.error(Exception('error'));
  /// final value = error.unwrap(); // Exceptionを投げる
  /// ```
  T unwrap() => switch (this) {
        Ok(:final data) => data,
        Err(:final error) => throw error,
      };

  /// 成功値を取得します。失敗の場合はデフォルト値を返します。
  ///
  /// [defaultValue] 失敗時に返すデフォルト値
  ///
  /// 例:
  /// ```dart
  /// final result = Result.ok(42);
  /// final value = result.unwrapOr(0); // 42
  ///
  /// final error = Result.error(Exception('error'));
  /// final value = error.unwrapOr(0); // 0
  /// ```
  T unwrapOr(T defaultValue) => switch (this) {
        Ok(:final data) => data,
        Err() => defaultValue,
      };

  /// Resultが成功かどうかを判定します。
  ///
  /// 成功の場合は`true`、失敗の場合は`false`を返します。
  ///
  /// 例:
  /// ```dart
  /// Result.ok(42).isOk; // true
  /// Result.error(Exception('error')).isOk; // false
  /// ```
  bool get isOk => switch (this) {
        Ok() => true,
        Err() => false,
      };

  /// Resultが失敗かどうかを判定します。
  ///
  /// 失敗の場合は`true`、成功の場合は`false`を返します。
  ///
  /// 例:
  /// ```dart
  /// Result.ok(42).isErr; // false
  /// Result.error(Exception('error')).isErr; // true
  /// ```
  bool get isErr => switch (this) {
        Ok() => false,
        Err() => true,
      };

  /// 成功値を別の型に変換します。失敗の場合はそのまま返します。
  ///
  /// [onSuccess] 成功値を変換する関数
  ///
  /// 成功時は[onSuccess]で変換した値を含む新しいResultを返し、
  /// 失敗時はエラーをそのまま返します。
  ///
  /// 例:
  /// ```dart
  /// final result = Result.ok(21);
  /// final doubled = result.map((x) => x * 2); // Result.ok(42)
  ///
  /// final error = Result.error(Exception('error'));
  /// final doubled = error.map((x) => x * 2); // エラーをそのまま返す
  /// ```
  Result<U, E> map<U>(U Function(T) onSuccess) => switch (this) {
        Ok(:final data) => Ok(onSuccess(data)),
        Err(:final error) => Err(error),
      };

  /// 成功値を非同期で別の型に変換します。失敗の場合はそのまま返します。
  ///
  /// [onSuccess] 成功値を非同期で変換する関数
  ///
  /// 成功時は[onSuccess]で変換した値を含む新しいResultを返し、
  /// 失敗時はエラーをそのまま返します。
  ///
  /// 例:
  /// ```dart
  /// final result = Result.ok('data');
  /// final processed = await result.mapAsync((x) async => await process(x));
  /// ```
  Future<Result<U, E>> mapAsync<U>(Future<U> Function(T) onSuccess) async =>
      switch (this) {
        Ok(:final data) => Ok(await onSuccess(data)),
        Err(:final error) => Err(error),
      };

  /// エラー値を別の型の例外に変換します。成功の場合はそのまま返します。
  ///
  /// [onFailure] エラー値を変換する関数
  ///
  /// 失敗時は[onFailure]で変換した例外を含む新しいResultを返し、
  /// 成功時は値をそのまま返します。
  ///
  /// 例:
  /// ```dart
  /// final error = Result.error(FormatException('parse error'));
  /// final mapped = error.mapErr((e) => Exception('converted: $e'));
  /// ```
  Result<T, F> mapErr<F extends Exception>(F Function(E) onFailure) =>
      switch (this) {
        Ok(:final data) => Ok(data),
        Err(:final error) => Err(onFailure(error)),
      };

  /// エラー値を非同期で別の型の例外に変換します。成功の場合はそのまま返します。
  ///
  /// [onFailure] エラー値を非同期で変換する関数
  ///
  /// 失敗時は[onFailure]で変換した例外を含む新しいResultを返し、
  /// 成功時は値をそのまま返します。
  ///
  /// 例:
  /// ```dart
  /// final error = Result.error(FormatException('parse error'));
  /// final mapped = await error.mapErrAsync((e) async => await convertError(e));
  /// ```
  Future<Result<T, F>> mapErrAsync<F extends Exception>(
    Future<F> Function(E) onFailure,
  ) async =>
      switch (this) {
        Ok(:final data) => Ok(data),
        Err(:final error) => Err(await onFailure(error)),
      };

  /// 成功時にResultを返す関数を適用し、失敗時はそのまま返します。
  ///
  /// [onSuccess] 成功値を受け取り、新しいResultを返す関数
  ///
  /// `map`と似ていますが、変換関数がResultを返す場合に使用します。
  /// これにより、Resultのチェーン処理が可能になります。
  ///
  /// 例:
  /// ```dart
  /// Result.ok(21)
  ///   .andThen((x) => Result.ok(x * 2))
  ///   .andThen((x) => Result.ok(x + 1)); // Result.ok(43)
  ///
  /// Result.error(Exception('error'))
  ///   .andThen((x) => Result.ok(x * 2)); // エラーをそのまま返す
  /// ```
  Result<U, E> andThen<U>(Result<U, E> Function(T) onSuccess) => switch (this) {
        Ok(:final data) => onSuccess(data),
        Err(:final error) => Err(error),
      };

  /// 非同期でResultを返す関数を適用し、失敗時はそのまま返します。
  ///
  /// [onSuccess] 成功値を受け取り、新しいResultを非同期で返す関数
  ///
  /// `andThen`の非同期版です。非同期処理を含むResultのチェーン処理に使用します。
  ///
  /// 例:
  /// ```dart
  /// await Result.ok('data')
  ///   .andThenAsync((x) async => await fetchResult(x))
  ///   .andThenAsync((x) async => await processResult(x));
  /// ```
  Future<Result<U, E>> andThenAsync<U>(
    Future<Result<U, E>> Function(T) onSuccess,
  ) async =>
      switch (this) {
        Ok(:final data) => await onSuccess(data),
        Err(:final error) => Err(error),
      };

  /// 成功値を取得します。失敗の場合は計算されたデフォルト値を返します。
  ///
  /// [onFailure] エラーを受け取り、デフォルト値を返す関数
  ///
  /// `unwrapOr`と似ていますが、デフォルト値が関数で計算されます。
  /// デフォルト値の計算にコストがかかる場合や、エラー情報を利用したい場合に便利です。
  ///
  /// 例:
  /// ```dart
  /// final result = Result.ok(42);
  /// final value = result.unwrapOrElse((e) => 0); // 42
  ///
  /// final error = Result.error(Exception('error'));
  /// final value = error.unwrapOrElse((e) {
  ///   print('Error: $e');
  ///   return 0;
  /// }); // 0
  /// ```
  T unwrapOrElse(T Function(E) onFailure) => switch (this) {
        Ok(:final data) => data,
        Err(:final error) => onFailure(error),
      };

  /// 成功値を取得します。失敗の場合はカスタムメッセージ付きで例外を投げます。
  ///
  /// [message] 失敗時に例外に含めるメッセージ
  ///
  /// `unwrap`と似ていますが、より詳細なエラーメッセージを提供します。
  /// デバッグやエラーログに便利です。
  ///
  /// 例:
  /// ```dart
  /// final result = Result.ok(42);
  /// final value = result.expect('値の取得に失敗'); // 42
  ///
  /// final error = Result.error(Exception('error'));
  /// final value = error.expect('値の取得に失敗'); // Exception('値の取得に失敗: error')を投げる
  /// ```
  T expect(String message) => switch (this) {
        Ok(:final data) => data,
        Err(:final error) => throw Exception('$message: $error'),
      };

  /// 失敗時に別のResultを返します。成功の場合はそのまま返します。
  ///
  /// [onFailure] エラーを受け取り、代替のResultを返す関数
  ///
  /// エラー回復やフォールバック処理に使用します。
  /// 成功時は値をそのまま返し、失敗時は[onFailure]で生成されたResultを返します。
  ///
  /// 例:
  /// ```dart
  /// final result = Result.ok(42);
  /// final value = result.orElse((e) => Result.ok(0)); // Result.ok(42)
  ///
  /// final error = Result.error(Exception('error'));
  /// final value = error.orElse((e) => Result.ok(0)); // Result.ok(0)
  /// ```
  Result<T, F> orElse<F extends Exception>(
    Result<T, F> Function(E) onFailure,
  ) =>
      switch (this) {
        Ok(:final data) => Ok(data),
        Err(:final error) => onFailure(error),
      };

  /// 非同期で失敗時に別のResultを返します。成功の場合はそのまま返します。
  ///
  /// [onFailure] エラーを受け取り、代替のResultを非同期で返す関数
  ///
  /// `orElse`の非同期版です。非同期処理を含むエラー回復やフォールバック処理に使用します。
  ///
  /// 例:
  /// ```dart
  /// await Result.error(Exception('error'))
  ///   .orElseAsync((e) async => await fetchFallbackData());
  /// ```
  Future<Result<T, F>> orElseAsync<F extends Exception>(
    Future<Result<T, F>> Function(E) onFailure,
  ) async =>
      switch (this) {
        Ok(:final data) => Ok(data),
        Err(:final error) => await onFailure(error),
      };

  /// 成功/失敗の両方で値を返します（fold操作）。
  ///
  /// [onFailure] 失敗時に呼ばれる関数
  /// [onSuccess] 成功時に呼ばれる関数
  ///
  /// 関数型プログラミングのfold操作です。
  /// 成功時は[onSuccess]を、失敗時は[onFailure]を呼び出し、その結果を返します。
  ///
  /// 例:
  /// ```dart
  /// final result = Result.ok(42);
  /// final message = result.fold(
  ///   (error) => 'Error: $error',
  ///   (value) => 'Value: $value',
  /// ); // 'Value: 42'
  ///
  /// final error = Result.error(Exception('error'));
  /// final message = error.fold(
  ///   (error) => 'Error: $error',
  ///   (value) => 'Value: $value',
  /// ); // 'Error: Exception: error'
  /// ```
  R fold<R>(
          {required R Function(E) onFailure,
          required R Function(T) onSuccess}) =>
      switch (this) {
        Ok(:final data) => onSuccess(data),
        Err(:final error) => onFailure(error),
      };

  /// エラーから回復を試みます。成功の場合はそのまま返します。
  ///
  /// [onFailure] エラーを受け取り、回復を試みたResultを返す関数
  ///
  /// `orElse`と似ていますが、同じエラー型[E]を返します。
  /// エラーから回復できる可能性がある場合に使用します。
  ///
  /// 例:
  /// ```dart
  /// final error = Result.error(Exception('network error'));
  /// final recovered = error.recover((e) {
  ///   // リトライやフォールバック処理
  ///   return Result.ok(defaultValue);
  /// });
  /// ```
  Result<T, E> recover(Result<T, E> Function(E) onFailure) => switch (this) {
        Ok(:final data) => Ok(data),
        Err(:final error) => onFailure(error),
      };

  /// 非同期でエラーから回復を試みます。成功の場合はそのまま返します。
  ///
  /// [onFailure] エラーを受け取り、回復を試みたResultを非同期で返す関数
  ///
  /// `recover`の非同期版です。非同期処理を含むエラー回復に使用します。
  ///
  /// 例:
  /// ```dart
  /// await Result.error(Exception('network error'))
  ///   .recoverAsync((e) async => await retryOperation());
  /// ```
  Future<Result<T, E>> recoverAsync(
    Future<Result<T, E>> Function(E) onFailure,
  ) async =>
      switch (this) {
        Ok(:final data) => Ok(data),
        Err(:final error) => await onFailure(error),
      };

  /// 成功値を取得します。失敗の場合はnullを返します。
  ///
  /// 成功時は値を返し、失敗時はnullを返します。
  /// null安全性を活用したい場合に便利です。
  ///
  /// 例:
  /// ```dart
  /// final result = Result.ok(42);
  /// final value = result.ok; // 42
  ///
  /// final error = Result.error(Exception('error'));
  /// final value = error.ok; // null
  /// ```
  T? get ok => switch (this) {
        Ok(:final data) => data,
        Err() => null,
      };

  /// エラー値を取得します。成功の場合はnullを返します。
  ///
  /// 失敗時はエラーを返し、成功時はnullを返します。
  /// null安全性を活用したい場合に便利です。
  ///
  /// 例:
  /// ```dart
  /// final result = Result.ok(42);
  /// final error = result.err; // null
  ///
  /// final error = Result.error(Exception('error'));
  /// final err = error.err; // Exception('error')
  /// ```
  E? get err => switch (this) {
        Ok() => null,
        Err(:final error) => error,
      };
}
