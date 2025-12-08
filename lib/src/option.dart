import 'package:freezed_annotation/freezed_annotation.dart';

import 'result.dart';

part 'option.freezed.dart';

/// Option型は、値が存在するかしないかを表す汎用的な型です。
///
/// Rustの`Option<T>`型にインスパイアされた実装で、
/// null安全性を明示的に扱うことができます。
///
/// [T] 値の型
///
/// 使用例:
/// ```dart
/// // 値が存在する場合
/// final option = Option.some(42);
/// final value = option.unwrap(); // 42
///
/// // 値が存在しない場合
/// final option = Option.none();
/// final value = option.unwrapOr(0); // 0
///
/// // チェーン処理
/// final result = Option.some(21)
///   .map((x) => x * 2)
///   .andThen((x) => Option.some(x + 1))
///   .unwrap(); // 43
/// ```
@freezed
sealed class Option<T> with _$Option<T> {
  const Option._();

  /// 値が存在するOptionを作成します。
  ///
  /// [value] 存在する値
  const factory Option.some(T value) = Some<T>;

  /// 値が存在しないOptionを作成します。
  const factory Option.none() = None;

  /// 値が存在するかしないかを表すOptionを作成します。
  ///
  /// [value] 値
  ///
  /// 値が存在する場合はOption.someを、存在しない場合はOption.noneを返します。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.fromNullable(42); // Option.some(42)
  /// final option2 = Option.fromNullable(null); // Option.none()
  /// ```
  factory Option.fromNullable(T? value) =>
      value == null ? Option.none() : Option.some(value);

  /// 値を取得します。値が存在しない場合は例外を投げます。
  ///
  /// 値が存在する場合は値を返し、存在しない場合は例外を投げます。
  /// 値が存在しない可能性がある場合は[unwrapOr]や[unwrapOrElse]の使用を検討してください。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some(42);
  /// final value = option.unwrap(); // 42
  ///
  /// final none = Option.none();
  /// final value = none.unwrap(); // 例外を投げる
  /// ```
  T unwrap() => switch (this) {
        Some(:final value) => value,
        None() => throw Exception('Called unwrap on None'),
      };

  /// 値を取得します。値が存在しない場合はデフォルト値を返します。
  ///
  /// [defaultValue] 値が存在しない場合に返すデフォルト値
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some(42);
  /// final value = option.unwrapOr(0); // 42
  ///
  /// final none = Option.none();
  /// final value = none.unwrapOr(0); // 0
  /// ```
  T unwrapOr(T defaultValue) => switch (this) {
        Some(:final value) => value,
        None() => defaultValue,
      };

  /// 値を取得します。値が存在しない場合は計算されたデフォルト値を返します。
  ///
  /// [onNone] 値が存在しない場合に呼ばれる関数
  ///
  /// `unwrapOr`と似ていますが、デフォルト値が関数で計算されます。
  /// デフォルト値の計算にコストがかかる場合に便利です。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some(42);
  /// final value = option.unwrapOrElse(() => 0); // 42
  ///
  /// final none = Option.none();
  /// final value = none.unwrapOrElse(() {
  ///   print('値が存在しません');
  ///   return 0;
  /// }); // 0
  /// ```
  T unwrapOrElse(T Function() onNone) => switch (this) {
        Some(:final value) => value,
        None() => onNone(),
      };

  /// 値を取得します。値が存在しない場合はカスタムメッセージ付きで例外を投げます。
  ///
  /// [message] 値が存在しない場合に例外に含めるメッセージ
  ///
  /// `unwrap`と似ていますが、より詳細なエラーメッセージを提供します。
  /// デバッグやエラーログに便利です。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some(42);
  /// final value = option.expect('値の取得に失敗'); // 42
  ///
  /// final none = Option.none();
  /// final value = none.expect('値の取得に失敗'); // Exception('値の取得に失敗')を投げる
  /// ```
  T expect(String message) => switch (this) {
        Some(:final value) => value,
        // StateError makes it explicit that the object is in an invalid state.
        None() => throw StateError(message),
      };

  /// Optionが値を持つかどうかを判定します。
  ///
  /// 値が存在する場合は`true`、存在しない場合は`false`を返します。
  ///
  /// 例:
  /// ```dart
  /// Option.some(42).isSome; // true
  /// Option.none().isSome; // false
  /// ```
  bool get isSome => switch (this) {
        Some() => true,
        None() => false,
      };

  /// Optionが値を持たないかどうかを判定します。
  ///
  /// 値が存在しない場合は`true`、存在する場合は`false`を返します。
  ///
  /// 例:
  /// ```dart
  /// Option.some(42).isNone; // false
  /// Option.none().isNone; // true
  /// ```
  bool get isNone => switch (this) {
        Some() => false,
        None() => true,
      };

  /// 値を取得します。値が存在しない場合はnullを返します。
  ///
  /// 値が存在する場合は値を返し、存在しない場合はnullを返します。
  /// null安全性を活用したい場合に便利です。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some(42);
  /// final value = option.value; // 42
  ///
  /// final none = Option.none();
  /// final value = none.value; // null
  /// ```
  T? get value => switch (this) {
        Some(:final value) => value,
        None() => null,
      };

  /// 値を別の型に変換します。値が存在しない場合はそのまま返します。
  ///
  /// [onSome] 値を変換する関数
  ///
  /// 値が存在する場合は[onSome]で変換した値を含む新しいOptionを返し、
  /// 存在しない場合はNoneをそのまま返します。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some(21);
  /// final doubled = option.map((x) => x * 2); // Option.some(42)
  ///
  /// final none = Option.none();
  /// final doubled = none.map((x) => x * 2); // Option.none()
  /// ```
  Option<U> map<U>(U Function(T) onSome) => switch (this) {
        Some(:final value) => Option.some(onSome(value)),
        None() => Option.none(),
      };

  /// 値を非同期で別の型に変換します。値が存在しない場合はそのまま返します。
  ///
  /// [onSome] 値を非同期で変換する関数
  ///
  /// 値が存在する場合は[onSome]で変換した値を含む新しいOptionを返し、
  /// 存在しない場合はNoneをそのまま返します。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some('data');
  /// final processed = await option.mapAsync((x) async => await process(x));
  /// ```
  Future<Option<U>> mapAsync<U>(Future<U> Function(T) onSome) async =>
      switch (this) {
        Some(:final value) => Option.some(await onSome(value)),
        None() => Option.none(),
      };

  /// 値が存在する場合にOptionを返す関数を適用します。値が存在しない場合はそのまま返します。
  ///
  /// [onSome] 値を受け取り、新しいOptionを返す関数
  ///
  /// `map`と似ていますが、変換関数がOptionを返す場合に使用します。
  /// これにより、Optionのチェーン処理が可能になります。
  ///
  /// 例:
  /// ```dart
  /// Option.some(21)
  ///   .andThen((x) => Option.some(x * 2))
  ///   .andThen((x) => Option.some(x + 1)); // Option.some(43)
  ///
  /// Option.none()
  ///   .andThen((x) => Option.some(x * 2)); // Option.none()
  /// ```
  Option<U> andThen<U>(Option<U> Function(T) onSome) => switch (this) {
        Some(:final value) => onSome(value),
        None() => Option.none(),
      };

  /// 非同期でOptionを返す関数を適用します。値が存在しない場合はそのまま返します。
  ///
  /// [onSome] 値を受け取り、新しいOptionを非同期で返す関数
  ///
  /// `andThen`の非同期版です。非同期処理を含むOptionのチェーン処理に使用します。
  ///
  /// 例:
  /// ```dart
  /// await Option.some('data')
  ///   .andThenAsync((x) async => await fetchOption(x))
  ///   .andThenAsync((x) async => await processOption(x));
  /// ```
  Future<Option<U>> andThenAsync<U>(
    Future<Option<U>> Function(T) onSome,
  ) async =>
      switch (this) {
        Some(:final value) => await onSome(value),
        None() => Option.none(),
      };

  /// 値が存在しない場合に別のOptionを返します。値が存在する場合はそのまま返します。
  ///
  /// [onNone] 値が存在しない場合に呼ばれる関数
  ///
  /// フォールバック処理に使用します。
  /// 値が存在する場合は値をそのまま返し、存在しない場合は[onNone]で生成されたOptionを返します。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some(42);
  /// final value = option.orElse(() => Option.some(0)); // Option.some(42)
  ///
  /// final none = Option.none();
  /// final value = none.orElse(() => Option.some(0)); // Option.some(0)
  /// ```
  Option<T> orElse(Option<T> Function() onNone) => switch (this) {
        Some(:final value) => Option.some(value),
        None() => onNone(),
      };

  /// 非同期で値が存在しない場合に別のOptionを返します。値が存在する場合はそのまま返します。
  ///
  /// [onNone] 値が存在しない場合に呼ばれる非同期関数
  ///
  /// `orElse`の非同期版です。非同期処理を含むフォールバック処理に使用します。
  ///
  /// 例:
  /// ```dart
  /// await Option.none()
  ///   .orElseAsync(() async => await fetchFallbackOption());
  /// ```
  Future<Option<T>> orElseAsync(Future<Option<T>> Function() onNone) async =>
      switch (this) {
        Some(:final value) => Option.some(value),
        None() => await onNone(),
      };

  /// 値が存在する場合に条件を満たすかどうかを判定します。
  ///
  /// [predicate] 値を判定する関数
  ///
  /// 値が存在し、条件を満たす場合はSomeを返し、
  /// 値が存在しないか、条件を満たさない場合はNoneを返します。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some(42);
  /// final filtered = option.filter((x) => x > 0); // Option.some(42)
  ///
  /// final filtered2 = option.filter((x) => x < 0); // Option.none()
  ///
  /// final none = Option.none();
  /// final filtered3 = none.filter((x) => x > 0); // Option.none()
  /// ```
  Option<T> filter(bool Function(T) predicate) => switch (this) {
        Some(:final value) =>
          predicate(value) ? Option.some(value) : Option.none(),
        None() => Option.none(),
      };

  /// 値の有無に関わらず値を返します（fold操作）。
  ///
  /// [onNone] 値が存在しない場合に呼ばれる関数
  /// [onSome] 値が存在する場合に呼ばれる関数
  ///
  /// 関数型プログラミングのfold操作です。
  /// 値が存在する場合は[onSome]を、存在しない場合は[onNone]を呼び出し、その結果を返します。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some(42);
  /// final message = option.fold(
  ///   () => '値が存在しません',
  ///   (value) => '値は $value です',
  /// ); // '値は 42 です'
  ///
  /// final none = Option.none();
  /// final message = none.fold(
  ///   () => '値が存在しません',
  ///   (value) => '値は $value です',
  /// ); // '値が存在しません'
  /// ```
  R fold<R>({required R Function() onNone, required R Function(T) onSome}) =>
      switch (this) {
        Some(:final value) => onSome(value),
        None() => onNone(),
      };

  /// OptionをResultに変換します。
  ///
  /// [error] 値が存在しない場合に使用するエラー
  ///
  /// 値が存在する場合は成功のResultを返し、
  /// 存在しない場合は失敗のResultを返します。
  ///
  /// 例:
  /// ```dart
  /// final option = Option.some(42);
  /// final result = option.toResult(() => Exception('値が存在しません'));
  /// // Result.ok(42)
  ///
  /// final none = Option.none();
  /// final result = none.toResult(() => Exception('値が存在しません'));
  /// // Result.error(Exception('値が存在しません'))
  /// ```
  Result<T, E> toResult<E extends Exception>(E Function() error) =>
      switch (this) {
        Some(:final value) => Result.ok(value),
        None() => Result.error(error()),
      };
}
