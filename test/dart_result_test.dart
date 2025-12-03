import 'package:test/test.dart';
import 'package:dart_result/dart_result.dart';

void main() {
  group('Result型の基本操作', () {
    test('Result.okで成功を作成できる', () {
      final result = Result.ok(42);
      expect(result.isOk, true);
      expect(result.isErr, false);
      expect(result.unwrap(), 42);
    });

    test('Result.errorで失敗を作成できる', () {
      final error = Exception('エラーが発生しました');
      final result = Result.error(error);
      expect(result.isOk, false);
      expect(result.isErr, true);
      expect(result.err, error);
    });
  });

  group('unwrap', () {
    test('成功時に値を返す', () {
      final result = Result.ok(42);
      expect(result.unwrap(), 42);
    });

    test('失敗時に例外を投げる', () {
      final error = Exception('エラー');
      final result = Result.error(error);
      expect(() => result.unwrap(), throwsA(error));
    });
  });

  group('unwrapOr', () {
    test('成功時に値を返す', () {
      final result = Result.ok(42);
      expect(result.unwrapOr(0), 42);
    });

    test('失敗時にデフォルト値を返す', () {
      final result = Result.error(Exception('エラー'));
      expect(result.unwrapOr(0), 0);
    });
  });

  group('unwrapOrElse', () {
    test('成功時に値を返す', () {
      final result = Result.ok(42);
      expect(result.unwrapOrElse((e) => 0), 42);
    });

    test('失敗時に計算されたデフォルト値を返す', () {
      final error = Exception('エラー');
      final result = Result.error(error);
      var called = false;
      final value = result.unwrapOrElse((e) {
        called = true;
        expect(e, error);
        return 0;
      });
      expect(value, 0);
      expect(called, true);
    });
  });

  group('expect', () {
    test('成功時に値を返す', () {
      final result = Result.ok(42);
      expect(result.expect('メッセージ'), 42);
    });

    test('失敗時にカスタムメッセージ付きで例外を投げる', () {
      final error = Exception('エラー');
      final result = Result.error(error);
      expect(
        () => result.expect('値の取得に失敗'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('値の取得に失敗'),
        )),
      );
    });
  });

  group('isOk / isErr', () {
    test('成功時にisOkがtrue、isErrがfalse', () {
      final result = Result.ok(42);
      expect(result.isOk, true);
      expect(result.isErr, false);
    });

    test('失敗時にisOkがfalse、isErrがtrue', () {
      final result = Result.error(Exception('エラー'));
      expect(result.isOk, false);
      expect(result.isErr, true);
    });
  });

  group('ok / err ゲッター', () {
    test('成功時にokが値を返し、errがnullを返す', () {
      final result = Result.ok(42);
      expect(result.ok, 42);
      expect(result.err, null);
    });

    test('失敗時にokがnullを返し、errがエラーを返す', () {
      final error = Exception('エラー');
      final result = Result.error(error);
      expect(result.ok, null);
      expect(result.err, error);
    });
  });

  group('map', () {
    test('成功時に値を変換する', () {
      final result = Result.ok(21);
      final doubled = result.map((x) => x * 2);
      expect(doubled.isOk, true);
      expect(doubled.unwrap(), 42);
    });

    test('失敗時はエラーをそのまま返す', () {
      final error = Exception('エラー');
      final result = Result.error(error);
      final doubled = result.map((x) => x * 2);
      expect(doubled.isErr, true);
      expect(doubled.err, error);
    });
  });

  group('mapAsync', () {
    test('成功時に値を非同期で変換する', () async {
      final result = Result.ok(21);
      final doubled = await result.mapAsync((x) async {
        await Future.delayed(Duration(milliseconds: 10));
        return x * 2;
      });
      expect(doubled.isOk, true);
      expect(doubled.unwrap(), 42);
    });

    test('失敗時はエラーをそのまま返す', () async {
      final error = Exception('エラー');
      final result = Result.error(error);
      final doubled = await result.mapAsync((x) async => x * 2);
      expect(doubled.isErr, true);
      expect(doubled.err, error);
    });
  });

  group('mapErr', () {
    test('成功時は値をそのまま返す', () {
      final result = Result.ok(42);
      final mapped = result.mapErr((e) => Exception('変換された: $e'));
      expect(mapped.isOk, true);
      expect(mapped.unwrap(), 42);
    });

    test('失敗時にエラーを変換する', () {
      final error = FormatException('parse error');
      final result = Result.error(error);
      final mapped = result.mapErr((e) => Exception('converted: $e'));
      expect(mapped.isErr, true);
      expect(mapped.err, isA<Exception>());
      expect(mapped.err.toString(), contains('converted'));
    });
  });

  group('mapErrAsync', () {
    test('成功時は値をそのまま返す', () async {
      final result = Result.ok(42);
      final mapped = await result.mapErrAsync((e) async => Exception('変換された'));
      expect(mapped.isOk, true);
      expect(mapped.unwrap(), 42);
    });

    test('失敗時にエラーを非同期で変換する', () async {
      final error = FormatException('parse error');
      final result = Result.error(error);
      final mapped = await result.mapErrAsync((e) async {
        await Future.delayed(Duration(milliseconds: 10));
        return Exception('converted: $e');
      });
      expect(mapped.isErr, true);
      expect(mapped.err, isA<Exception>());
      expect(mapped.err.toString(), contains('converted'));
    });
  });

  group('andThen', () {
    test('成功時にResultを返す関数をチェーンできる', () {
      final result = Result.ok(21)
          .andThen((x) => Result.ok(x * 2))
          .andThen((x) => Result.ok(x + 1));
      expect(result.isOk, true);
      expect(result.unwrap(), 43);
    });

    test('失敗時はエラーをそのまま返す', () {
      final error = Exception('エラー');
      final result = Result.error(error);
      final chained = result.andThen((x) => Result.ok(x * 2));
      expect(chained.isErr, true);
      expect(chained.err, error);
    });

    test('チェーン中に失敗が発生した場合、そのエラーを返す', () {
      final error = Exception('チェーン中のエラー');
      final result = Result.ok(21)
          .andThen((x) => Result.error(error))
          .andThen((x) => Result.ok(x * 2));
      expect(result.isErr, true);
      expect(result.err, error);
    });
  });

  group('andThenAsync', () {
    test('成功時にResultを返す非同期関数をチェーンできる', () async {
      final first = await Result.ok(21).andThenAsync((x) async {
        await Future.delayed(Duration(milliseconds: 10));
        return Result.ok(x * 2);
      });
      final result = await first.andThenAsync((x) async {
        await Future.delayed(Duration(milliseconds: 10));
        return Result.ok(x + 1);
      });
      expect(result.isOk, true);
      expect(result.unwrap(), 43);
    });

    test('失敗時はエラーをそのまま返す', () async {
      final error = Exception('エラー');
      final result = Result.error(error);
      final chained = await result.andThenAsync((x) async => Result.ok(x * 2));
      expect(chained.isErr, true);
      expect(chained.err, error);
    });
  });

  group('orElse', () {
    test('成功時は値をそのまま返す', () {
      final result = Result.ok(42);
      final value = result.orElse((e) => Result.ok(0));
      expect(value.isOk, true);
      expect(value.unwrap(), 42);
    });

    test('失敗時に代替のResultを返す', () {
      final error = Exception('エラー');
      final result = Result.error(error);
      final value = result.orElse((e) => Result.ok(0));
      expect(value.isOk, true);
      expect(value.unwrap(), 0);
    });

    test('失敗時にエラー情報を利用できる', () {
      final error = Exception('エラー');
      final result = Result.error(error);
      var called = false;
      final value = result.orElse((e) {
        called = true;
        expect(e, error);
        return Result.ok(0);
      });
      expect(value.isOk, true);
      expect(called, true);
    });
  });

  group('orElseAsync', () {
    test('成功時は値をそのまま返す', () async {
      final result = Result.ok(42);
      final value = await result.orElseAsync((e) async => Result.ok(0));
      expect(value.isOk, true);
      expect(value.unwrap(), 42);
    });

    test('失敗時に代替のResultを非同期で返す', () async {
      final error = Exception('エラー');
      final result = Result.error(error);
      final value = await result.orElseAsync((e) async {
        await Future.delayed(Duration(milliseconds: 10));
        return Result.ok(0);
      });
      expect(value.isOk, true);
      expect(value.unwrap(), 0);
    });
  });

  group('fold', () {
    test('成功時にonSuccessを呼び出す', () {
      final result = Result.ok(42);
      final message = result.fold(
        (error) => 'Error: $error',
        (value) => 'Value: $value',
      );
      expect(message, 'Value: 42');
    });

    test('失敗時にonFailureを呼び出す', () {
      final error = Exception('エラー');
      final result = Result.error(error);
      final message = result.fold(
        (error) => 'Error: $error',
        (value) => 'Value: $value',
      );
      expect(message, contains('Error:'));
      expect(message, contains('エラー'));
    });

    test('異なる型を返すことができる', () {
      final result = Result.ok(42);
      final count = result.fold(
        (error) => 0,
        (value) => 1,
      );
      expect(count, 1);

      final error = Result.error(Exception('エラー'));
      final count2 = error.fold(
        (error) => 0,
        (value) => 1,
      );
      expect(count2, 0);
    });
  });

  group('recover', () {
    test('成功時は値をそのまま返す', () {
      final result = Result.ok(42);
      final recovered = result.recover((e) => Result.ok(0));
      expect(recovered.isOk, true);
      expect(recovered.unwrap(), 42);
    });

    test('失敗時に回復を試みる', () {
      final error = Exception('network error');
      final result = Result.error(error);
      final recovered = result.recover((e) {
        expect(e, error);
        return Result.ok(0);
      });
      expect(recovered.isOk, true);
      expect(recovered.unwrap(), 0);
    });

    test('回復に失敗した場合、新しいエラーを返す', () {
      final error = Exception('network error');
      final result = Result.error(error);
      final newError = Exception('recovery failed');
      final recovered = result.recover((e) => Result.error(newError));
      expect(recovered.isErr, true);
      expect(recovered.err, newError);
    });
  });

  group('recoverAsync', () {
    test('成功時は値をそのまま返す', () async {
      final result = Result.ok(42);
      final recovered = await result.recoverAsync((e) async => Result.ok(0));
      expect(recovered.isOk, true);
      expect(recovered.unwrap(), 42);
    });

    test('失敗時に非同期で回復を試みる', () async {
      final error = Exception('network error');
      final result = Result.error(error);
      final recovered = await result.recoverAsync((e) async {
        await Future.delayed(Duration(milliseconds: 10));
        expect(e, error);
        return Result.ok(0);
      });
      expect(recovered.isOk, true);
      expect(recovered.unwrap(), 0);
    });
  });

  group('複合的な使用例', () {
    test('複数の操作をチェーンできる', () {
      final result = Result.ok(10)
          .map((x) => x * 2)
          .andThen((x) => Result.ok(x + 5))
          .map((x) => x.toString())
          .unwrap();
      expect(result, '25');
    });

    test('エラーハンドリングのチェーン', () {
      final result = Result.error(Exception('最初のエラー'))
          .orElse((e) => Result.ok(0))
          .map((x) => x * 2)
          .unwrap();
      expect(result, 0);
    });

    test('foldを使ったエラーハンドリング', () {
      final result = Result.ok(42);
      final message = result.map((x) => x * 2).fold(
            (error) => 'エラーが発生しました: $error',
            (value) => '値は $value です',
          );
      expect(message, '値は 84 です');
    });
  });

  group('型安全性', () {
    test('異なる型のResultを扱える', () {
      final intResult = Result.ok(42);
      final stringResult = intResult.map((x) => x.toString());
      expect(stringResult.unwrap(), '42');
      expect(stringResult, isA<Result<String, Exception>>());
    });

    test('異なる例外型を扱える', () {
      final formatError = FormatException('parse error');
      final result = Result.error(formatError);
      final mapped = result.mapErr((e) => Exception('converted: $e'));
      expect(mapped.err, isA<Exception>());
      expect(mapped.err, isNot(isA<FormatException>()));
    });
  });

  group('Option型の基本操作', () {
    test('Option.someで値を持つOptionを作成できる', () {
      final option = Option.some(42);
      expect(option.isSome, true);
      expect(option.isNone, false);
      expect(option.unwrap(), 42);
    });

    test('Option.noneで値を持たないOptionを作成できる', () {
      final option = Option.none();
      expect(option.isSome, false);
      expect(option.isNone, true);
      expect(option.value, null);
    });
  });

  group('Option型のunwrap', () {
    test('値が存在する場合に値を返す', () {
      final option = Option.some(42);
      expect(option.unwrap(), 42);
    });

    test('値が存在しない場合に例外を投げる', () {
      final option = Option.none();
      expect(() => option.unwrap(), throwsA(isA<Exception>()));
    });
  });

  group('Option型のunwrapOr', () {
    test('値が存在する場合に値を返す', () {
      final option = Option.some(42);
      expect(option.unwrapOr(0), 42);
    });

    test('値が存在しない場合にデフォルト値を返す', () {
      final option = Option.none();
      expect(option.unwrapOr(0), 0);
    });
  });

  group('Option型のunwrapOrElse', () {
    test('値が存在する場合に値を返す', () {
      final option = Option.some(42);
      expect(option.unwrapOrElse(() => 0), 42);
    });

    test('値が存在しない場合に計算されたデフォルト値を返す', () {
      final option = Option.none();
      var called = false;
      final value = option.unwrapOrElse(() {
        called = true;
        return 0;
      });
      expect(value, 0);
      expect(called, true);
    });
  });

  group('Option型のexpect', () {
    test('値が存在する場合に値を返す', () {
      final option = Option.some(42);
      expect(option.expect('メッセージ'), 42);
    });

    test('値が存在しない場合にカスタムメッセージ付きで例外を投げる', () {
      final option = Option.none();
      expect(
        () => option.expect('値の取得に失敗'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('値の取得に失敗'),
        )),
      );
    });
  });

  group('Option型のisSome / isNone', () {
    test('値が存在する場合にisSomeがtrue、isNoneがfalse', () {
      final option = Option.some(42);
      expect(option.isSome, true);
      expect(option.isNone, false);
    });

    test('値が存在しない場合にisSomeがfalse、isNoneがtrue', () {
      final option = Option.none();
      expect(option.isSome, false);
      expect(option.isNone, true);
    });
  });

  group('Option型のvalueゲッター', () {
    test('値が存在する場合に値を返し、存在しない場合にnullを返す', () {
      final option = Option.some(42);
      expect(option.value, 42);
    });

    test('値が存在しない場合にnullを返す', () {
      final option = Option.none();
      expect(option.value, null);
    });
  });

  group('Option型のmap', () {
    test('値が存在する場合に値を変換する', () {
      final option = Option.some(21);
      final doubled = option.map((x) => x * 2);
      expect(doubled.isSome, true);
      expect(doubled.unwrap(), 42);
    });

    test('値が存在しない場合はNoneをそのまま返す', () {
      final option = Option.none();
      final doubled = option.map((x) => x * 2);
      expect(doubled.isNone, true);
    });
  });

  group('Option型のmapAsync', () {
    test('値が存在する場合に値を非同期で変換する', () async {
      final option = Option.some(21);
      final doubled = await option.mapAsync((x) async {
        await Future.delayed(Duration(milliseconds: 10));
        return x * 2;
      });
      expect(doubled.isSome, true);
      expect(doubled.unwrap(), 42);
    });

    test('値が存在しない場合はNoneをそのまま返す', () async {
      final option = Option.none();
      final doubled = await option.mapAsync((x) async => x * 2);
      expect(doubled.isNone, true);
    });
  });

  group('Option型のandThen', () {
    test('値が存在する場合にOptionを返す関数をチェーンできる', () {
      final option = Option.some(21)
          .andThen((x) => Option.some(x * 2))
          .andThen((x) => Option.some(x + 1));
      expect(option.isSome, true);
      expect(option.unwrap(), 43);
    });

    test('値が存在しない場合はNoneをそのまま返す', () {
      final option = Option.none();
      final chained = option.andThen((x) => Option.some(x * 2));
      expect(chained.isNone, true);
    });

    test('チェーン中にNoneが返された場合、そのNoneを返す', () {
      final option = Option.some(21)
          .andThen((x) => Option.none())
          .andThen((x) => Option.some(x * 2));
      expect(option.isNone, true);
    });
  });

  group('Option型のandThenAsync', () {
    test('値が存在する場合にOptionを返す非同期関数をチェーンできる', () async {
      final first = await Option.some(21).andThenAsync((x) async {
        await Future.delayed(Duration(milliseconds: 10));
        return Option.some(x * 2);
      });
      final result = await first.andThenAsync((x) async {
        await Future.delayed(Duration(milliseconds: 10));
        return Option.some(x + 1);
      });
      expect(result.isSome, true);
      expect(result.unwrap(), 43);
    });

    test('値が存在しない場合はNoneをそのまま返す', () async {
      final option = Option.none();
      final chained =
          await option.andThenAsync((x) async => Option.some(x * 2));
      expect(chained.isNone, true);
    });
  });

  group('Option型のorElse', () {
    test('値が存在する場合は値をそのまま返す', () {
      final option = Option.some(42);
      final value = option.orElse(() => Option.some(0));
      expect(value.isSome, true);
      expect(value.unwrap(), 42);
    });

    test('値が存在しない場合に代替のOptionを返す', () {
      final option = Option.none();
      final value = option.orElse(() => Option.some(0));
      expect(value.isSome, true);
      expect(value.unwrap(), 0);
    });

    test('値が存在しない場合に関数が呼ばれる', () {
      final option = Option.none();
      var called = false;
      final value = option.orElse(() {
        called = true;
        return Option.some(0);
      });
      expect(value.isSome, true);
      expect(called, true);
    });
  });

  group('Option型のorElseAsync', () {
    test('値が存在する場合は値をそのまま返す', () async {
      final option = Option.some(42);
      final value = await option.orElseAsync(() async => Option.some(0));
      expect(value.isSome, true);
      expect(value.unwrap(), 42);
    });

    test('値が存在しない場合に代替のOptionを非同期で返す', () async {
      final option = Option.none();
      final value = await option.orElseAsync(() async {
        await Future.delayed(Duration(milliseconds: 10));
        return Option.some(0);
      });
      expect(value.isSome, true);
      expect(value.unwrap(), 0);
    });
  });

  group('Option型のfilter', () {
    test('値が存在し条件を満たす場合はSomeを返す', () {
      final option = Option.some(42);
      final filtered = option.filter((x) => x > 0);
      expect(filtered.isSome, true);
      expect(filtered.unwrap(), 42);
    });

    test('値が存在するが条件を満たさない場合はNoneを返す', () {
      final option = Option.some(42);
      final filtered = option.filter((x) => x < 0);
      expect(filtered.isNone, true);
    });

    test('値が存在しない場合はNoneをそのまま返す', () {
      final option = Option.none();
      final filtered = option.filter((x) => x > 0);
      expect(filtered.isNone, true);
    });
  });

  group('Option型のfold', () {
    test('値が存在する場合にonSomeを呼び出す', () {
      final option = Option.some(42);
      final message = option.fold(
        () => '値が存在しません',
        (value) => '値は $value です',
      );
      expect(message, '値は 42 です');
    });

    test('値が存在しない場合にonNoneを呼び出す', () {
      final option = Option.none();
      final message = option.fold(
        () => '値が存在しません',
        (value) => '値は $value です',
      );
      expect(message, '値が存在しません');
    });

    test('異なる型を返すことができる', () {
      final option = Option.some(42);
      final count = option.fold(
        () => 0,
        (value) => 1,
      );
      expect(count, 1);

      final none = Option.none();
      final count2 = none.fold(
        () => 0,
        (value) => 1,
      );
      expect(count2, 0);
    });
  });

  group('Option型のtoResult', () {
    test('値が存在する場合に成功のResultを返す', () {
      final option = Option.some(42);
      final result = option.toResult(() => Exception('値が存在しません'));
      expect(result.isOk, true);
      expect(result.unwrap(), 42);
    });

    test('値が存在しない場合に失敗のResultを返す', () {
      final option = Option.none();
      final error = Exception('値が存在しません');
      final result = option.toResult(() => error);
      expect(result.isErr, true);
      expect(result.err, error);
    });
  });

  group('Option型の複合的な使用例', () {
    test('複数の操作をチェーンできる', () {
      final result = Option.some(10)
          .map((x) => x * 2)
          .andThen((x) => Option.some(x + 5))
          .map((x) => x.toString())
          .unwrap();
      expect(result, '25');
    });

    test('フォールバック処理のチェーン', () {
      final result =
          Option.none().orElse(() => Option.some(0)).map((x) => x * 2).unwrap();
      expect(result, 0);
    });

    test('foldを使った値の処理', () {
      final option = Option.some(42);
      final message = option.map((x) => x * 2).fold(
            () => '値が存在しません',
            (value) => '値は $value です',
          );
      expect(message, '値は 84 です');
    });

    test('filterとmapの組み合わせ', () {
      final option = Option.some(42).filter((x) => x > 0).map((x) => x * 2);
      expect(option.isSome, true);
      expect(option.unwrap(), 84);

      final filtered = Option.some(-1).filter((x) => x > 0).map((x) => x * 2);
      expect(filtered.isNone, true);
    });
  });

  group('Option型の型安全性', () {
    test('異なる型のOptionを扱える', () {
      final intOption = Option.some(42);
      final stringOption = intOption.map((x) => x.toString());
      expect(stringOption.unwrap(), '42');
      expect(stringOption, isA<Option<String>>());
    });

    test('Option型からResult型への変換', () {
      final option = Option.some(42);
      final result = option.toResult(() => Exception('エラー'));
      expect(result, isA<Result<int, Exception>>());
      expect(result.isOk, true);
    });
  });
}
