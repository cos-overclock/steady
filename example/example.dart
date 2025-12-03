import 'package:rustic/rustic.dart';

void main() {
  print('=== rustic サンプルアプリケーション ===\n');

  // Result型の基本的な使用例
  demonstrateResultBasic();
  print('');

  // Result型のチェーン処理
  demonstrateResultChaining();
  print('');

  // Result型のエラーハンドリング
  demonstrateResultErrorHandling();
  print('');

  // Option型の基本的な使用例
  demonstrateOptionBasic();
  print('');

  // Option型のチェーン処理
  demonstrateOptionChaining();
  print('');

  // Option型からResult型への変換
  demonstrateOptionToResult();
  print('');

  // 実用的な例: バリデーション
  demonstrateValidation();
  print('');

  // 実用的な例: データ取得
  demonstrateDataFetching();
}

/// Result型の基本的な使用例
void demonstrateResultBasic() {
  print('--- Result型の基本的な使用例 ---');

  // 成功を表すResult
  final success = Result.ok(42);
  print('成功: ${success.unwrap()}');
  print('isOk: ${success.isOk}');
  print('isErr: ${success.isErr}');

  // 失敗を表すResult
  final failure = Result.error(Exception('エラーが発生しました'));
  print('失敗: ${failure.err}');
  print('isOk: ${failure.isOk}');
  print('isErr: ${failure.isErr}');

  // unwrapOrの使用
  final value = failure.unwrapOr(0);
  print('デフォルト値: $value');
}

/// Result型のチェーン処理
void demonstrateResultChaining() {
  print('--- Result型のチェーン処理 ---');

  final result = Result.ok(10)
      .map((x) => x * 2) // 20
      .andThen((x) => Result.ok(x + 5)) // 25
      .map((x) => x.toString()); // "25"

  print('チェーン処理の結果: ${result.unwrap()}');

  // エラーが発生した場合
  final errorResult = Result.ok(10)
      .map((x) => x * 2)
      .andThen((x) => Result.error(Exception('エラー')))
      .map((x) => x.toString());

  print('エラー時の結果: ${errorResult.isErr}');
  print('エラー内容: ${errorResult.err}');
}

/// Result型のエラーハンドリング
void demonstrateResultErrorHandling() {
  print('--- Result型のエラーハンドリング ---');

  // orElseの使用
  final result1 = Result.error(Exception('エラー1'))
      .orElse((e) => Result.ok(0));
  print('orElseの結果: ${result1.unwrap()}');

  // recoverの使用
  final result2 = Result.error(Exception('ネットワークエラー'))
      .recover((e) {
    print('エラーから回復を試みます: $e');
    return Result.ok(100);
  });
  print('recoverの結果: ${result2.unwrap()}');

  // foldの使用
  final message = Result.ok(42).fold(
    (error) => 'エラー: $error',
    (value) => '値は $value です',
  );
  print('foldの結果: $message');
}

/// Option型の基本的な使用例
void demonstrateOptionBasic() {
  print('--- Option型の基本的な使用例 ---');

  // 値が存在するOption
  final some = Option.some(42);
  print('値が存在: ${some.unwrap()}');
  print('isSome: ${some.isSome}');
  print('isNone: ${some.isNone}');

  // 値が存在しないOption
  final none = Option.none();
  print('値が存在しない: ${none.isNone}');
  print('isSome: ${none.isSome}');

  // unwrapOrの使用
  final value = none.unwrapOr(0);
  print('デフォルト値: $value');
}

/// Option型のチェーン処理
void demonstrateOptionChaining() {
  print('--- Option型のチェーン処理 ---');

  final result = Option.some(10)
      .map((x) => x * 2) // 20
      .andThen((x) => Option.some(x + 5)) // 25
      .map((x) => x.toString()); // "25"

  print('チェーン処理の結果: ${result.unwrap()}');

  // 値が存在しない場合
  final noneResult = Option.none()
      .map((x) => x * 2)
      .andThen((x) => Option.some(x + 5));

  print('Noneの場合の結果: ${noneResult.isNone}');
}

/// Option型からResult型への変換
void demonstrateOptionToResult() {
  print('--- Option型からResult型への変換 ---');

  final option = Option.some(42);
  final result = option.toResult(() => Exception('値が存在しません'));
  print('OptionからResultへの変換: ${result.isOk}');
  print('値: ${result.unwrap()}');

  final none = Option.none();
  final errorResult = none.toResult(() => Exception('値が存在しません'));
  print('NoneからResultへの変換: ${errorResult.isErr}');
  print('エラー: ${errorResult.err}');
}

/// 実用的な例: バリデーション
void demonstrateValidation() {
  print('--- 実用的な例: バリデーション ---');

  // 正の整数をパースする関数
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

  // 有効な値
  final validResult = parsePositiveInt('42');
  print('有効な値: ${validResult.unwrap()}');

  // 無効な値
  final invalidResult = parsePositiveInt('-10');
  print('無効な値のエラー: ${invalidResult.err}');

  // チェーン処理
  final processed = parsePositiveInt('21')
      .map((x) => x * 2)
      .unwrapOr(0);
  print('処理後の値: $processed');
}

/// 実用的な例: データ取得
void demonstrateDataFetching() {
  print('--- 実用的な例: データ取得 ---');

  // ユーザー情報を取得する関数（シミュレーション）
  Option<User> findUser(String userId) {
    final users = {
      '1': User(id: '1', name: 'Alice', age: 30),
      '2': User(id: '2', name: 'Bob', age: 25),
    };
    final user = users[userId];
    return user != null ? Option.some(user) : Option.none();
  }

  // ユーザーが見つかった場合
  final userOption = findUser('1');
  final userName = userOption
      .map((user) => user.name)
      .unwrapOr('Unknown');
  print('ユーザー名: $userName');

  // ユーザーが見つからない場合
  final notFoundOption = findUser('999');
  final defaultName = notFoundOption
      .map((user) => user.name)
      .unwrapOr('Unknown');
  print('見つからない場合: $defaultName');

  // OptionからResultへの変換
  final userResult = findUser('2')
      .toResult(() => Exception('User not found'));
  print('Result型での処理: ${userResult.isOk}');
  if (userResult.isOk) {
    print('ユーザー名: ${userResult.unwrap().name}');
  }
}

/// サンプル用のUserクラス
class User {
  final String id;
  final String name;
  final int age;

  User({
    required this.id,
    required this.name,
    required this.age,
  });

  @override
  String toString() => 'User(id: $id, name: $name, age: $age)';
}

