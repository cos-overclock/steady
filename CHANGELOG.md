## 1.0.1

foldメソッドを名前付き引数に変更

## 1.0.0

初回リリース

### 機能

#### Result型

Rustの`Result<T, E>`にインスパイアされた型安全なエラーハンドリング

- **基本操作**: `ok`/`error`による成功/失敗の表現、`unwrap`/`unwrapOr`/`expect`による値の取得
- **変換**: `map`, `mapErr`による値の変換、非同期対応（`mapAsync`, `mapErrAsync`）
- **チェーン処理**: `andThen`, `andThenAsync`による関数の合成
- **エラー回復**: `orElse`, `recover`によるフォールバック処理
- **fold操作**: 成功/失敗の両ケースを統一的に処理

#### Option型

Rustの`Option<T>`にインスパイアされた型安全なnull処理

- **基本操作**: `some`/`none`による値の有無の表現、`unwrap`/`unwrapOr`/`expect`による値の取得
- **変換**: `map`による値の変換、非同期対応（`mapAsync`）
- **チェーン処理**: `andThen`, `andThenAsync`による関数の合成
- **フィルタリング**: `filter`による条件に基づく値の絞り込み
- **フォールバック**: `orElse`による代替値の提供
- **型変換**: `toResult`によるResult型への変換

#### その他

- Freezedベースのイミュータブルな実装
- パターンマッチング対応
- 包括的なテストカバレッジ（85テストケース）
- MIT License
