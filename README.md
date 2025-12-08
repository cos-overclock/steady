# steady

[![pub package](https://img.shields.io/pub/v/steady.svg)](https://pub.dev/packages/steady)

Dart用のResult型とOption型の汎用ライブラリです。Rustの`Result<T, E>`型と`Option<T>`型にインスパイアされた実装で、例外処理とnull安全性を明示的かつ型安全に扱うことができます。

## 特徴

- ✅ **型安全なエラーハンドリング**: Result型で例外を明示的に扱い、コンパイル時にエラーを検出
- ✅ **型安全なnull処理**: Option型でnull安全性を明示的に扱い、null参照エラーを防止
- ✅ **豊富なユーティリティメソッド**: チェーン処理、変換、エラー回復など、便利なメソッドを提供
- ✅ **非同期処理対応**: 非同期処理を含む操作もサポート
- ✅ **Freezedベース**: イミュータブルでパターンマッチングに対応
- ✅ **軽量**: 最小限の依存関係で実装

## インストール

`pubspec.yaml`に追加してください:

```yaml
dependencies:
  steady: ^1.0.0
```

その後、以下のコマンドを実行:

```bash
flutter pub get
```

## 基本的な使用方法

### Result型

#### Resultの作成

```dart
import 'package:steady/steady.dart';

// 成功を表すResult
final success = Result.ok(42);

// 失敗を表すResult
final failure = Result.error(Exception('エラーが発生しました'));
```

### 値の取得

```dart
// 成功値を取得（失敗時は例外を投げる）
final value = success.unwrap(); // 42

// デフォルト値を指定
final value = failure.unwrapOr(0); // 0

// 計算されたデフォルト値
final value = failure.unwrapOrElse((error) {
  print('エラー: $error');
  return 0;
});

// カスタムメッセージ付きで例外を投げる（元のE型で再throw）
final value = failure.expect('値の取得に失敗'); // 失敗時は元の例外を再送出
```

### 成功/失敗の判定

```dart
if (result.isOk) {
  print('成功: ${result.ok}');
}

if (result.isErr) {
  print('失敗: ${result.err}');
}
```

### Option型

#### Optionの作成

```dart
import 'package:steady/steady.dart';

// 値が存在するOption
final some = Option.some(42);

// 値が存在しないOption
final none = Option.none();
```

#### 値の取得

```dart
// 値を取得（存在しない場合は例外を投げる）
final value = some.unwrap(); // 42

// デフォルト値を指定
final value = none.unwrapOr(0); // 0

// 計算されたデフォルト値
final value = none.unwrapOrElse(() {
  print('値が存在しません');
  return 0;
});

// カスタムメッセージ付きで例外を投げる（StateErrorを送出）
final value = none.expect('値の取得に失敗'); // StateErrorを投げる
```

#### 値の存在判定

```dart
if (option.isSome) {
  print('値が存在: ${option.value}');
}

if (option.isNone) {
  print('値が存在しません');
}
```

## 主な機能

### Result型

### 値の変換 (`map`)

成功値を別の型に変換します。失敗時はエラーをそのまま返します。  
`onSuccess` が `E` 型の例外を投げた場合は `Err` に包まれ、それ以外の例外はそのまま再throwされます。

```dart
final result = Result.ok(21);
final doubled = result.map((x) => x * 2); // Result.ok(42)

// 失敗時はエラーをそのまま返す
final error = Result.error(Exception('エラー'));
final doubled = error.map((x) => x * 2); // エラーをそのまま返す
```

### 非同期変換 (`mapAsync`)

非同期で値を変換します。  
`onSuccess` が `E` 型の例外を投げた場合は `Err` に包まれ、それ以外の例外はそのまま再throwされます。

```dart
final result = Result.ok('data');
final processed = await result.mapAsync((x) async {
  return await processData(x);
});
```

### エラー変換 (`mapErr`)

エラー値を別の型の例外に変換します。

```dart
final error = Result.error(FormatException('parse error'));
final mapped = error.mapErr((e) => Exception('converted: $e'));
```

### チェーン処理 (`andThen`)

Resultを返す関数をチェーンできます。

```dart
final result = Result.ok(21)
    .andThen((x) => Result.ok(x * 2))
    .andThen((x) => Result.ok(x + 1))
    .unwrap(); // 43
```

### エラー回復 (`orElse` / `recover`)

エラー時に代替のResultを返します。

```dart
// orElse: 異なるエラー型を返すことができる
final result = Result.error(Exception('エラー'))
    .orElse((e) => Result.ok(0)); // Result.ok(0)

// recover: 同じエラー型を返す
final result = Result.error(Exception('network error'))
    .recover((e) => Result.ok(defaultValue));
```

### Fold操作

成功/失敗の両方で値を返します。

```dart
final result = Result.ok(42);
final message = result.fold(
  (error) => 'Error: $error',
  (value) => 'Value: $value',
); // 'Value: 42'
```

### Option型

#### 値の変換 (`map`)

値を別の型に変換します。値が存在しない場合はNoneをそのまま返します。

```dart
final option = Option.some(21);
final doubled = option.map((x) => x * 2); // Option.some(42)

// 値が存在しない場合はNoneをそのまま返す
final none = Option.none();
final doubled = none.map((x) => x * 2); // Option.none()
```

#### 非同期変換 (`mapAsync`)

非同期で値を変換します。

```dart
final option = Option.some('data');
final processed = await option.mapAsync((x) async {
  return await processData(x);
});
```

#### チェーン処理 (`andThen`)

Optionを返す関数をチェーンできます。

```dart
final result = Option.some(21)
    .andThen((x) => Option.some(x * 2))
    .andThen((x) => Option.some(x + 1))
    .unwrap(); // 43
```

#### フォールバック (`orElse`)

値が存在しない場合に代替のOptionを返します。

```dart
final none = Option.none();
final value = none.orElse(() => Option.some(0)); // Option.some(0)
```

#### フィルタリング (`filter`)

条件を満たす値のみを保持します。

```dart
final option = Option.some(42);
final filtered = option.filter((x) => x > 0); // Option.some(42)
final filtered2 = option.filter((x) => x < 0); // Option.none()
```

#### Fold操作

値の有無に関わらず値を返します。

```dart
final option = Option.some(42);
final message = option.fold(
  () => '値が存在しません',
  (value) => '値は $value です',
); // '値は 42 です'
```

#### Result型への変換 (`toResult`)

OptionをResult型に変換します。

```dart
final option = Option.some(42);
final result = option.toResult(() => Exception('値が存在しません'));
// Result.ok(42)

final none = Option.none();
final result = none.toResult(() => Exception('値が存在しません'));
// Result.error(Exception('値が存在しません'))
```

## API リファレンス

### Result型

### ファクトリーメソッド

#### `Result.ok(T data)`
成功を表すResultを作成します。

#### `Result.error(E error)`
失敗を表すResultを作成します。

### 値の取得

#### `T unwrap()`
成功値を取得します。失敗時は例外を投げます。

#### `T unwrapOr(T defaultValue)`
成功値を取得します。失敗時はデフォルト値を返します。

#### `T unwrapOrElse(T Function(E) onFailure)`
成功値を取得します。失敗時は計算されたデフォルト値を返します。

#### `T expect(String message)`
成功値を取得します。失敗時は元の例外を再送出します。

### 判定

#### `bool get isOk`
Resultが成功かどうかを判定します。

#### `bool get isErr`
Resultが失敗かどうかを判定します。

#### `T? get ok`
成功値を取得します。失敗時はnullを返します。

#### `E? get err`
エラー値を取得します。成功時はnullを返します。

### 変換

#### `Result<U, E> map<U>(U Function(T) onSuccess)`
成功値を別の型に変換します。

#### `Future<Result<U, E>> mapAsync<U>(Future<U> Function(T) onSuccess)`
成功値を非同期で別の型に変換します。

#### `Result<T, F> mapErr<F extends Exception>(F Function(E) onFailure)`
エラー値を別の型の例外に変換します。

#### `Future<Result<T, F>> mapErrAsync<F extends Exception>(Future<F> Function(E) onFailure)`
エラー値を非同期で別の型の例外に変換します。

### チェーン処理

#### `Result<U, E> andThen<U>(Result<U, E> Function(T) onSuccess)`
成功時にResultを返す関数を適用します。

#### `Future<Result<U, E>> andThenAsync<U>(Future<Result<U, E>> Function(T) onSuccess)`
非同期でResultを返す関数を適用します。

### エラーハンドリング

#### `Result<T, F> orElse<F extends Exception>(Result<T, F> Function(E) onFailure)`
失敗時に別のResultを返します。

#### `Future<Result<T, F>> orElseAsync<F extends Exception>(Future<Result<T, F>> Function(E) onFailure)`
非同期で失敗時に別のResultを返します。

#### `Result<T, E> recover(Result<T, E> Function(E) onFailure)`
エラーから回復を試みます。

#### `Future<Result<T, E>> recoverAsync(Future<Result<T, E>> Function(E) onFailure)`
非同期でエラーから回復を試みます。

### その他

#### `R fold<R>(R Function(E) onFailure, R Function(T) onSuccess)`
成功/失敗の両方で値を返します。

### Option型

#### ファクトリーメソッド

#### `Option.some(T value)`
値が存在するOptionを作成します。

#### `Option.none()`
値が存在しないOptionを作成します。

#### 値の取得

#### `T unwrap()`
値を取得します。値が存在しない場合は例外を投げます。

#### `T unwrapOr(T defaultValue)`
値を取得します。値が存在しない場合はデフォルト値を返します。

#### `T unwrapOrElse(T Function() onNone)`
値を取得します。値が存在しない場合は計算されたデフォルト値を返します。

#### `T expect(String message)`
値を取得します。値が存在しない場合はStateErrorを投げます。

#### 判定

#### `bool get isSome`
Optionが値を持つかどうかを判定します。

#### `bool get isNone`
Optionが値を持たないかどうかを判定します。

#### `T? get value`
値を取得します。値が存在しない場合はnullを返します。

#### 変換

#### `Option<U> map<U>(U Function(T) onSome)`
値を別の型に変換します。

#### `Future<Option<U>> mapAsync<U>(Future<U> Function(T) onSome)`
値を非同期で別の型に変換します。

#### チェーン処理

#### `Option<U> andThen<U>(Option<U> Function(T) onSome)`
値が存在する場合にOptionを返す関数を適用します。

#### `Future<Option<U>> andThenAsync<U>(Future<Option<U>> Function(T) onSome)`
非同期でOptionを返す関数を適用します。

#### エラーハンドリング

#### `Option<T> orElse(Option<T> Function() onNone)`
値が存在しない場合に別のOptionを返します。

#### `Future<Option<T>> orElseAsync(Future<Option<T>> Function() onNone)`
非同期で値が存在しない場合に別のOptionを返します。

#### その他

#### `Option<T> filter(bool Function(T) predicate)`
条件を満たす値のみを保持します。

#### `R fold<R>(R Function() onNone, R Function(T) onSome)`
値の有無に関わらず値を返します。

#### `Result<T, E> toResult<E extends Exception>(E Function() error)`
OptionをResult型に変換します。

## 使用例

### 例1: API呼び出し

```dart
Future<Result<User, Exception>> fetchUser(int id) async {
  try {
    final response = await http.get(Uri.parse('/users/$id'));
    if (response.statusCode == 200) {
      return Result.ok(User.fromJson(response.body));
    } else {
      return Result.error(Exception('Failed to fetch user'));
    }
  } catch (e) {
    return Result.error(Exception('Network error: $e'));
  }
}

// 使用例
final userResult = await fetchUser(1);
final userName = userResult
    .map((user) => user.name)
    .unwrapOr('Unknown');
```

### 例2: バリデーション

```dart
Result<int, Exception> parsePositiveInt(String value) {
  final parsed = int.tryParse(value);
  if (parsed == null) {
    return Result.error(FormatException('Invalid number: $value'));
  }
  if (parsed <= 0) {
    return Result.error(Exception('Number must be positive'));
  }
  return Result.ok(parsed);
}

// 使用例
final result = parsePositiveInt('42')
    .map((x) => x * 2)
    .unwrapOr(0);
```

### 例3: エラー回復

```dart
Future<Result<String, Exception>> fetchData() async {
  // プライマリソースから取得を試みる
  final primary = await fetchFromPrimary();
  if (primary.isOk) return primary;
  
  // 失敗したらセカンダリソースから取得
  return primary.orElseAsync((e) async {
    print('Primary failed: $e, trying secondary...');
    return await fetchFromSecondary();
  });
}
```

### 例4: 複数の操作をチェーン

```dart
Result<String, Exception> processData(int input) {
  return Result.ok(input)
      .andThen((x) => validateInput(x))
      .map((x) => x * 2)
      .andThen((x) => saveToDatabase(x))
      .map((x) => x.toString());
}

Result<int, Exception> validateInput(int value) {
  if (value < 0) {
    return Result.error(Exception('Value must be positive'));
  }
  return Result.ok(value);
}
```

### 例5: Option型の使用

```dart
Option<int> findUserAge(String userId) {
  final user = users[userId];
  return user != null ? Option.some(user.age) : Option.none();
}

// 使用例
final ageOption = findUserAge('user123');
final age = ageOption
    .map((age) => age + 1)
    .unwrapOr(0);
```

### 例6: Option型のチェーン処理

```dart
Option<String> getUserEmail(String userId) {
  return findUser(userId)
      .andThen((user) => Option.some(user.email))
      .filter((email) => email.contains('@'));
}

Option<User> findUser(String userId) {
  final user = users[userId];
  return user != null ? Option.some(user) : Option.none();
}
```

### 例7: Option型からResult型への変換

```dart
Result<int, Exception> parseAndValidate(String input) {
  return Option.some(input)
      .map((s) => int.tryParse(s))
      .andThen((parsed) => parsed != null 
          ? Option.some(parsed) 
          : Option.none())
      .filter((value) => value > 0)
      .toResult(() => Exception('Invalid input: $input'));
}
```

## サンプルアプリケーション

`example`ディレクトリにサンプルアプリケーションが含まれています。

```bash
cd example
dart pub get
dart run example.dart
```

サンプルアプリケーションでは以下の内容をデモンストレーションしています：

- Result型の基本的な使用方法
- Result型のチェーン処理
- Result型のエラーハンドリング
- Option型の基本的な使用方法
- Option型のチェーン処理
- Option型からResult型への変換
- 実用的な例（バリデーション、データ取得）

## テスト

```bash
dart test
```

## コントリビューション

プルリクエストやイシューの報告を歓迎します。改善提案もお待ちしています。

## 関連リンク

- [pub.dev](https://pub.dev/packages/steady)
- [GitHub](https://github.com/cos-overclock/steady)
